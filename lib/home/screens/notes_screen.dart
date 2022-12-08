import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:intl/intl.dart';
import 'package:mstand/home/dialogs/add_note.dart';
import 'package:mstand/home/screens/show_note.dart';
import 'package:mstand/language_constants.dart';

class NotesScreen extends StatefulWidget {
  String userId;
  NotesScreen({key, required this.userId});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final db = FirebaseFirestore.instance;
    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('notes')
        .orderBy('addDate', descending: true)
        .snapshots();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddNote(
                  userId: widget.userId,
                );
              });
        },
        tooltip: translation(context).newNote,
        child: const Icon(Icons.note_alt),
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
              return Center(child: Text(translation(context).noNoteAdd));
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
                              .collection('notes')
                              .doc(data['noteKey'])
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
                        onLongPress: () async {},
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowNotes(
                                userId: widget.userId,
                                noteName: data['noteName'],
                                noteText: data['NoteText'],
                                noteKey: data['noteKey'],
                                setDate: data['setDate'],
                              ),
                            ),
                          );
                        },
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.note_alt,
                              color: const Color(0xff3191f5),
                              size: width * 0.12,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['noteName'],
                                  style: TextStyle(
                                    fontSize: width * 0.040,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.post_add_rounded,
                                      size: width * 0.040,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    Text(
                                      (DateFormat('yyyy-MM-dd').format(
                                              (data['addDate'] as Timestamp)
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
                            const Expanded(
                              child: SizedBox(width: 5),
                            ),
                          ],
                        )),
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
