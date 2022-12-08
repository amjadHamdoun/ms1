import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mstand/language_constants.dart';

class ShowNotes extends StatefulWidget {
  String userId;
  String noteName;
  String noteText;
  String noteKey;
  bool setDate;
  ShowNotes({
    key,
    required this.userId,
    required this.noteName,
    required this.noteText,
    required this.noteKey,
    required this.setDate,
  });

  @override
  State<ShowNotes> createState() => _ShowNotesState();
}

class _ShowNotesState extends State<ShowNotes> {
  TextEditingController nameController = TextEditingController();
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      nameController.text = widget.noteName;
      textController.text = widget.noteText;
    });
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    CollectionReference<Map<String, dynamic>> db =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).notes,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: width,
            height: 60,
            color: Colors.grey.withOpacity(0.2),
            child: Center(
              child: TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration.collapsed(
                    hintText: translation(context).noteName),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              width: width,
              // color: Colors.grey,
              child: TextField(
                maxLines: 10,
                textAlign: TextAlign.right,
                controller: textController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: width,
            height: 50,
            color: const Color(0xff3191f5),
            child: MaterialButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) {
                    showSnackBar(
                        translation(context).writeNoteName, Colors.red);
                  } else if (textController.text.isEmpty) {
                    showSnackBar(
                        translation(context).writeTextNote, Colors.red);
                  } else {
                    final noteInfo = {
                      'noteName': nameController.text,
                      'NoteText': textController.text,
                    };
                    await db
                        .doc(widget.userId)
                        .collection('notes')
                        .doc(widget.noteKey)
                        .update(noteInfo)
                        .then((value) {
                      showSnackBar(translation(context).editDone, Colors.green);
                    });
                  }
                },
                child: Text(
                  translation(context).edit,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.040,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
