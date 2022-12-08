import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mstand/home/dialogs/add_branch.dart';
import 'package:mstand/home/dialogs/add_company.dart';
import 'package:mstand/home/dialogs/add_project.dart';
import 'package:mstand/home/dialogs/add_section.dart';
import 'package:mstand/language_constants.dart';
import 'package:mstand/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animator/flutter_animator.dart';

// Add File Screen

// ignore: must_be_immutable
class AddFileScreen extends StatefulWidget {
  String user_id;
  bool has_internet;
  bool isNotification;
  AddFileScreen({
    key,
    required this.user_id,
    required this.has_internet,
    required this.isNotification,
  });

  @override
  State<AddFileScreen> createState() => _AddFileScreenState();
}

class _AddFileScreenState extends State<AddFileScreen> {
  var selctedCompany;
  var selectedProject;
  var selectedSection;
  var selectedBranch;
  var dateTime;
  var disDateTime;
  PlatformFile? pickedDoc;

  var imageTime = '';
  List<PlatformFile>? pickedFile;
  UploadTask? uploudTask;
  bool hasImage = false;
  String file_Url = '';
  bool isLoading = false;
  String filePath = '';
  bool isSelected = false;
  String fileType = '';
  String fileName = '';

  List<String> allSections = [];

  List<String> _pictures = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController infoController = TextEditingController();

// This Funcation Used To Scan Image Using Camera
  Future scanImage() async {
    List<String> pictures;
    try {
      pictures = await CunningDocumentScanner.getPictures() ?? [];
      if (pictures.isEmpty) {
        setState(() {
          isSelected = false;
        });
      }
      if (!mounted) return;
      setState(() {
        _pictures = pictures;
        isSelected = true;
        fileType = 'Image';
      });
      // ignore: empty_catches
    } catch (exception) {}
  }

// Select Image From File FilePiker
  Future selectImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg'],
        allowMultiple: true,
      );
      if (result == null) {
        setState(() {
          hasImage = false;
          isSelected = false;
        });
      } else {
        hasImage = true;
      }
      if (File(result!.files.first.path!).lengthSync() >= 21000000) {
        showSnackBar(translation(context).filebig, Colors.red);
      } else {
        setState(() {
          pickedFile = result.files;
          if (pickedFile != null) {
            for (int i = 0; i < pickedFile!.length; i++) {
              _pictures.add(pickedFile![i].path ?? '');
            }
          }
          // for(int i = 0; i < pickedFile)
          isSelected = true;
          fileType = 'Image';
        });
      }
    } catch (e) {}
  }

// Select PDF From File - FilePiker
  Future selectPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );
      if (result == null) {
        setState(() {
          isSelected = false;
        });
      } else {
        hasImage = true;
      }
      if (File(result!.files.first.path!).lengthSync() >= 21000000) {
        showSnackBar(translation(context).filebig, Colors.red);
      } else {
        setState(() {
          // pickedFile = result?.files.first;
          pickedDoc = result.files.first;

          filePath = result.files[0].path!;
          fileName = result.files[0].name;
          isSelected = true;
          fileType = 'pdf';
        });
      }
    } catch (e) {}
  }

  // Select Word File or xlsx From File - FilePiker

  Future selectDoc() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'doc', 'xlsx', 'xlsm'],
        allowMultiple: true,
      );
      if (result == null) {
        setState(() {
          isSelected = false;
        });
      } else {
        hasImage = true;
      }

      if (File(result!.files.first.path!).lengthSync() >= 21000000) {
        // ignore: use_build_context_synchronously
        showSnackBar(translation(context).filebig, Colors.red);
      } else {}

      setState(() {
        // pickedFile = result?.files.first;
        pickedDoc = result.files.first;

        filePath = result.files[0].path!;
        fileName = result.files[0].name;
        isSelected = true;
        fileType = 'Doc';
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  // Uploud Image to FirebaseStorage

  Future uploudImages(
      String folderName, String imageName, int imageIndex) async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final filePaht = '${authUser!.phoneNumber}/docs/$folderName/$imageName';
    if (_pictures.isNotEmpty) {
      final file = File(_pictures[imageIndex]);
      final ref = FirebaseStorage.instance.ref().child(filePaht);
      uploudTask = ref.putFile(file);

      final snapshot = await uploudTask!.whenComplete(() {});
      final fileUrl = await snapshot.ref.getDownloadURL();
    } else {
      setState(() {
        isSelected = false;
      });
    }
  }

  // Uploud Pdf or Doc to FirebaseStorage

  Future uploudDoc(String folderName, String fileName) async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final filePaht = '${authUser!.phoneNumber}/docs/$folderName/$fileName';
    if (pickedDoc != null) {
      final file = File(pickedDoc!.path!);
      final ref = FirebaseStorage.instance.ref().child(filePaht);
      uploudTask = ref.putFile(file);

      final snapshot = await uploudTask!.whenComplete(() {});

      final fileUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        file_Url = fileUrl;
      });
    }
  }

  CollectionReference<Map<String, dynamic>> db =
      FirebaseFirestore.instance.collection('users');

  FirebaseAuth auth = FirebaseAuth.instance;

  // Get All Sections From SharedPreferences \ Set im Main File

  void getSections() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> sections = prefs.getStringList('mySections') ?? [];
    setState(() {
      allSections = sections;
    });
  }

  void showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 10),
      ),
    );
  }

  // Show Date and Time Piker

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 720)),
      lastDate: DateTime.now().add(const Duration(days: 7200)),
      // cancelText: 'الغاء',
      // confirmText: 'موافق',
      // helpText: 'اختر تاريخ انتهاء المستند',
      // locale: const Locale("ar", "AR"),
      useRootNavigator: true,
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 10, minute: 0),
          useRootNavigator: false,
          // cancelText: 'الغاء',
          // confirmText: 'موافق',
          // helpText: 'اختر وقت تنبيه انتهاء المستند',
        ).then((time) {
          if (time != null) {
            setState(() {
              dateTime =
                  date.add(Duration(hours: time.hour, minutes: time.minute));
              disDateTime =
                  '${dateTime.year}-${dateTime.month}-${dateTime.day}   ${dateTime.hour}:${dateTime.minute}';
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getSections();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).addDoc,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              fileType == 'Doc'
                  ? Padding(
                      padding: const EdgeInsets.all(5),
                      child: FadeInLeft(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logos/word_logo.png',
                              width: 40,
                            ),
                            Text(
                              fileName,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              fileType == 'pdf'
                  ? Padding(
                      padding: const EdgeInsets.all(5),
                      child: FadeInLeft(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logos/pdf_logo.png',
                              width: 40,
                            ),
                            Text(
                              fileName,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              fileType == 'Image'
                  ? _pictures.isNotEmpty
                      ? FadeInLeft(
                          child: SizedBox(
                            width: width - 50,
                            height: 70,
                            child: ListView.builder(
                              itemCount:
                                  _pictures.isNotEmpty ? _pictures.length : 0,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final item = _pictures[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 70,
                                        child: Image.file(File(item)),
                                      ),
                                      Positioned(
                                        top: -12,
                                        right: -12,
                                        child: IconButton(
                                          splashColor: Colors.red,
                                          onPressed: () {
                                            setState(() {
                                              _pictures.removeAt(index);
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Container()
                  : Container(),
              _pictures.isNotEmpty ? const SizedBox(height: 15) : Container(),
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
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: width - 100,
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
                                            color:
                                                Colors.black.withOpacity(0.13)),
                                      ),
                                      child: MaterialButton(
                                        onPressed: () {
                                          scanImage().then((value) {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(
                                          translation(context).useCamera,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      width: width - 100,
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
                                            color:
                                                Colors.black.withOpacity(0.13)),
                                      ),
                                      child: MaterialButton(
                                        onPressed: () {
                                          selectImage().then((value) {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(
                                          translation(context).selectImage,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      width: width - 100,
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
                                            color:
                                                Colors.black.withOpacity(0.13)),
                                      ),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          selectPdf().then((value) {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(
                                          translation(context).selectPdf,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Container(
                                      width: width - 100,
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
                                            color:
                                                Colors.black.withOpacity(0.13)),
                                      ),
                                      child: MaterialButton(
                                        onPressed: () async {
                                          selectDoc().then((value) {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(
                                          translation(context).selectWord,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  },
                  child: isSelected
                      ? Text(translation(context).docDelected)
                      : Text(translation(context).selectDoc),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: width - 50,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffeeeeee),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.13)),
                ),
                child: Center(
                  child: TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration.collapsed(
                        hintText: translation(context).docName),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: width - 50,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffeeeeee),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.13)),
                ),
                child: Center(
                  child: TextField(
                    controller: infoController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration.collapsed(
                        hintText: translation(context).docInfo),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: width - 50,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffeeeeee),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.13)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddCompany();
                              });
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xff3191f5),
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user_id)
                          .collection('companys')
                          .snapshots(),
                      builder: ((context, snapshot) {
                        if (!snapshot.hasData) {
                          return Expanded(
                            flex: 5,
                            child: DropdownButton<dynamic>(
                              items:  [],
                              onChanged: (value) {
                                setState(() {
                                  selctedCompany = value;
                                });
                              },
                              isExpanded: true,
                              hint: Text(translation(context).selectCo),
                              underline: Container(),
                              alignment: Alignment.center,
                            ),
                          );
                        } else {
                          List<DropdownMenuItem> allCompanys = [];
                          for (int i = 0; i < snapshot.data!.docs.length; i++) {
                            DocumentSnapshot snap = snapshot.data!.docs[i];
                            allCompanys.add(
                              DropdownMenuItem(
                                alignment: Alignment.center,
                                value: snap.id,
                                child: Text(
                                  snap.id,
                                ),
                              ),
                            );
                          }
                          return Expanded(
                            flex: 5,
                            child: DropdownButton<dynamic>(
                              items: allCompanys,
                              onChanged: (v) {
                                setState(() {
                                  selctedCompany = v;
                                });
                              },
                              isExpanded: true,
                              hint: Text(translation(context).selectCo),
                              underline: Container(),
                              alignment: Alignment.center,
                              value: selctedCompany,
                            ),
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),

              ///////////////////////////////
              //////////////////////////////
              const SizedBox(height: 15),
              Container(
                width: width - 50,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffeeeeee),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.13)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          if (selctedCompany != null) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddProject(
                                    coName: selctedCompany,
                                  );
                                });
                          } else {
                            showSnackBar(
                                translation(context).selectCoFirst, Colors.red);
                          }
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xff3191f5),
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user_id)
                          .collection('companys')
                          .doc(selctedCompany)
                          .collection('projects')
                          .snapshots(),
                      builder: ((context, snapshot) {
                        if (!snapshot.hasData) {
                          return Expanded(
                            flex: 5,
                            child: DropdownButton<dynamic>(
                              items: const [],
                              onChanged: (v) {
                                setState(() {
                                  selctedCompany = v;
                                });
                              },
                              isExpanded: true,
                              hint: Text(translation(context).selectProject),
                              underline: Container(),
                              alignment: Alignment.center,
                            ),
                          );
                        } else {
                          List<DropdownMenuItem> allCompanys = [];
                          for (int i = 0; i < snapshot.data!.docs.length; i++) {
                            DocumentSnapshot snap = snapshot.data!.docs[i];
                            allCompanys.add(
                              DropdownMenuItem(
                                alignment: Alignment.center,
                                value: snap.id,
                                child: Text(
                                  snap.id,
                                ),
                              ),
                            );
                          }
                          return Expanded(
                            flex: 5,
                            child: DropdownButton<dynamic>(
                              items: allCompanys,
                              onChanged: (v) {
                                setState(() {
                                  selectedProject = v;
                                });
                              },
                              isExpanded: true,
                              hint: Text(translation(context).selectProject),
                              underline: Container(),
                              alignment: Alignment.center,
                              value: selectedProject,
                            ),
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
              ///////////////////////////////
              //////////////////////////////
              const SizedBox(height: 15),
              Container(
                width: width - 50,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffeeeeee),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.13)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          if (selectedProject != null) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddBranch(
                                    coName: selctedCompany,
                                    projectName: selectedProject,
                                  );
                                });
                          } else {
                            showSnackBar(
                                translation(context).selectProjectFirst,
                                Colors.red);
                          }
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xff3191f5),
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user_id)
                          .collection('companys')
                          .doc(selctedCompany)
                          .collection('projects')
                          .doc(selectedProject)
                          .collection('branches')
                          .snapshots(),
                      builder: ((context, snapshot) {
                        if (!snapshot.hasData) {
                          return Expanded(
                            flex: 5,
                            child: DropdownButton<dynamic>(
                              items: const [],
                              onChanged: (v) {
                                setState(() {
                                  selctedCompany = v;
                                });
                              },
                              isExpanded: true,
                              hint: Text(translation(context).selectBranch),
                              underline: Container(),
                              alignment: Alignment.center,
                            ),
                          );
                        } else {
                          List<DropdownMenuItem> allCompanys = [];
                          for (int i = 0; i < snapshot.data!.docs.length; i++) {
                            DocumentSnapshot snap = snapshot.data!.docs[i];
                            allCompanys.add(
                              DropdownMenuItem(
                                alignment: Alignment.center,
                                value: snap.id,
                                child: Text(
                                  snap.id,
                                ),
                              ),
                            );
                          }
                          return Expanded(
                            flex: 5,
                            child: DropdownButton<dynamic>(
                              items: allCompanys,
                              onChanged: (v) {
                                setState(() {
                                  selectedBranch = v;
                                });
                              },
                              isExpanded: true,
                              hint: Text(translation(context).selectBranch),
                              underline: Container(),
                              alignment: Alignment.center,
                              value: selectedBranch,
                            ),
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
              //////////////////////////////
              /////////////////////////////
              const SizedBox(height: 15),
              Container(
                width: width - 50,
                height: 50,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xffeeeeee),
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.13)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AddSection();
                              }).then((value) {
                            getSections();
                          });
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xff3191f5),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: DropdownButton(
                        items: allSections.map((section) {
                          return DropdownMenuItem(
                            alignment: Alignment.center,
                            value: section,
                            child: Text(section),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedSection = v;
                          });
                        },
                        onTap: () async {
                          getSections();
                        },
                        isExpanded: true,
                        hint: Text(translation(context).selectSection),
                        underline: Container(),
                        alignment: Alignment.center,
                        value: selectedSection,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black.withOpacity(0.13)),
                ),
                child: MaterialButton(
                    onPressed: _showDatePicker,
                    child: dateTime == null
                        ? Text(translation(context).docDateEndExp)
                        : Text(
                            disDateTime,
                          )),
              ),
              const SizedBox(height: 30),
              !isLoading
                  ? Container(
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
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.13)),
                      ),
                      child: MaterialButton(
                        onPressed: () async {
                          if (fileType == '' ||
                              nameController.text.length <= 1 ||
                              selctedCompany == null ||
                              selectedProject == null ||
                              selectedBranch == null ||
                              selectedSection == null ||
                              dateTime == null) {
                            showSnackBar(
                                translation(context).endInfoFirst, Colors.red);
                          } else {
                            if (fileType == 'Image') {
                              if (_pictures.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                DateTime now = DateTime.now();
                                String nowTime = now.toString();
                                String nameNow = nowTime
                                    .split('.')[0]
                                    .replaceAll('-', '_')
                                    .replaceAll(':', '_')
                                    .replaceAll(' ', '_');

                                for (int i = 0; i < _pictures.length; i++) {
                                  uploudImages(nameNow, '${i + 1}_$nameNow', i);
                                }
                                if (widget.isNotification) {
                                  CreateScheduldNotification(
                                      ' ${translation(context).dateEnd} ${nameController.text}',
                                      translation(context).docDateExp,
                                      dateTime,
                                      nameNow,
                                      '');
                                }
                                final docInfo = {
                                  'docName': nameController.text,
                                  'folderName': nameNow,
                                  'docInfo': infoController.text,
                                  'coName': selctedCompany,
                                  'projectName': selectedProject,
                                  'branchName': selectedBranch,
                                  'sectionName': selectedSection,
                                  'addDateTime': DateTime.now(),
                                  'expireDateTime': dateTime,
                                  'fileType': fileType,
                                };
                                final sectionInfo = {
                                  'sectionName': selectedSection,
                                  'date': DateTime.now(),
                                };
                                await db
                                    .doc(widget.user_id)
                                    .collection('companys')
                                    .doc(selctedCompany)
                                    .collection('projects')
                                    .doc(selectedProject)
                                    .collection('branches')
                                    .doc(selectedBranch)
                                    .collection('sections')
                                    .doc(selectedSection)
                                    .set(sectionInfo);
                                await db
                                    .doc(widget.user_id)
                                    .collection('documents')
                                    .doc(nameNow)
                                    .set(docInfo)
                                    .then((value) {
                                  setState(() {
                                    isLoading = false;
                                    showSnackBar(
                                        translation(context).docUploded,
                                        Colors.green);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddFileScreen(
                                          has_internet: widget.has_internet,
                                          user_id: widget.user_id,
                                          isNotification: widget.isNotification,
                                        ),
                                      ),
                                    );
                                  });
                                });
                              }
                            } else if (fileType == 'Doc' || fileType == 'pdf') {
                              setState(() {
                                isLoading = true;
                              });
                              DateTime now = DateTime.now();
                              String nowTime = now.toString();
                              String nameNow = nowTime
                                  .split('.')[0]
                                  .replaceAll('-', '_')
                                  .replaceAll(':', '_')
                                  .replaceAll(' ', '_');
                              if (widget.isNotification) {
                                CreateScheduldNotification(
                                    ' ${translation(context).dateEnd} ${nameController.text}',
                                    translation(context).dateExpComBody,
                                    dateTime,
                                    nameNow,
                                    '');
                              }

                              uploudDoc(nameNow, fileName).then((value) async {
                                final docInfo = {
                                  'docName': nameController.text,
                                  'docInfo': infoController.text,
                                  'folderName': nameNow,
                                  'coName': selctedCompany,
                                  'projectName': selectedProject,
                                  'branchName': selectedBranch,
                                  'sectionName': selectedSection,
                                  'addDateTime': DateTime.now(),
                                  'expireDateTime': dateTime,
                                  'fileType': fileType,
                                  'fileUrl': file_Url,
                                };
                                final sectionInfo = {
                                  'sectionName': selectedSection,
                                  'date': DateTime.now(),
                                };
                                await db
                                    .doc(widget.user_id)
                                    .collection('companys')
                                    .doc(selctedCompany)
                                    .collection('projects')
                                    .doc(selectedProject)
                                    .collection('branches')
                                    .doc(selectedBranch)
                                    .collection('sections')
                                    .doc(selectedSection)
                                    .set(sectionInfo);
                                await db
                                    .doc(widget.user_id)
                                    .collection('documents')
                                    .doc(nameNow)
                                    .set(docInfo)
                                    .then((value) {
                                  setState(() {
                                    isLoading = false;
                                    showSnackBar(
                                        translation(context).docUploded,
                                        Colors.green);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddFileScreen(
                                          has_internet: widget.has_internet,
                                          user_id: widget.user_id,
                                          isNotification: widget.isNotification,
                                        ),
                                      ),
                                    );
                                  });
                                });
                              });
                            }
                          }
                        },
                        child: Text(
                          translation(context).uplodeDoc,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Container(
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
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.13)),
                      ),
                      child: MaterialButton(
                        onPressed: () async {},
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
