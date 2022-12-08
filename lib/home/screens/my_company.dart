import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:mstand/home/dialogs/add_company.dart';
import 'package:mstand/home/screens/projects.dart';
import 'package:mstand/language_constants.dart';

// Show Comoanys From FireStore Comoanys collection of User

class MyComoanys extends StatefulWidget {
  String? user_id;
  bool has_internet;
  MyComoanys({key, required this.user_id, required this.has_internet});

  @override
  State<MyComoanys> createState() => _MyComoanysState();
}

class _MyComoanysState extends State<MyComoanys> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    final db = FirebaseFirestore.instance;

    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user_id)
        .collection('companys')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddCompany();
              });
        },
        backgroundColor: Color(0xff3191f5),
        tooltip: translation(context).tapAddCo,
        child: Icon(Icons.add),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).myCos,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
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
            return Center(child: Text(translation(context).noCosAdd));
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
                      nestedAction: SwipeNestedAction(
                          title: translation(context).deleteCo),
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
                            .doc(data['CoName'])
                            .delete();

                        final FirebaseStorage storage =
                            FirebaseStorage.instance;

                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user_id)
                            .collection('documents')
                            .where('coName', isEqualTo: data['CoName'])
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
                            builder: (context) => Projects(
                                companyName: data['CoName'],
                                has_internet: widget.has_internet,
                                user_id: widget.user_id??""),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          data['ImgUrl'] == 'none'
                              ? Icon(
                                  Icons.business_outlined,
                                  size: _width * 0.10,
                                  color: Color(0xff3191f5),
                                )
                              : widget.has_internet
                                  ? Image.network(
                                      data['ImgUrl'],
                                      width: _width * 0.12,
                                    )
                                  : Icon(
                                      Icons.business_outlined,
                                      size: _width * 0.10,
                                      color: Color(0xff3191f5),
                                    ),
                          SizedBox(width: 15),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['CoName'],
                                style: TextStyle(
                                  fontSize: _width * 0.050,
                                ),
                              ),
                              Text(
                                data['CoNumber'],
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
