import 'package:flutter/material.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:mstand/home/screens/show_note.dart';
import 'package:mstand/home/screens/show_secretary.dart';
import 'package:mstand/language_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;

class ShowNotification extends StatefulWidget {
  String userId;
  ShowNotification({
    key,
    required this.userId,
  });

  @override
  State<ShowNotification> createState() => _ShowNotificationState();
}

class _ShowNotificationState extends State<ShowNotification> {
  Future showFileFromNotification(String? folderPath, String userId) async {
    /////////////////////////////////
    ////////////////////////////////
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
              ),
            ),
            (route) => route.isFirst);
      }
      // ignore: invalid_return_type_for_catch_error
    }).catchError((e) => print("error fetching data: $e"));
    /////////////////////////////////
    ////////////////////////////////
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
              ),
            ),
          );
        } catch (e) {}
      }
      // ignore: invalid_return_type_for_catch_error
    }).catchError((e) => print("error fetching data: $e"));
    /////////////////////////////////
    ////////////////////////////////
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
                username: '_',
              ),
            ),
          );
        } catch (e) {
          print(e);
        }
      }
      // ignore: invalid_return_type_for_catch_error
    }).catchError((e) => print("error fetching data: $e"));
    ///////////////////////////////
    //////////////////////////////
  }

  void showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        textDirection: TextDirection.rtl,
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('notification')
        .orderBy('date', descending: true)
        .limit(20)
        .snapshots();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: width,
        height: height * 0.55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  translation(context).notifications,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: Container(
                  width: width,
                  color: Colors.grey.withOpacity(0.2),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: usersStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text(translation(context).conectError));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.data?.size == 0) {
                          return Center(
                              child: Text(translation(context).noNotification));
                        }
                        return ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              width: width,
                              height: 120,
                              color: Colors.grey.withOpacity(0.1),
                              child: MaterialButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: () {
                                  try {
                                    showFileFromNotification(
                                        data['Key'], widget.userId);
                                  } catch (e) {
                                    print(e);
                                  }
                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          (intl.DateFormat('yyyy-MM-dd').format(
                                                  (data['date'] as Timestamp)
                                                      .toDate()))
                                              .toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          data['title'],
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          data['body'],
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList());
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
