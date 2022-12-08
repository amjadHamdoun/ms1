import 'package:flutter/material.dart';
import 'package:mstand/language_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../notification.dart';

class AddNote extends StatefulWidget {
  String userId;
  AddNote({key, required this.userId});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  var imageTime = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController textController = TextEditingController();

  CollectionReference<Map<String, dynamic>> db =
      FirebaseFirestore.instance.collection('users');

  var dateTime;
  var disDateTime;
  bool setDate = false;

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

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7200)),
      useRootNavigator: true,
    ).then((date) {
      if (date != null) {
        showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 10, minute: 0),
        ).then((time) {
          if (time != null) {
            print('------');
            print(date.add(Duration(hours: time.hour, minutes: time.minute)));
            print(time);
            setState(() {
              dateTime =
                  date.add(Duration(hours: time.hour, minutes: time.minute));
              disDateTime =
                  '${dateTime.year}-${dateTime.month}-${dateTime.day}   ${dateTime.hour}:${dateTime.minute}';
            });
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
                  translation(context).addNewNote,
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
                          hintText: translation(context).noteName),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: width - 100,
                  height: 120,
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
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      controller: textController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration.collapsed(
                        hintText: translation(context).writeHer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                setDate
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(translation(context).remindme),
                          Checkbox(
                              value: setDate,
                              onChanged: (v) {
                                setstate(() {
                                  setState(() {
                                    setDate = v!;
                                  });
                                });
                              }),
                        ],
                      ),
                setDate
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
                            onPressed: _showDatePicker,
                            onLongPress: () {
                              setstate(() {
                                setState(() {
                                  setDate = false;
                                });
                              });
                            },
                            child: dateTime == null
                                ? Text(translation(context).remindDate)
                                : Text(
                                    disDateTime,
                                  )),
                      )
                    : Container(),
                const SizedBox(height: 15),
                Container(
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
                    border: Border.all(color: Colors.black.withOpacity(0.13)),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      String nowTime = now.toString();
                      String nameNow = nowTime
                          .split('.')[0]
                          .replaceAll('-', '_')
                          .replaceAll(':', '_')
                          .replaceAll(' ', '_');
                      if (nameController.text.isEmpty) {
                        showSnackBar(
                            translation(context).enterNoteName, Colors.red);
                      } else if (textController.text.isEmpty) {
                        showSnackBar(
                            translation(context).enterNoteText, Colors.red);
                      } else {
                        if (setDate) {
                          if (dateTime != null) {
                            final companuInfo = {
                              'noteName': nameController.text,
                              'NoteText': textController.text,
                              'reminderDate': dateTime,
                              'setDate': true,
                              'addDate': DateTime.now(),
                              'noteKey': nameNow,
                            };
                            await db
                                .doc(widget.userId)
                                .collection('notes')
                                .doc(nameNow)
                                .set(companuInfo)
                                .then((value) {
                              CreateScheduldNotification(
                                ' ${translation(context).remind} ${nameController.text}',
                                textController.text,
                                dateTime,
                                nameNow,
                                nameNow,
                              );
                              Navigator.pop(context);
                            });
                          }
                        } else {
                          final companuInfo = {
                            'noteName': nameController.text,
                            'NoteText': textController.text,
                            'setDate': false,
                            'addDate': DateTime.now(),
                            'noteKey': nameNow,
                          };
                          await db
                              .doc(widget.userId)
                              .collection('notes')
                              .doc(nameNow)
                              .set(companuInfo)
                              .then((value) {
                            Navigator.pop(context);
                          });
                        }
                      }
                    },
                    child: Text(
                      translation(context).addNote,
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
  }
}
