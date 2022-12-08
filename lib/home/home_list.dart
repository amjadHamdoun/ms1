import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/home/screens/show_file.dart';
import 'package:mstand/language_constants.dart';

// This Screen be at the bottom of the home page

class HomeList extends StatefulWidget {
  const HomeList({key});

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  bool hasData = false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          width: width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: const Items()),
    );
  }
}

class Items extends StatefulWidget {
  const Items({key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  String userId = '';
  bool docuser = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future getUser() async {
    userId = (auth.currentUser?.phoneNumber)??"";
  }

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      setState(() {
        docuser = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get All last Docs
    late Stream<QuerySnapshot>? usersStream;
    if(userId.isNotEmpty)
      {
        usersStream = FirebaseFirestore.instance
            .collection('users')
            .doc(docuser ? userId : 'No')
            .collection('documents')
            .orderBy('addDateTime', descending: true)
            .limit(10)
            .snapshots();
      }

    double width = MediaQuery.of(context).size.width;
    return userId.isNotEmpty? StreamBuilder<QuerySnapshot>(
        stream: usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data?.size == 0) {
            return Center(
              child: GestureDetector(
                onTap: () {
                  print(docuser);
                },
                child: Text(
                  translation(context).notDocAddList,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: width * 0.035,
                  ),
                ),
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: MaterialButton(
                  padding: const EdgeInsets.all(0),
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
                          addDateTime: data['addDateTime'].toString(),
                          exDateTime: data['expireDateTime'],
                          folderPath: data['folderName'],
                          userId: userId,
                          fileLink: data['fileType'] == 'Image'
                              ? 'No'
                              : data['fileUrl'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    width: double.infinity,
                    // height: 70,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                color: Color(0xff3191f5),
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: width - 100,
                                    child: Text(
                                      data['docName'],
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    data['coName'],
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.next_plan,
                            size: 20,
                            color: Color(0xff3191f5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }):
    const SizedBox();
  }
}
