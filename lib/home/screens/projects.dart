import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:mstand/home/dialogs/add_project.dart';
import 'package:mstand/home/screens/branches_screen.dart';
import 'package:mstand/home/screens/sections.dart';
import 'package:mstand/language_constants.dart';

import '../dialogs/add_company.dart';

class Projects extends StatefulWidget {
  String companyName;
  String user_id;
  bool has_internet;
  Projects({
    key,
    required this.companyName,
    required this.user_id,
    required this.has_internet,
  });

  @override
  State<Projects> createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    final db = FirebaseFirestore.instance;

    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user_id)
        .collection('companys')
        .doc(widget.companyName)
        .collection('projects')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff3191f5),
        elevation: 0,
        title: Text(
          '${widget.companyName} - ${translation(context).projectAct}',
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddProject(
                  coName: widget.companyName,
                );
              });
        },
        backgroundColor: Color(0xff3191f5),
        tooltip: translation(context).tapAddProject,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(translation(context).conectError));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data?.size == 0) {
            return Center(child: Text(translation(context).noProjectAdd));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.all(5),
                child: SwipeActionCell(
                  key: ValueKey(document),
                  trailingActions: <SwipeAction>[
                    SwipeAction(
                      nestedAction:
                          SwipeNestedAction(title: translation(context).delete),
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: _width * 0.090,
                      ),
                      onTap: (CompletionHandler handler) async {
                        await handler(true);
                        await db
                            .collection('users')
                            .doc(widget.user_id)
                            .collection('companys')
                            .doc(widget.companyName)
                            .collection('projects')
                            .doc(data['projectName'])
                            .delete();

                        final FirebaseStorage storage =
                            FirebaseStorage.instance;

                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user_id)
                            .collection('documents')
                            .where('projectName',
                                isEqualTo: data['projectName'])
                            .where('coName', isEqualTo: widget.companyName)
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          querySnapshot.docs.forEach((doc) async {
                            await db
                                .collection('users')
                                .doc(widget.user_id)
                                .collection('documents')
                                .doc(doc['folderName'])
                                .delete();
                            try {
                              final storageRef = FirebaseStorage.instance
                                  .ref()
                                  .child(
                                      "${widget.user_id}/docs/${doc['folderName']}");
                              final listResult = await storageRef.listAll();

                              print(listResult.items);
                              for (var item in listResult.items) {
                                await storage.ref(item.fullPath).delete();
                              }
                            } catch (e) {}
                          });
                        });
                      },
                      color: Colors.red,
                    ),
                    SwipeAction(
                        onTap: (CompletionHandler handler) async {
                          await handler(false);
                        },
                        color: Colors.red),
                  ],
                  child: Container(
                    width: _width,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    child: MaterialButton(
                      splashColor: Color.fromARGB(57, 49, 144, 245),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BranchesScreen(
                              companyName: data['coName'],
                              projectName: data['projectName'],
                              user_id: widget.user_id,
                              has_internet: widget.has_internet,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          data['ImgUrl'] == 'none'
                              ? Icon(
                                  Icons.design_services_sharp,
                                  size: _width * 0.10,
                                  color: Color(0xff3191f5),
                                )
                              : widget.has_internet
                                  ? Image.network(
                                      data['ImgUrl'],
                                      width: _width * 0.12,
                                    )
                                  : Icon(
                                      Icons.design_services_sharp,
                                      size: _width * 0.10,
                                      color: Color(0xff3191f5),
                                    ),
                          SizedBox(width: 15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['projectName'],
                                style: TextStyle(
                                  fontSize: _width * 0.050,
                                ),
                              ),
                              Text(
                                data['coName'],
                                style: TextStyle(
                                  fontSize: _width * 0.030,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
