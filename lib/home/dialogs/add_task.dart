import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mstand/language_constants.dart';
import 'package:mstand/notification.dart';
// import 'package:whatsapp_share2/whatsapp_share2.dart';

class AddTask extends StatefulWidget {
  String userId;
  String secretaryKey;
  String phoneNumber;
  String username;
  String name;
  String taskKey;
  AddTask({
    key,
    required this.userId,
    required this.secretaryKey,
    required this.phoneNumber,
    required this.username,
    required this.name,
    required this.taskKey,
  });

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController nameController = TextEditingController();
  bool send = false;

  CollectionReference<Map<String, dynamic>> db =
      FirebaseFirestore.instance.collection('users');

  var dateTime;
  var disDateTime;
  bool setDate = false;

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
                  translation(context).addNewTask,
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
                          hintText: translation(context).theTask),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(translation(context).sendViaWhatsapp),
                    Checkbox(
                        value: send,
                        onChanged: (v) {
                          setstate(() {
                            setState(() {
                              send = v!;
                            });
                          });
                        }),
                  ],
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
                      String taskName = nameController.text;
                      DateTime now = DateTime.now();
                      String nowTime = now.toString();
                      String nameNow = nowTime
                          .split('.')[0]
                          .replaceAll('-', '_')
                          .replaceAll(':', '_')
                          .replaceAll(' ', '_');
                      if (nameController.text.isEmpty) {
                        showSnackBar(
                            translation(context).writeTask, Colors.red);
                      } else {
                        if (setDate) {
                          if (dateTime != null) {
                            final taskInfo = {
                              'taskName': taskName,
                              'date': DateTime.now(),
                              'taskKey': nameNow,
                              'setDate': true,
                              'reminderDate': dateTime,
                              'name': widget.name,
                              'secretaryKey': widget.taskKey,
                              'phoneNumber': widget.phoneNumber,
                            };

                            await db
                                .doc(widget.userId)
                                .collection('tasks')
                                .doc(nameNow)
                                .set(taskInfo)
                                .then((value) async {
                              CreateScheduldNotification(
                                ' ${translation(context).task} ${nameController.text}',
                                '${translation(context).to} ${widget.name}',
                                dateTime,
                                widget.taskKey,
                                nameNow,
                              );
                              if (send) {
                                // await WhatsappShare.share(
                                //   phone: widget.phoneNumber,
                                //   text:
                                //       'من تطبيق حقيبة الاعمال تم اسناد مهمة لك\n المهمة - $taskName - \n من - ${widget.username}',
                                // );
                              }
                              Navigator.pop(context);
                            });
                          }
                        } else {
                          final taskInfo = {
                            'taskName': taskName,
                            'date': DateTime.now(),
                            'taskKey': nameNow,
                            'setDate': false,
                            'name': widget.name,
                            'secretaryKey': widget.taskKey,
                            'phoneNumber': widget.phoneNumber,
                          };

                          await db
                              .doc(widget.userId)
                              .collection('tasks')
                              .doc(nameNow)
                              .set(taskInfo)
                              .then((value) async {
                            if (send) {
                              // await WhatsappShare.share(
                              //   phone: widget.phoneNumber,
                              //   text:
                              //       'من تطبيق حقيبة الاعمال تم اسناد مهمة لك\n المهمة - $taskName - \n من - ${widget.username}',
                              // );
                            }
                            Navigator.pop(context);
                          });
                        }
                      }
                    },
                    child: Text(
                      translation(context).addTask,
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
    });
  }
}
