import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mstand/language_constants.dart';

class AddBranch extends StatefulWidget {
  String coName;
  String projectName;
  AddBranch({
    key,
    required this.coName,
    required this.projectName,
  });

  @override
  State<AddBranch> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  CollectionReference<Map<String, dynamic>> db =
      FirebaseFirestore.instance.collection('users');

  FirebaseAuth auth = FirebaseAuth.instance;

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
              Text(
                translation(context).addNewBranch,
                style: TextStyle(
                  fontSize: width * 0.045,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: width - 100,
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
                        hintText: translation(context).branchName),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              isLoading
                  ? Container()
                  : Container(
                      width: width - 100,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 14, 174, 92),
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
                          if (nameController.text.isEmpty) {
                            showSnackBar(translation(context).enterBranchName,
                                Colors.red);
                          } else {
                            setState(() {
                              isLoading = true;
                            });
                            String branchtName = nameController.text;
                            final userphone = auth.currentUser?.phoneNumber;

                            final branchInfo = {
                              'branchName': branchtName,
                              'date': DateTime.now(),
                              'coName': widget.coName,
                              'projectName': widget.projectName,
                            };

                            await db
                                .doc(userphone)
                                .collection('companys')
                                .doc(widget.coName)
                                .collection('projects')
                                .doc(widget.projectName)
                                .collection('branches')
                                .doc(branchtName)
                                .set(branchInfo)
                                .then((value) {
                              Navigator.pop(context);
                            });
                          }
                        },
                        child: Text(
                          translation(context).addBranch,
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
  }
}
