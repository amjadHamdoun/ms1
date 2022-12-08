import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mstand/home/dialogs/add_task.dart';
import 'package:mstand/language_constants.dart';
// import 'package:whatsapp_share2/whatsapp_share2.dart';

class ShowSecretary extends StatefulWidget {
  String userId;
  String name;
  String secretaryKey;
  String phoneNumber;
  String username;
  String taskKey;
  ShowSecretary({
    key,
    required this.userId,
    required this.name,
    required this.secretaryKey,
    required this.phoneNumber,
    required this.username,
    required this.taskKey,
  });

  @override
  State<ShowSecretary> createState() => _ShowSecretaryState();
}

class _ShowSecretaryState extends State<ShowSecretary> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final db = FirebaseFirestore.instance;
    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('tasks')
        .where('secretaryKey', isEqualTo: widget.secretaryKey)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          widget.name,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddTask(
                  userId: widget.userId,
                  secretaryKey: widget.secretaryKey,
                  phoneNumber: widget.phoneNumber,
                  username: widget.username,
                  name: widget.name,
                  taskKey: widget.taskKey,
                );
              });
        },
        tooltip: translation(context).newTask,
        child: const Icon(Icons.add_task_rounded),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(translation(context).conectError));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.size == 0) {
              return Center(child: Text(translation(context).noTaskAdd));
            }
            return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return FadeInRight(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: SwipeActionCell(
                    key: ValueKey(document),
                    trailingActions: <SwipeAction>[
                      SwipeAction(
                        nestedAction: SwipeNestedAction(
                            title: translation(context).delete),
                        // title: "删除",
                        icon: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: width * 0.090,
                        ),
                        onTap: (CompletionHandler handler) async {
                          await handler(true);
                          await db
                              .collection('users')
                              .doc(widget.userId)
                              .collection('tasks')
                              .doc(data['taskKey'])
                              .delete();
                        },
                        color: Colors.red,
                      ),
                      SwipeAction(
                          onTap: (CompletionHandler handler) async {},
                          color: Colors.red),
                    ],
                    child: Container(
                      width: width,
                      height: 70,
                      color: Colors.grey.withOpacity(0.2),
                      child: MaterialButton(
                        onPressed: () async {
                          // await WhatsappShare.share(
                          //   phone: widget.phoneNumber,
                          //   text:
                          //       '${translation(context).taskForYou} - ${data['taskName']} - \n ',
                          // );
                        },
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['taskName'],
                                style: TextStyle(
                                  fontSize: width * 0.040,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.date_range,
                                    size: width * 0.040,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  Text(
                                    (intl.DateFormat('yyyy-MM-dd').format(
                                            (data['date'] as Timestamp)
                                                .toDate()))
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList());
          }),
    );
  }
}
