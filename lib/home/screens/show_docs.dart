import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mstand/home/screens/calendar_screen.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:mstand/language_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ShowDocScreen extends StatefulWidget {
  String user_id;
  String username;
  ShowDocScreen({
    key,
    required this.user_id,
    required this.username,
  });

  @override
  State<ShowDocScreen> createState() => _ShowDocScreenState();
}

class _ShowDocScreenState extends State<ShowDocScreen> {
  var selctedCompany;
  var selectedProject;
  var selectedBranch;
  var selectedSection;
  bool isSelctedCompany = false;
  bool isSelectedProject = false;
  bool isSelectedBranch = false;
  bool isSelectedSection = false;
  bool hideArchiveFiles = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final db = FirebaseFirestore.instance;

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

    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user_id)
        .collection('documents')
        .where('expireDateTime',
            isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots();

    if (hideArchiveFiles) {
      usersStream = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user_id)
          .collection('documents')
          .snapshots();
    }

    if (isSelctedCompany) {
      if (hideArchiveFiles) {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('coName', isEqualTo: selctedCompany)
            .snapshots();
      } else {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('expireDateTime',
                isGreaterThan: Timestamp.fromDate(DateTime.now()))
            .where('coName', isEqualTo: selctedCompany)
            .snapshots();
      }
    }
    if (isSelectedProject) {
      if (hideArchiveFiles) {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('coName', isEqualTo: selctedCompany)
            .where('projectName', isEqualTo: selectedProject)
            .snapshots();
      } else {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('expireDateTime',
                isGreaterThan: Timestamp.fromDate(DateTime.now()))
            .where('coName', isEqualTo: selctedCompany)
            .where('projectName', isEqualTo: selectedProject)
            .snapshots();
      }
    }
    if (isSelectedBranch) {
      if (hideArchiveFiles) {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('coName', isEqualTo: selctedCompany)
            .where('projectName', isEqualTo: selectedProject)
            .where('branchName', isEqualTo: selectedBranch)
            .snapshots();
      } else {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('expireDateTime',
                isGreaterThan: Timestamp.fromDate(DateTime.now()))
            .where('coName', isEqualTo: selctedCompany)
            .where('projectName', isEqualTo: selectedProject)
            .where('branchName', isEqualTo: selectedBranch)
            .snapshots();
      }
    }
    if (isSelectedSection) {
      if (hideArchiveFiles) {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('coName', isEqualTo: selctedCompany)
            .where('projectName', isEqualTo: selectedProject)
            .where('branchName', isEqualTo: selectedBranch)
            .where('sectionName', isEqualTo: selectedSection)
            .snapshots();
      } else {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
            .where('expireDateTime',
                isGreaterThan: Timestamp.fromDate(DateTime.now()))
            .where('coName', isEqualTo: selctedCompany)
            .where('projectName', isEqualTo: selectedProject)
            .where('branchName', isEqualTo: selectedBranch)
            .where('sectionName', isEqualTo: selectedSection)
            .snapshots();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).allDocs,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
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
                          height: height * 0.60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  translation(context).docFilter,
                                  style: TextStyle(
                                    fontSize: width * 0.045,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.user_id)
                                      .collection('companys')
                                      .snapshots(),
                                  builder: ((context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(
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
                                        child: DropdownButton<dynamic>(
                                          items: const [],
                                          onChanged: (v) {
                                            setState(() {
                                              selctedCompany = v;
                                              selectedProject = null;
                                              selectedBranch = null;
                                              selectedSection = null;
                                            });
                                          },
                                          isExpanded: true,
                                          hint: Text(
                                              translation(context).selectCo),
                                          underline: Container(),
                                          alignment: Alignment.center,
                                        ),
                                      );
                                    } else {
                                      List<DropdownMenuItem> allCompanys = [];
                                      for (int i = 0;
                                          i < snapshot.data!.docs.length;
                                          i++) {
                                        DocumentSnapshot snap =
                                            snapshot.data!.docs[i];
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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Container(
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
                                          child: DropdownButton<dynamic>(
                                            items: allCompanys,
                                            onChanged: (v) {
                                              setstate(() {
                                                selctedCompany = v;
                                                setState(() {
                                                  selctedCompany = v;
                                                  isSelctedCompany = true;
                                                  selectedProject = null;
                                                  selectedBranch = null;
                                                  selectedSection = null;
                                                });
                                              });
                                            },
                                            isExpanded: true,
                                            hint: Text(
                                                translation(context).selectCo),
                                            underline: Container(),
                                            alignment: Alignment.center,
                                            value: selctedCompany,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                                /////////////////////////////////
                                ////////////////////////////////
                                const SizedBox(height: 15),
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
                                      return Container(
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
                                        child: DropdownButton<dynamic>(
                                          items: const [],
                                          onChanged: (v) {
                                            setState(() {
                                              selectedProject = v;
                                              selectedBranch = null;
                                              isSelectedProject = true;
                                              selectedSection = null;
                                            });
                                          },
                                          isExpanded: true,
                                          hint: Text(translation(context)
                                              .selectProject),
                                          underline: Container(),
                                          alignment: Alignment.center,
                                        ),
                                      );
                                    } else {
                                      List<DropdownMenuItem> allCompanys = [];
                                      for (int i = 0;
                                          i < snapshot.data!.docs.length;
                                          i++) {
                                        DocumentSnapshot snap =
                                            snapshot.data!.docs[i];
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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Container(
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
                                          child: DropdownButton<dynamic>(
                                            items: allCompanys,
                                            onChanged: (v) {
                                              setstate(() {
                                                selectedProject = v;
                                                setState(() {
                                                  selectedProject = v;
                                                  isSelectedProject = true;
                                                  selectedBranch = null;
                                                  selectedSection = null;
                                                  print(isSelectedProject);
                                                });
                                              });
                                            },
                                            isExpanded: true,
                                            hint: Text(translation(context)
                                                .selectProject),
                                            underline: Container(),
                                            alignment: Alignment.center,
                                            value: selectedProject,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                                /////////////////////////////////
                                ////////////////////////////////
                                const SizedBox(height: 15),
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
                                      return Container(
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
                                        child: DropdownButton<dynamic>(
                                          items: const [],
                                          onChanged: (v) {
                                            setState(() {
                                              selectedBranch = v;
                                              isSelectedBranch = true;
                                              selectedSection = null;
                                            });
                                          },
                                          isExpanded: true,
                                          hint: Text(translation(context)
                                              .selectBranch),
                                          underline: Container(),
                                          alignment: Alignment.center,
                                        ),
                                      );
                                    } else {
                                      List<DropdownMenuItem> allCompanys = [];
                                      for (int i = 0;
                                          i < snapshot.data!.docs.length;
                                          i++) {
                                        DocumentSnapshot snap =
                                            snapshot.data!.docs[i];
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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Container(
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
                                          child: DropdownButton<dynamic>(
                                            items: allCompanys,
                                            onChanged: (v) {
                                              setstate(() {
                                                selectedBranch = v;
                                                setState(() {
                                                  selectedBranch = v;
                                                  isSelectedBranch = true;
                                                  selectedSection = null;
                                                });
                                              });
                                            },
                                            isExpanded: true,
                                            hint: Text(translation(context)
                                                .selectBranch),
                                            underline: Container(),
                                            alignment: Alignment.center,
                                            value: selectedBranch,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                                /////////////////////////////////
                                ////////////////////////////////
                                const SizedBox(height: 15),
                                StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(widget.user_id)
                                      .collection('companys')
                                      .doc(selctedCompany)
                                      .collection('projects')
                                      .doc(selectedProject)
                                      .collection('branches')
                                      .doc(selectedBranch)
                                      .collection('sections')
                                      .snapshots(),
                                  builder: ((context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container(
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
                                        child: DropdownButton<dynamic>(
                                          items: const [],
                                          onChanged: (v) {
                                            setState(() {
                                              selectedSection = v;
                                              isSelectedSection = true;
                                            });
                                          },
                                          isExpanded: true,
                                          hint: Text(translation(context)
                                              .selectSection),
                                          underline: Container(),
                                          alignment: Alignment.center,
                                        ),
                                      );
                                    } else {
                                      List<DropdownMenuItem> allCompanys = [];
                                      for (int i = 0;
                                          i < snapshot.data!.docs.length;
                                          i++) {
                                        DocumentSnapshot snap =
                                            snapshot.data!.docs[i];
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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Container(
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
                                          child: DropdownButton<dynamic>(
                                            items: allCompanys,
                                            onChanged: (v) {
                                              setstate(() {
                                                selectedSection = v;
                                                setState(() {
                                                  selectedSection = v;
                                                  isSelectedSection = true;
                                                });
                                              });
                                            },
                                            isExpanded: true,
                                            hint: Text(translation(context)
                                                .selectSection),
                                            underline: Container(),
                                            alignment: Alignment.center,
                                            value: selectedSection,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(translation(context).showArchDocs),
                                    Checkbox(
                                        value: hideArchiveFiles,
                                        onChanged: (v) {
                                          setstate(() {
                                            setState(() {
                                              hideArchiveFiles = v!;
                                            });
                                          });
                                        }),
                                  ],
                                ),
                                const SizedBox(height: 5),
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
                                        color: Colors.black.withOpacity(0.13)),
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'تم',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalenderScreen(
                user_id: widget.user_id,
              ),
            ),
          );
        },
        child: const Icon(Icons.calendar_month),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(translation(context).conectError));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.size == 0) {
              return Center(child: Text(translation(context).noDocsAdd));
            }
            return ListView(
              reverse: true,
              shrinkWrap: true,
              primary: true,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: FadeInRight(
                    child: SwipeActionCell(
                      key: ValueKey(document),
                      trailingActions: <SwipeAction>[
                        SwipeAction(
                          nestedAction: SwipeNestedAction(
                              title: translation(context).deleteDoc),
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: width * 0.090,
                          ),
                          onTap: (CompletionHandler handler) async {
                            await handler(true);
                            await db
                                .collection('users')
                                .doc(widget.user_id)
                                .collection('documents')
                                .doc(data['folderName'])
                                .delete();
                            final FirebaseStorage storage =
                                FirebaseStorage.instance;
                            try {
                              final storageRef = FirebaseStorage.instance
                                  .ref()
                                  .child(
                                      "${widget.user_id}/docs/${data['folderName']}");
                              final listResult = await storageRef.listAll();

                              print(listResult.items);
                              for (var item in listResult.items) {
                                await storage.ref(item.fullPath).delete();
                              }
                            } catch (e) {}
                          },
                          color: Colors.red,
                        ),
                        SwipeAction(
                            nestedAction: SwipeNestedAction(
                                title: translation(context).shareDoc),
                            icon: Icon(
                              Icons.share,
                              color: Colors.white,
                              size: width * 0.090,
                            ),
                            onTap: (CompletionHandler handler) async {
                              await handler(false);
                              showSnackBar(
                                  translation(context).docPre, Colors.green);

                              final FirebaseStorage storage =
                                  FirebaseStorage.instance;
                              late List images = [];
                              late List<String> links = [];
                              try {
                                final storageRef = FirebaseStorage.instance
                                    .ref()
                                    .child(
                                        "${widget.user_id}/docs/${data['folderName']}");
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
                                  final path = data['fileType'] == 'pdf'
                                      ? '${temp.path}/$nameNow.pdf'
                                      : data['fileType'] == 'Doc'
                                          ? '${temp.path}/$nameNow'
                                          : '${temp.path}/$nameNow.jpg';
                                  print(path);
                                  File(path).writeAsBytesSync(bytes);
                                  links.add(path);
                                } catch (e) {
                                  print(e.toString());
                                }
                              }
                              await Share.shareFiles(links);
                            },
                            color: Colors.grey),
                      ],
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            child: Container(
                              height: 1000,
                              width: 5,
                              color: (data['expireDateTime'] as Timestamp)
                                      .toDate()
                                      .isBefore(DateTime.now())
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          Container(
                            width: width,
                            // height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: MaterialButton(
                              splashColor:
                                  const Color.fromARGB(57, 49, 144, 245),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowFile(
                                      fileName: data['docName'],
                                      coName: data['coName'],
                                      projectName: data['projectName'],
                                      branchName: data['branchName'],
                                      sectionName: data['sectionName'],
                                      fileInfo: data['docInfo'],
                                      fileType: data['fileType'],
                                      addDateTime:
                                          data['addDateTime'].toString(),
                                      exDateTime: data['expireDateTime'],
                                      folderPath: data['folderName'],
                                      userId: widget.user_id,
                                      fileLink: data['fileType'] == 'Image'
                                          ? 'No'
                                          : data['fileUrl'],
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    data['fileType'] == 'pdf'
                                        ? Icons.picture_as_pdf
                                        : data['fileType'] == 'Image'
                                            ? Icons.image
                                            : Icons.file_copy,
                                    size: width * 0.10,
                                    color: const Color(0xff3191f5),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['docName'],
                                            style: TextStyle(
                                              fontSize: width * 0.050,
                                            ),
                                          ),
                                          Text(
                                            '${data['coName']} > ${data['projectName']}',
                                            style: TextStyle(
                                              fontSize: width * 0.030,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          (intl.DateFormat('yyyy-MM-dd').format(
                                                  (data['addDateTime']
                                                          as Timestamp)
                                                      .toDate()))
                                              .toString(),
                                          style: TextStyle(
                                            color:
                                                Colors.green.withOpacity(0.5),
                                            fontSize: width * 0.030,
                                          ),
                                        ),
                                        Text(
                                          (intl.DateFormat('yyyy-MM-dd').format(
                                                  (data['expireDateTime']
                                                          as Timestamp)
                                                      .toDate()))
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.red.withOpacity(0.5),
                                            fontSize: width * 0.030,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
