import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mstand/language_constants.dart';

class SearchScreen extends StatefulWidget {
  String user_id;
  SearchScreen({key, required this.user_id});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var selctedCompany;
  var selectedProject;
  var selectedBranch;
  var selectedSection;
  bool isSelctedCompany = false;
  bool isSelectedProject = false;
  bool isSelectedBranch = false;
  bool isSelectedSection = false;
  bool hideArchiveFiles = true;
  TextEditingController serachController = TextEditingController();
  String searchText = '';
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user_id)
        .collection('documents')
        .snapshots();

    if (isSelctedCompany) {
      if (hideArchiveFiles) {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user_id)
            .collection('documents')
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
      }
    }

    return Scaffold(
      floatingActionButton: serachController.text.isEmpty
          ? Container()
          : FloatingActionButton(
              backgroundColor: const Color(0xff3D3D3D),
              child: const Icon(Icons.close),
              onPressed: () {
                serachController.clear();
                setState(() {
                  searchText = '';
                });
              },
            ),
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0),
        elevation: 0,
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Color.fromARGB(255, 0, 0, 0),
            size: 28,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            color: Colors.white,
            icon: const Icon(
              Icons.filter_alt,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 25,
            ),
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
                          height: height * 0.50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  translation(context).filterSearch,
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
                                // SizedBox(height: 5),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [
                                //     Text('اظهار المستندات المؤرشفة'),
                                //     Checkbox(
                                //         value: hideArchiveFiles,
                                //         onChanged: (v) {
                                //           setstate(() {
                                //             setState(() {
                                //               hideArchiveFiles = v!;
                                //             });
                                //           });
                                //         }),
                                //   ],
                                // ),
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
                                        color: Colors.black.withOpacity(0.13)),
                                  ),
                                  child: MaterialButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      translation(context).done,
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
                      );
                    });
                  });
            },
          ),
        ],
        title: TextField(
          controller: serachController,
          textAlign: TextAlign.right,
          autofocus: true,
          keyboardType: TextInputType.name,
          onChanged: (text) {
            setState(() {
              searchText = text;
            });
          },
          decoration: InputDecoration.collapsed(
            hintText: translation(context).searchDoc,
            hintTextDirection: TextDirection.rtl,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: searchText == ''
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.content_paste_search_sharp,
                      size: width * 0.30,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      translation(context).searchDoc,
                      style: TextStyle(
                        fontSize: width * 0.06,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: usersStream.asBroadcastStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(translation(context).conectError));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.size == 0) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: width * 0.30,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            translation(context).noresult,
                            style: TextStyle(
                              fontSize: width * 0.06,
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView(children: [
                    ...snapshot.data!.docs
                        .where((QueryDocumentSnapshot<Object?> element) =>
                            element['docName']
                                .toString()
                                .contains(serachController.text))
                        .map((QueryDocumentSnapshot<Object?> data) {
                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            Container(
                              width: width,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
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
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (intl.DateFormat('yyyy-MM-dd')
                                                    .format((data['addDateTime']
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
                                            (intl.DateFormat('yyyy-MM-dd')
                                                    .format(
                                                        (data['expireDateTime']
                                                                as Timestamp)
                                                            .toDate()))
                                                .toString(),
                                            style: TextStyle(
                                              color:
                                                  Colors.red.withOpacity(0.5),
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
                            Positioned(
                              right: 0,
                              child: Container(
                                height: 70,
                                width: 5,
                                color: (data['expireDateTime'] as Timestamp)
                                        .toDate()
                                        .isBefore(DateTime.now())
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ]);
                }),
      ),
    );
  }
}
