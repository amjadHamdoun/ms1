import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/home/dialogs/app_info.dart';
import 'package:mstand/home/dialogs/show_notification.dart';
import 'package:mstand/home/home_list.dart';
import 'package:mstand/home/screens/add_file_screen.dart';
import 'package:mstand/home/screens/alert_dialog.dart';
import 'package:mstand/home/screens/archive_screen.dart';
import 'package:mstand/home/screens/my_company.dart';
import 'package:mstand/home/screens/notes_screen.dart';
import 'package:mstand/home/screens/offices_screen.dart';
import 'package:mstand/home/screens/search_screen.dart';
import 'package:mstand/home/screens/secretary_screen.dart';
import 'package:mstand/home/screens/show_docs.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:mstand/home/screens/show_note.dart';
import 'package:mstand/home/screens/show_secretary.dart';
import 'package:mstand/intro_screen.dart';
import 'package:mstand/language_constants.dart';
import 'package:mstand/main.dart';
import 'package:mstand/sub_block.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../language.dart';
import '../notification.dart';
import 'package:permission_handler/permission_handler.dart';

// Home page of the app

class Home extends StatefulWidget {
  const Home({key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  static FirebaseAuth auth = FirebaseAuth.instance;
  static String userId = '';
  String userName = '';
  bool hasInternet = true;
  String langCode = '';
  late bool notificationOn = true;
  bool isSub = true;
  _showDialog(BuildContext context)
  {

    continueCallBack()  {
    CollectionReference<Map<String, dynamic>> db =
    FirebaseFirestore.instance.collection('users');
    db.doc(userId).delete().whenComplete(() async {
      await auth.currentUser!.delete();
      AwesomeNotifications().actionSink.close();
      AwesomeNotifications().displayedSink.close();
      AwesomeNotifications().cancelAllSchedules();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const IntroScreen(),
        ),
      );
    });
    }
    BlurryDialog  alert = BlurryDialog( translation(context).deleteAccount,
        translation(context).confirmDeleteAccount,
        continueCallBack);


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // get curent language
  Future getLang() async {
    final prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('languageCode');
    final bool? notifOn = prefs.getBool('notificationOn');
    setState(() {
      if (action != null) {
        langCode = action;
      }
      notificationOn = notifOn??true;
    });
  }

  // Check if user subscribe
  Future CheckSub() async {
    if(auth.currentUser!=null)
      {
        final db = FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser!.phoneNumber)
            .get()
            .then((value) {
          setState(() {
            isSub = value['isSub'];
            if (!isSub) {
              Fluttertoast.showToast(
                msg: translation(context).youInFree,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 5,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          });
        });
      }

  }

  // Check if Has Internet
  Future chechInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        hasInternet = true;
      }
    } on SocketException catch (_) {
      print('not connected');
      hasInternet = false;
    }
  }

  static final db = FirebaseFirestore.instance;

  // Set User info in Firebase FireStore

  Future setUserInfo(String userId, String online) async {
    String divce = '';
    final fcmToken = await FirebaseMessaging.instance.getToken();

    final userIdToken =
    FirebaseAuth.instance.currentUser!=null?
    await FirebaseAuth.instance.currentUser!.getIdToken():"";
    final userToken = userIdToken;
    if (Platform.isAndroid) {
      // Divece Type Android Or Ios
      divce = 'Android';
    } else if (Platform.isIOS) {
      divce = "IOS";
    }
    Map<String, Object?> userInfo = {
      "platform": divce,
      "userIdToken": userToken,
      "fcmToken": fcmToken,
      "state": online,
    };
    if(userId.isNotEmpty)
      {
        await db.collection('users').doc(userId).update(userInfo);
      }
  }

  Future<Map<String, dynamic>?> getUser() async {
    userId = (auth.currentUser?.phoneNumber)??"";
    await AwesomeNotifications().cancelAllSchedules();
    if (notificationOn) {
      if(userId.isNotEmpty) {
        FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
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
      }
      if(userId.isNotEmpty)
        {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
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
          /////////////
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
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
        }

    }
    return null;
  }

// get user id is phoneNumber
  Future<String> read(String phoneNumber) async {
    var usrename = '';
    if(userId.isNotEmpty)
      {
        final snapshot =
        await db.collection('users').doc(phoneNumber).get().then((value) {
          usrename = value['name'];
        });
        setState(() {
          userName = usrename;
        });
      }

    // print(data!['name']);
    return usrename;
  }

// Call Notification Funcation
  Future notificationAction(String userId, String user) async {
    AwesomeNotifications().actionStream.listen((notification) async {
      try {
        showFileFromNotification(notification.bigPicture, userId);
      } catch (e) {}
      try {
        showNoteFromNotification(notification.bigPicture, userId);
      } catch (e) {}
      try {
        showTasksFromNotification(notification.bigPicture, userId);
      } catch (e) {
        print(e);
      }

      if (Platform.isIOS) {
        if (notification.channelKey == 'scheduld_channel') {
          AwesomeNotifications().getGlobalBadgeCounter().then((value) {
            AwesomeNotifications().setGlobalBadgeCounter(value - 1);
          });
        }
      }
    });
  }

  Future setPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.storage,
      Permission.location,
      Permission.camera,
    ].request();
  }

// open specific scrren when user tap on Notification From out of app
  Future showFileFromNotification(String? folderPath, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('documents')
        .where('folderName', isEqualTo: folderPath)
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        Map<String, dynamic> Function() documentData =
            event.docs.single.data; //if it is a single document
        print(documentData()['docName']);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => ShowFile(
                      addDateTime: documentData()['addDateTime'].toString(),
                      branchName: documentData()['branchName'],
                      coName: documentData()['coName'],
                      exDateTime: documentData()['expireDateTime'],
                      fileInfo: documentData()['docInfo'],
                      fileLink: documentData()['fileType'] == 'Image'
                          ? 'No'
                          : documentData()['fileUrl'],
                      fileName: documentData()['docName'],
                      fileType: documentData()['fileType'],
                      folderPath: documentData()['folderName'],
                      projectName: documentData()['projectName'],
                      sectionName: documentData()['sectionName'],
                      userId: userId,
                    )),
            (route) => route.isFirst);
      }
      // ignore: invalid_return_type_for_catch_error
    }).catchError((e) => print("error fetching data: $e"));
  }

// open specific scrren when user tap on Notification From app
  Future showNoteFromNotification(String? folderPath, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .where('noteKey', isEqualTo: folderPath)
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        Map<String, dynamic> Function() documentData =
            event.docs.single.data; //if it is a single document
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ShowNotes(
                      noteKey: documentData()['noteKey'],
                      noteName: documentData()['noteName'],
                      noteText: documentData()['NoteText'],
                      setDate: documentData()['setDate'],
                      userId: userId,
                    )),
          );
        } catch (e) {}
      }
      // ignore: invalid_return_type_for_catch_error
    }).catchError((e) => print("error fetching data: $e"));
  }

  Future showTasksFromNotification(String? folderPath, String userId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('secretarys')
        .where('secretaryKey', isEqualTo: folderPath)
        .get()
        .then((event) {
      if (event.docs.isNotEmpty) {
        Map<String, dynamic> Function() documentData =
            event.docs.single.data; //if it is a single document
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ShowSecretary(
                      name: documentData()['secretaryName'],
                      phoneNumber: documentData()['phoneNumber'],
                      secretaryKey: documentData()['secretaryKey'],
                      taskKey: documentData()['secretaryKey'],
                      userId: userId,
                      username: ' ',
                    )),
          );
        } catch (e) {}
      }
      // ignore: invalid_return_type_for_catch_error
    }).catchError((e) => print("error fetching data: $e"));
  }

  //Send Notifcation Info To Firebase

  Future setNotificationToFireStore(String userId) async {
    AwesomeNotifications().displayedStream.listen((notification) {
      DateTime now = DateTime.now();
      String nowTime = now.toString();

      String nameNow = nowTime
          .split('.')[0]
          .replaceAll('-', '_')
          .replaceAll(':', '_')
          .replaceAll(' ', '_');
      String? body = notification.body;
      String? title = notification.title;
      String? groubkey = notification.bigPicture;
      String? summary = notification.summary;
      // String? type = event.;
      Map<String, dynamic> sectionInfo = {
        'title': title,
        'body': body,
        'Key': groubkey,
        'date': DateTime.now(),
        'sum': summary,
      };
      db
          .collection('users')
          .doc(userId)
          .collection('notification')
          .doc(nameNow)
          .set(sectionInfo);
    });
  }

  @override
  void initState() {
    // Call All Funcation
    super.initState();
    CheckSub().then((value) {
      if (!isSub) {}
    });
    WidgetsBinding.instance.addObserver(this);
    getLang();
    getUser().then((value) {
      setState(() {
        read(userId).then((value) {
          setState(() {});
          // setPermission();
          setPermission();
        });
        try {
          setUserInfo(userId, 'online');
          notificationAction(userId, userName);
          setNotificationToFireStore(userId);
        } catch (e) {}
      });

      print(userName);
    });
    chechInternet();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setUserInfo(userId, 'online');
    } else {
      setUserInfo(userId, 'offline');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var selcteLang;

// Change Lang dropdownItems
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "ar", child: Text("العربية")),
      const DropdownMenuItem(value: "en", child: Text("English")),
    ];
    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        endDrawer: Drawer(
          child: ListView(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: width,
                    height: 170,
                    child: Image.asset(
                      'assets/login_logo/bk_drawer.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      crossAxisAlignment: langCode == 'en'
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff3191f5).withOpacity(0),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromARGB(35, 0, 0, 0),
                                  blurRadius: 20,
                                  offset: Offset(0, 4)),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.050,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff3191f5).withOpacity(0),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color.fromARGB(35, 0, 0, 0),
                                  blurRadius: 20,
                                  offset: Offset(0, 4)),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            userId.replaceAll('+', ''),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.050,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 15),
                    SizedBox(
                      width: 150,
                      child: DropdownButton<Language>(
                        icon: const Icon(Icons.language),
                        items: Language.languageList()
                            .map<DropdownMenuItem<Language>>((e) =>
                                DropdownMenuItem<Language>(
                                  value: e,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        e.flag,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                      Text(e.name),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (Language? language) async {
                          if (language != null) {
                            Locale locale =
                                await setLocale(language.languageCode);
                            // ignore: use_build_context_synchronously
                            MyApp.setLocale(context, locale);
                          }
                          setState(() {
                            getLang();
                          });
                        },
                        isExpanded: true,
                        hint: Text(translation(context).changeLang),
                        style: TextStyle(
                          fontSize: width * 0.050,
                          color: Colors.black,
                        ),
                        underline: Container(),
                        alignment: Alignment.center,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Checkbox(
                          value: notificationOn,
                          onChanged: (v) async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('notificationOn', v!);
                            getLang();
                            if (!v) {
                              await AwesomeNotifications().cancelAllSchedules();
                            } else {
                              getUser();
                            }
                          },
                        ),
                        Text(
                          notificationOn
                              ? translation(context).notificationStop
                              : translation(context).notificationStart,
                          style: TextStyle(
                            fontSize: width * 0.050,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          !notificationOn
                              ? Icons.notifications
                              : Icons.notifications_active,
                          size: width * 0.060,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AppInfo();
                            });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            translation(context).aboutApp,
                            style: TextStyle(
                              fontSize: width * 0.050,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.info_outline_rounded,
                            size: width * 0.060,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    isSub
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                translation(context).appActiv,
                                style: TextStyle(
                                  fontSize: width * 0.050,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Image.asset(
                                "assets/logos/premium.png",
                                width: width * 0.08,
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                translation(context).teatTime,
                                style: TextStyle(
                                  fontSize: width * 0.050,
                                  color: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SubBlock(
                                        showToast: false,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  translation(context).active,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.access_time,
                                size: width * 0.08,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              if(userId.isNotEmpty)
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: width,
                        height: 50,
                        color: Colors.red,
                        child: MaterialButton(
                          child: Text(
                            translation(context).deleteAccount,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.040,
                            ),
                          ),
                          onPressed: () async {
                              _showDialog(context);

                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: width,
                        height: 50,
                        color: Colors.red,
                        child: MaterialButton(
                          child: Text(
                            userId.isEmpty?translation(context).login:
                            translation(context).loginOut,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.040,
                            ),
                          ),
                          onPressed: () async {
                            setUserInfo(userId, 'offline')
                                .then((value) async {
                              await FirebaseAuth.instance.signOut();
                            });
                            AwesomeNotifications().actionSink.close();
                            AwesomeNotifications().displayedSink.close();
                            AwesomeNotifications().cancelAllSchedules();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const IntroScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.blue.withOpacity(0),
          elevation: 0,
          leading: Stack(
            children: [
              IconButton(
                color: Colors.white,
                icon: const Icon(
                  Icons.notifications,
                  color: Color.fromARGB(255, 0, 0, 0),
                  size: 28,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ShowNotification(
                          userId: userId,
                        );
                      });
                },
              ),
              Positioned(
                right: 22,
                top: 13,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xff3191f5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              color: Colors.white,
              icon: const Icon(
                Icons.search,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 25,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(user_id: userId),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 25,
              ),
              onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: langCode == "ar"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      translation(context).homepage,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: width * 0.050,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btText: translation(context).addDoc,
                              btIcon: Icons.note_add_rounded,
                              btAction: () {
                                if(userId.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                    msg: "Please login",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                                else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddFileScreen(
                                        user_id: userId,
                                        has_internet: hasInternet,
                                        isNotification: notificationOn,
                                      ),
                                    ),
                                  );
                                }

                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btText: translation(context).companes,
                              btIcon: Icons.business_outlined,
                              btAction: () {
                                if(userId.isEmpty)
                                  {
                                    Fluttertoast.showToast(
                                      msg: "Please login",
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 5,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  }
                                else{
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                builder: (context) => MyComoanys(
                                user_id: userId,
                                has_internet: hasInternet),
                                ),
                                );
                                }

                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btAction: () {
                                if(userId.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                    msg: "Please login",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                                else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SecretaryScreen(
                                        userId: userId,
                                        userName: userName,
                                      ),
                                    ),
                                  );
                                }

                              },
                              btIcon: Icons.person,
                              btText: translation(context).secretary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btAction: () {
                                if(userId.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                    msg: "Please login",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                                else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowDocScreen(
                                        user_id: userId,
                                        username: userName,
                                      ),
                                    ),
                                  );
                                }

                              },
                              btIcon: Icons.folder_copy_sharp,
                              btText: translation(context).mydocument,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btAction: () {
                                if(userId.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                    msg: "Please login",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                                else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotesScreen(
                                        userId: userId,
                                      ),
                                    ),
                                  );
                                }

                              },
                              btIcon: Icons.note_alt,
                              btText: translation(context).notes,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btAction: () {
                                if(userId.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                    msg: "Please login",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                                else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArchiveScreen(
                                        user_id: userId,
                                      ),
                                    ),
                                  );
                                }

                              },
                              btIcon: Icons.archive,
                              btText: translation(context).archives,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btAction: () {
                                if(userId.isEmpty)
                                {
                                  Fluttertoast.showToast(
                                    msg: "Please login",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                                else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OfficesScreen(
                                        userId: userId,
                                      ),
                                    ),
                                  );
                                }


                              },
                              btIcon: Icons.account_balance,
                              btText: translation(context).offices,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: myButton(
                              btAction: () =>
                                  _scaffoldKey.currentState!.openEndDrawer(),
                              btIcon: Icons.settings,
                              btText: translation(context).settings,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: width,
              height: 30,
              color: Colors.white,
              child: Center(
                child: Text(
                  translation(context).lastDoc,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 64, 64, 64),
                    fontSize: width * 0.035,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: HomeList(),
            ),
          ],
        ));
  }
}

class myButton extends StatelessWidget {
  String btText;
  IconData btIcon;
  VoidCallback btAction;

  myButton(
      {key,
      required this.btText,
      required this.btIcon,
      required this.btAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xff3191f5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: MaterialButton(
        onPressed: btAction,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              btText,
              style: const TextStyle(color: Color(0xfffffefe)),
            ),
            Icon(
              btIcon,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
