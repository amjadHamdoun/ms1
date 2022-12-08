import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/language_constants.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCompany extends StatefulWidget {
  const AddCompany({key});

  @override
  State<AddCompany> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  var imageTime = '';
  PlatformFile? pickedFile;
  UploadTask? uploudTask;
  bool hasImage = false;
  String imageUrl = '';
  bool isLoading = false;

  Future selectImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) {
      hasImage = false;
    } else {
      hasImage = true;
    }
    setState(() {
      pickedFile = result?.files.first;
    });
  }

  Future uploudFile(String imageName) async {
    final User? authUser = FirebaseAuth.instance.currentUser;
    final filePaht = '${authUser!.phoneNumber}/companyImages/$imageName.png';
    if (pickedFile != null) {
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref().child(filePaht);
      uploudTask = ref.putFile(file);

      final snapshot = await uploudTask!.whenComplete(() {});

      var imageUrl = await snapshot.ref.getDownloadURL();
      print(imageUrl);
      setState(() {
        imageUrl = imageUrl;
      });
    }
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();

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
                translation(context).addNewCo,
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
                        hintText: translation(context).coName),
                  ),
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
                    controller: numberController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration.collapsed(
                        hintText: translation(context).recordNumber),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              hasImage
                  ? Container(
                      width: width - 100,
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
                        border:
                            Border.all(color: Colors.black.withOpacity(0.13)),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          selectImage();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.file(
                              File(pickedFile!.path!),
                              width: 25,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              translation(context).changePhoto,
                              style: const TextStyle(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      width: width - 100,
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
                        border:
                            Border.all(color: Colors.black.withOpacity(0.13)),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          selectImage();
                        },
                        child: Text(translation(context).addPhotoOpt),
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
                          var detroit = tz.getLocation('Asia/Muscat');
                          var now = tz.TZDateTime.now(detroit);
                          String nowTime = now.toString();
                          String nameNow = nowTime
                              .split('.')[0]
                              .replaceAll('-', '_')
                              .replaceAll(':', '_')
                              .replaceAll(' ', '_');

                          String companyName = nameController.text;
                          String companyNumber = numberController.text;
                          var dateTime1 = DateTime.parse(nowTime.split('.')[0]);
                          final userphone = auth.currentUser?.phoneNumber;

                          if (companyName.length <= 1) {
                            showSnackBar(
                                translation(context).enterCoName, Colors.red);
                          } else if (companyNumber.length <= 1) {
                            showSnackBar(translation(context).enterRecordNimber,
                                Colors.red);
                          } else {
                            setState(() {
                              isLoading = true;
                            });
                            if (pickedFile != null) {
                              uploudFile(nameNow).then((value) async {
                                final companuInfo = {
                                  'CoName': companyName,
                                  'CoNumber': companyNumber,
                                  'date': dateTime1,
                                  'ImgUrl': imageUrl
                                };
                                print(companuInfo);
                                await db
                                    .doc(userphone)
                                    .collection('companys')
                                    .doc(companyName)
                                    .set(companuInfo);
                                Navigator.pop(context);
                                showSnackBar(translation(context).coAddDone,
                                    Colors.green);
                              });
                            } else {
                              uploudFile(nameNow).then((value) async {
                                final companuInfo = {
                                  'CoName': companyName,
                                  'CoNumber': companyNumber,
                                  'date': dateTime1,
                                  'ImgUrl': 'none',
                                };
                                print(companuInfo);

                                await db
                                    .doc(userphone)
                                    .collection('companys')
                                    .doc(companyName)
                                    .set(companuInfo)
                                    .then((value) {
                                  Navigator.pop(context);
                                });

                                showSnackBar(translation(context).coAddDone,
                                    Colors.green);
                              });
                            }
                          }
                        },
                        child: Text(
                          translation(context).addCo,
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
  }
}
