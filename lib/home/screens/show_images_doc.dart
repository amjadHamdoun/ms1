import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:photo_view/photo_view.dart';

class ShowImagesDic extends StatefulWidget {
  String folderName;
  String docName;
  String userId;
  ShowImagesDic({
    key,
    required this.folderName,
    required this.docName,
    required this.userId,
  });

  @override
  State<ShowImagesDic> createState() => _ShowImagesDicState();
}

class _ShowImagesDicState extends State<ShowImagesDic> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  late List images = [];
  Future imageUrl() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("${widget.userId}/docs/${widget.folderName}");
      final listResult = await storageRef.listAll();
      for (var item in listResult.items) {
        String downloadLink = await storage.ref(item.fullPath).getDownloadURL();
        setState(() {
          images.add(downloadLink);
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    imageUrl();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          widget.docName,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: images.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return FadeInUp(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setstate) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              width: height,
                              height: height * 0.60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: PhotoView(
                                imageProvider: NetworkImage(images[index]),
                                backgroundDecoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0)),
                              ),
                            ),
                          );
                        });
                      });
                },
                child: SizedBox(
                  width: width - 50,
                  child: Image.network(images[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
