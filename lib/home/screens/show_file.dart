import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:mstand/home/dialogs/add_offices.dart';
import 'package:mstand/home/screens/pdf_view.dart';
import 'package:mstand/home/screens/show_images_doc.dart';
import 'package:mstand/language_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';

import '../../notification.dart';

// Show File Scrren Buttons

class ShowFile extends StatefulWidget {
  String fileName;
  String fileInfo;
  String coName;
  String projectName;
  String branchName;
  String sectionName;
  String addDateTime;
  Timestamp exDateTime;
  String fileType;
  String fileLink;
  String folderPath;
  String userId;
  ShowFile({
    key,
    required this.fileName,
    required this.fileInfo,
    required this.coName,
    required this.projectName,
    required this.branchName,
    required this.sectionName,
    required this.addDateTime,
    required this.exDateTime,
    required this.fileType,
    required this.fileLink,
    required this.folderPath,
    required this.userId,
  });

  @override
  State<ShowFile> createState() => _ShowFileState();
}

class _ShowFileState extends State<ShowFile> {
  var dateTime;
  var disDateTime;

  late bool notificationOn = true;

  // Check if uer set Notification On or Off in Settings

  Future getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? notifOn = prefs.getBool('notificationOn');
    setState(() {
      notificationOn = notifOn!;
    });
  }

// Set All Notifcation Agen
  Future<Map<String, dynamic>?> getUser() async {
    await AwesomeNotifications().cancelAllSchedules();

    if (notificationOn) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('documents')
          .where('expireDateTime',
              isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          DateTime dates = (doc['expireDateTime'] as Timestamp).toDate();
          DateTime dates2 = dates.subtract(const Duration(days: 7));
          DateTime dates3 = dates2.subtract(const Duration(days: 7));
          DateTime dates4 = dates3.subtract(const Duration(days: 7));
          String Names = doc['docName'];
          String groubKey = doc['folderName'];
          CreateScheduldNotification(' ${translation(context).dateEnd} $Names',
              translation(context).docDateExp, dates, groubKey, '');
          CreateScheduldNotification(
              ' ${translation(context).dateExpCom} $Names',
              translation(context).dateExpComBody,
              dates2,
              groubKey,
              '');
          CreateScheduldNotification(
              ' ${translation(context).dateExpCom} $Names',
              translation(context).dateExpComBody,
              dates3,
              groubKey,
              '');
          CreateScheduldNotification(
              ' ${translation(context).dateExpCom} $Names',
              translation(context).dateExpComBody,
              dates4,
              groubKey,
              '');
        }
      });
      /////////////
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('notes')
          .where('reminderDate',
              isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          DateTime dates = (doc['reminderDate'] as Timestamp).toDate();
          String Names = doc['noteName'];
          String noteText = doc['NoteText'];
          String groubKey = doc['noteKey'];
          CreateScheduldNotification(' ${translation(context).remind} $Names',
              noteText, dates, groubKey, '');
        }
      });
      /////////////
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('tasks')
          .where('reminderDate',
              isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          DateTime dates = (doc['reminderDate'] as Timestamp).toDate();
          String name = doc['name'];
          String taskName = doc['taskName'];
          String groubKey = doc['secretaryKey'];
          String secretaryKey = doc['taskKey'];
          CreateScheduldNotification(
            ' ${translation(context).task} $taskName',
            '${translation(context).to} $name',
            dates,
            groubKey,
            secretaryKey,
          );
        }
      });
    }
    return null;
  }

  void showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        // textDirection: TextDirection.rtl,
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ));
  }

  late bool isSahre = false;
  String filePath = '';
  String fileName = '';
  TextEditingController fileInfoController = TextEditingController();

  // Share File or Docs To Apps
  Future<void> shareFile(String fileUrl) async {
    setState(() {
      isLoadingShare = true;
    });
    try {
      DateTime now = DateTime.now();
      String nowTime = now.toString();
      String nameNow = nowTime
          .split('.')[0]
          .replaceAll('-', '')
          .replaceAll(':', '')
          .replaceAll(' ', '');
      final url = Uri.parse(fileUrl);
      final response = await http.get(url);
      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = widget.fileType == 'pdf'
          ? '${temp.path}/$nameNow.pdf'
          : '${temp.path}/$nameNow';
      print(path);
      File(path).writeAsBytesSync(bytes);
      await Share.shareFiles([path], text: 'Share File').then((value) {
        setState(() {
          isLoadingShare = false;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

// Downloade File Using flutter_downloader: ^1.8.4
  Future download(String fileLink) async {
    DateTime now = DateTime.now();
    String nowTime = now.toString();
    String nameNow = nowTime
        .split('.')[0]
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll(' ', '');
    var status = Permission.storage;
    if (await status.isGranted) {
      if (Platform.isAndroid) {
        final baseStorage = await getExternalStorageDirectory();
        String fName = widget.fileType == 'pdf'
            ? '$nameNow.pdf'
            : widget.fileType == 'Doc'
                ? nameNow
                : '$nameNow.jpg';
        String fPath = baseStorage!.path;
        await FlutterDownloader.enqueue(
          fileName: fName,
          url: fileLink,
          headers: {}, // optional: header send with url (auth token etc)
          savedDir: fPath,
          showNotification:
              true, // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)

          saveInPublicStorage: true,
        );
      } else if (Platform.isIOS) {
        final baseStorage = await getApplicationDocumentsDirectory();
        String fName = widget.fileType == 'pdf'
            ? '$nameNow.pdf'
            : widget.fileType == 'Doc'
                ? nameNow
                : '$nameNow.jpg';
        String fPath = baseStorage.path;
        await FlutterDownloader.enqueue(
          fileName: fName,
          url: fileLink,
          headers: {}, // optional: header send with url (auth token etc)
          savedDir: fPath,
          showNotification:
              true, // show download progress in status bar (for Android)
          openFileFromNotification:
              true, // click on notification to open downloaded file (for Android)

          saveInPublicStorage: true,
        );
      }
    }
  }

  // Ceck if ueer have Whatsapp on Device or not

  Future<bool?> isInstalledWhatsapp() async {
    final val = await WhatsappShare.isInstalled(package: Package.whatsapp);
    print('Whatsapp Business is installed: $val');
    return val;
  }

// Ceck if ueer have Business Whatsapp on Device or not
  Future<bool?> isInstalledBusinessWhatsapp() async {
    final val =
        await WhatsappShare.isInstalled(package: Package.businessWhatsapp);
    print('Whatsapp Business is installed: $val');
    return val;
  }

  // Share File To Whatsapp

  Future<void> shareFileWhatsapp(
      String text, String phoneNumber, List<String> files) async {
    await WhatsappShare.shareFile(
      text: text,
      phone: phoneNumber,
      filePath: files,
    );
  }

  final ReceivePort _port = ReceivePort();

  late bool isLoading = false;
  late bool isLoadingShare = false;
  late bool isLoadingSend = false;
  late bool isDelete = false;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    getNotifications();
    setState(() {
      fileInfoController.text = widget.fileInfo;
      nameController.text = widget.fileName;
    });
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      DownloadTaskStatus status = data[1];
      if (status == DownloadTaskStatus.complete) {
        showSnackBar(translation(context).fileShowinDownLoad, Colors.green);
        setState(() {
          isLoading = false;
        });
      }
      if (status == DownloadTaskStatus.running) {
        // showSnackBar('يتم تحميل الملف', Colors.green);
        setState(() {
          isLoading = true;
        });
      }
      if (status == DownloadTaskStatus.failed) {
        showSnackBar(translation(context).fileNotDownload, Colors.red);
        setState(() {
          isLoading = false;
        });
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  // Send Download Task to downloader_send_port Port

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('offices')
        .orderBy('date', descending: true)
        .snapshots();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final db = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          widget.fileName,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: width,
              // height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xff3191f5).withOpacity(0.5),
                      width: 1,
                    ),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: widget.fileType == 'Image'
                        ? Icon(
                            Icons.image,
                            size: width * 0.20,
                            color: const Color(0xff3191f5),
                          )
                        : widget.fileType == 'pdf'
                            ? Icon(
                                Icons.picture_as_pdf,
                                size: width * 0.20,
                                color: const Color(0xff3191f5),
                              )
                            : Icon(
                                Icons.file_copy,
                                size: width * 0.20,
                                color: const Color(0xff3191f5),
                              ),
                  ),
                  Container(
                    width: width - 80,
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fileName,
                          style: TextStyle(
                            fontSize: width * 0.045,
                          ),
                        ),
                        Row(
                          children: [
                            (widget.exDateTime)
                                    .toDate()
                                    .isBefore(DateTime.now())
                                ? Text(
                                    translation(context).exp,
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Colors.red,
                                    ),
                                  )
                                : Text(
                                    translation(context).noExp,
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Colors.green,
                                    ),
                                  ),
                            Text(
                              translation(context).docSituation,
                              style: TextStyle(
                                fontSize: width * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: width,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xff3191f5).withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  '${widget.coName} > ${widget.projectName} > ${widget.branchName} > ${widget.sectionName}',
                  style: TextStyle(
                    fontSize: width * 0.030,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.fileType == 'Image' || widget.fileType == 'pdf'
                      ? Container(
                          width: width - 20,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff3191f5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xffeeeeee),
                                  blurRadius: 10,
                                  offset: Offset(0, 4)),
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.13)),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              if (widget.fileType == 'pdf') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PdfViewer(
                                      pdfUrl: widget.fileLink,
                                      pdfName: widget.fileName,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowImagesDic(
                                      docName: widget.fileName,
                                      folderName: widget.folderPath,
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              translation(context).showDoc,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 15),
                  !isLoading
                      ? Container(
                          width: width - 20,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff3191f5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xffeeeeee),
                                  blurRadius: 10,
                                  offset: Offset(0, 4)),
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.13)),
                          ),
                          child: MaterialButton(
                            onPressed: () async {
                              if (widget.fileType == 'pdf' ||
                                  widget.fileType == 'Doc') {
                                download(widget.fileLink);
                              } else if (widget.fileType == 'Image') {
                                final FirebaseStorage storage =
                                    FirebaseStorage.instance;
                                late List images = [];
                                try {
                                  final storageRef = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          "${widget.userId}/docs/${widget.folderPath}");
                                  final listResult = await storageRef.listAll();

                                  print(listResult.items);
                                  for (var item in listResult.items) {
                                    String downloadLink = await storage
                                        .ref(item.fullPath)
                                        .getDownloadURL();
                                    download(downloadLink);
                                  }
                                  print(images);
                                } catch (e) {}
                              }
                            },
                            child: Text(
                              translation(context).downloadDoc,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: width - 20,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff3191f5),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0xffeeeeee),
                                  blurRadius: 10,
                                  offset: Offset(0, 4)),
                            ],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.13)),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 15),
                  Container(
                    width: width - 20,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xff3191f5),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xffeeeeee),
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.13)),
                    ),
                    child: isLoadingShare
                        ? const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : MaterialButton(
                            onPressed: () async {
                              setState(() {
                                isLoadingShare = true;
                              });
                              final FirebaseStorage storage =
                                  FirebaseStorage.instance;
                              late List images = [];
                              late List<String> links = [];
                              try {
                                final storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child(
                                        "${widget.userId}/docs/${widget.folderPath}");
                                final listResult = await storageRef.listAll();

                                print(listResult.items);
                                for (var item in listResult.items) {
                                  String downloadLink = await storage
                                      .ref(item.fullPath)
                                      .getDownloadURL();
                                  images.add(downloadLink);
                                }
                              } catch (e) {}
                              for (var link in images) {
                                try {
                                  DateTime now = DateTime.now();
                                  String nowTime = now.toString();
                                  String nameNow = nowTime
                                      .split('.')[0]
                                      .replaceAll('-', '')
                                      .replaceAll(':', '')
                                      .replaceAll(' ', '');
                                  final url = Uri.parse(link);
                                  final response = await http.get(url);
                                  final bytes = response.bodyBytes;
                                  final temp = await getTemporaryDirectory();
                                  final path = widget.fileType == 'pdf'
                                      ? '${temp.path}/$nameNow.pdf'
                                      : widget.fileType == 'Doc'
                                          ? '${temp.path}/$nameNow'
                                          : '${temp.path}/$nameNow.jpg';
                                  print(path);
                                  File(path).writeAsBytesSync(bytes);
                                  links.add(path);
                                } catch (e) {
                                  print(e.toString());
                                }
                              }
                              await Share.shareFiles(links).then((value) {
                                setState(() {
                                  isLoadingShare = false;
                                });
                              });
                              // }
                            },
                            child: Text(
                              translation(context).shareDoc,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: width - 20,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xff3191f5),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xffeeeeee),
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withOpacity(0.13)),
              ),
              child: isLoadingSend
                  ? Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : MaterialButton(
                      onPressed: () async {
                        setState(() {
                          isLoadingSend = true;
                        });
                        final FirebaseStorage storage =
                            FirebaseStorage.instance;
                        late List images = [];
                        late List<String> links = [];
                        bool? val = await WhatsappShare.isInstalled(
                            package: Package.whatsapp);
                        bool? val2 = await WhatsappShare.isInstalled(
                            package: Package.businessWhatsapp);
                        try {
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "${widget.userId}/docs/${widget.folderPath}");
                          final listResult = await storageRef.listAll();

                          print(listResult.items);
                          for (var item in listResult.items) {
                            String downloadLink = await storage
                                .ref(item.fullPath)
                                .getDownloadURL();
                            images.add(downloadLink);
                          }
                        } catch (e) {}
                        for (var link in images) {
                          try {
                            DateTime now = DateTime.now();
                            String nowTime = now.toString();
                            String nameNow = nowTime
                                .split('.')[0]
                                .replaceAll('-', '')
                                .replaceAll(':', '')
                                .replaceAll(' ', '');
                            final url = Uri.parse(link);
                            final response = await http.get(url);
                            final bytes = response.bodyBytes;
                            final temp = await getExternalStorageDirectory();
                            final path = widget.fileType == 'pdf'
                                ? '${temp!.path}/$nameNow.pdf'
                                : widget.fileType == 'Doc'
                                    ? '${temp!.path}/$nameNow'
                                    : '${temp!.path}/$nameNow.jpg';
                            print(path);
                            File(path).writeAsBytesSync(bytes);
                            links.add(path);
                          } catch (e) {
                            print(e.toString());
                          }
                        }
                        setState(() {
                          isLoadingSend = false;
                        });
                        if (val! || val2!) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    width: width,
                                    height: height * 0.50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          translation(context).selecteOffices,
                                          style: TextStyle(
                                            fontSize: width * 0.050,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Expanded(
                                          child: SizedBox(
                                              width: width,
                                              child:
                                                  StreamBuilder<QuerySnapshot>(
                                                      stream: usersStream,
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  QuerySnapshot>
                                                              snapshot) {
                                                        if (snapshot.hasError) {
                                                          return Center(
                                                            child: Text(
                                                                translation(
                                                                        context)
                                                                    .conectError),
                                                          );
                                                        }

                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        }
                                                        if (snapshot
                                                                .data?.size ==
                                                            0) {
                                                          return Center(
                                                              child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(translation(
                                                                      context)
                                                                  .noOfficesAdd),
                                                              TextButton(
                                                                onPressed: () {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return const AddOffices();
                                                                      });
                                                                },
                                                                child: Text(
                                                                  translation(
                                                                          context)
                                                                      .addOffices,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        width *
                                                                            0.040,
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ));
                                                        }
                                                        return ListView(
                                                            children: snapshot
                                                                .data!.docs
                                                                .map((DocumentSnapshot
                                                                    document) {
                                                          Map<String, dynamic>
                                                              data =
                                                              document.data()!
                                                                  as Map<String,
                                                                      dynamic>;
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            child: Container(
                                                              width: width,
                                                              height: 60,
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.2),
                                                              child:
                                                                  MaterialButton(
                                                                onPressed:
                                                                    () async {
                                                                  await shareFileWhatsapp(
                                                                          'file',
                                                                          '${data['phoneNumber']}',
                                                                          links)
                                                                      .then(
                                                                          (value) {
                                                                    Navigator.pop(
                                                                        context);
                                                                  });
                                                                },
                                                                child: Center(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    Icon(
                                                                      Icons
                                                                          .account_balance,
                                                                      color: const Color(
                                                                          0xff3191f5),
                                                                      size: width *
                                                                          0.12,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          data[
                                                                              'officeName'],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                width * 0.040,
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.location_on_sharp,
                                                                              size: width * 0.025,
                                                                              color: Colors.black.withOpacity(0.5),
                                                                            ),
                                                                            Text(
                                                                              data['location'],
                                                                              style: TextStyle(
                                                                                fontSize: width * 0.035,
                                                                                color: Colors.black.withOpacity(0.5),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    // SizedBox(width: 10),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                  ],
                                                                )),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList());
                                                      })),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        } else {
                          showSnackBar(
                              // ignore: use_build_context_synchronously
                              translation(context).noWhatsapp,
                              Colors.red);
                        }
                      },
                      child: Text(
                        translation(context).sendDocToOffices,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 15),
            Container(
              width: width - 20,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xff3191f5),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xffeeeeee),
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withOpacity(0.13)),
              ),
              child: MaterialButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setstate) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              width: width,
                              height: height * 0.40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    translation(context).editDoc,
                                    style: TextStyle(
                                      fontSize: width * 0.050,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: width,
                                      height: height * 0.30,
                                      color: Colors.grey.withOpacity(0.2),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: width - 50,
                                            height: 50,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Color(0xffeeeeee),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4)),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.13)),
                                            ),
                                            child: Center(
                                              child: TextField(
                                                controller: nameController,
                                                textAlign: TextAlign.center,
                                                decoration:
                                                    InputDecoration.collapsed(
                                                        hintText:
                                                            translation(context)
                                                                .docName),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            width: width - 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Color(0xffeeeeee),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4)),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.13)),
                                            ),
                                            child: MaterialButton(
                                                onPressed: () {
                                                  showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now()
                                                        .subtract(
                                                            const Duration(
                                                                days: 720)),
                                                    lastDate: DateTime.now()
                                                        .add(const Duration(
                                                            days: 7200)),
                                                    // cancelText: 'الغاء',
                                                    // confirmText: 'موافق',
                                                    // helpText: 'اختر تاريخ انتهاء المستند',
                                                    // locale: const Locale("ar", "AR"),
                                                    useRootNavigator: true,
                                                  ).then((date) {
                                                    if (date != null) {
                                                      showTimePicker(
                                                        context: context,
                                                        initialTime:
                                                            const TimeOfDay(
                                                                hour: 10,
                                                                minute: 0),
                                                        // cancelText: 'الغاء',
                                                        // confirmText: 'موافق',
                                                        // helpText: 'اختر وقت تنبيه انتهاء المستند',
                                                      ).then((time) {
                                                        if (time != null) {
                                                          print('------');
                                                          print(date.add(
                                                              Duration(
                                                                  hours:
                                                                      time.hour,
                                                                  minutes: time
                                                                      .minute)));
                                                          print(time);
                                                          setState(() {
                                                            dateTime = date.add(
                                                                Duration(
                                                                    hours: time
                                                                        .hour,
                                                                    minutes: time
                                                                        .minute));
                                                            setstate(() {
                                                              setState(() {
                                                                disDateTime =
                                                                    '${dateTime.year}-${dateTime.month}-${dateTime.day}   ${dateTime.hour}:${dateTime.minute}';
                                                              });
                                                            });
                                                          });
                                                        }
                                                      });
                                                    }
                                                  });
                                                },
                                                child: dateTime == null
                                                    ? Text(translation(context)
                                                        .docDateEndExp)
                                                    : Text(
                                                        disDateTime,
                                                      )),
                                          ),
                                          const SizedBox(height: 15),
                                          Container(
                                            width: width - 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: const Color(0xff3191f5),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Color(0xffeeeeee),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 4)),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.black
                                                      .withOpacity(0.13)),
                                            ),
                                            child: MaterialButton(
                                              onPressed: () async {
                                                if (nameController.text == 0) {
                                                  showSnackBar(
                                                      translation(context)
                                                          .wirteFileName,
                                                      Colors.red);
                                                } else {
                                                  if (dateTime != null) {
                                                    final docInfo = {
                                                      'docName':
                                                          nameController.text,
                                                      'expireDateTime':
                                                          dateTime,
                                                    };
                                                    await db
                                                        .collection('users')
                                                        .doc(widget.userId)
                                                        .collection('documents')
                                                        .doc(widget.folderPath)
                                                        .update(docInfo)
                                                        .then((value) {
                                                      showSnackBar(
                                                          translation(context)
                                                              .editDone,
                                                          Colors.green);
                                                      setState(() {
                                                        widget.fileName =
                                                            nameController.text;
                                                      });
                                                      getUser().then((value) =>
                                                          {
                                                            Navigator.pop(
                                                                context)
                                                          });
                                                    });
                                                  } else {
                                                    final docInfo = {
                                                      'docName':
                                                          nameController.text,
                                                    };
                                                    await db
                                                        .collection('users')
                                                        .doc(widget.userId)
                                                        .collection('documents')
                                                        .doc(widget.folderPath)
                                                        .update(docInfo)
                                                        .then((value) {
                                                      showSnackBar(
                                                          translation(context)
                                                              .editDone,
                                                          Colors.green);
                                                      setState(() {
                                                        widget.fileName =
                                                            nameController.text;
                                                      });
                                                      Navigator.pop(context);
                                                    });
                                                  }
                                                }
                                              },
                                              child: Text(
                                                translation(context).edit,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      });
                },
                child: Text(
                  translation(context).edit,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: width - 20,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xff3191f5),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xffeeeeee),
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black.withOpacity(0.13)),
              ),
              child: MaterialButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: width,
                            height: height * 0.40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  translation(context).docInfo,
                                  style: TextStyle(
                                    fontSize: width * 0.050,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: height * 0.30,
                                    color: Colors.grey.withOpacity(0.2),
                                    padding: const EdgeInsets.all(10),
                                    child: TextField(
                                      onChanged: (text) async {
                                        late Map<String, String> fInfo = {
                                          'docInfo': text,
                                        };
                                        await db
                                            .collection('users')
                                            .doc(widget.userId)
                                            .collection('documents')
                                            .doc(widget.folderPath)
                                            .update(fInfo);
                                        setState(() {
                                          widget.fileInfo = text;
                                        });
                                      },
                                      controller: fileInfoController,
                                      maxLines: 10,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration.collapsed(
                                        hintText: translation(context).delete,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
                child: Text(
                  translation(context).docInfo,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            !isDelete
                ? Container(
                    width: width - 20,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xff3191f5),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xffeeeeee),
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.13)),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          isDelete = true;
                        });
                      },
                      child: Text(
                        translation(context).deleteDoc,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: width - 20,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xffeeeeee),
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.13)),
                    ),
                    child: MaterialButton(
                      onPressed: () async {
                        await db
                            .collection('users')
                            .doc(widget.userId)
                            .collection('documents')
                            .doc(widget.folderPath)
                            .delete();
                        final FirebaseStorage storage =
                            FirebaseStorage.instance;
                        try {
                          final storageRef = FirebaseStorage.instance
                              .ref()
                              .child(
                                  "${widget.userId}/docs/${widget.folderPath}");
                          final listResult = await storageRef.listAll();

                          print(listResult.items);
                          for (var item in listResult.items) {
                            await storage
                                .ref(item.fullPath)
                                .delete()
                                .then((value) {
                              Navigator.pop(context);
                            });
                          }
                        } catch (e) {}
                      },
                      child: Text(
                        translation(context).deleteConfirmation,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
