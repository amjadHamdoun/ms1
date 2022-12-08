import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:mstand/home/dialogs/add_secretary.dart';
import 'package:mstand/home/screens/calendar_all_screen.dart';
import 'package:mstand/home/screens/show_secretary.dart';
import 'package:mstand/language_constants.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';

class SecretaryScreen extends StatefulWidget {
  String userId;
  String userName;
  SecretaryScreen({
    key,
    required this.userId,
    required this.userName,
  });

  @override
  State<SecretaryScreen> createState() => _SecretaryScreenState();
}

class _SecretaryScreenState extends State<SecretaryScreen> {
  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final db = FirebaseFirestore.instance;
    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('secretarys')
        .orderBy('addDate', descending: true)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).secretary,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: HawkFabMenu(
        icon: AnimatedIcons.menu_arrow,
        hawkFabMenuController: hawkFabMenuController,
        items: [
          HawkFabMenuItem(
            label: translation(context).newSecretary,
            ontap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddSecretary(
                      userId: widget.userId,
                    );
                  });
            },
            icon: const Icon(
              Icons.person_add_alt_rounded,
            ),
            color: Colors.green,
            labelColor: Colors.blue,
          ),
          HawkFabMenuItem(
            label: translation(context).calender,
            ontap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CalenderAllScreen(user_id: widget.userId)),
              );
            },
            icon: const Icon(Icons.calendar_month),
            labelColor: Colors.white,
            labelBackgroundColor: Colors.blue,
          ),
        ],
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
                return Center(child: Text(translation(context).noSecretaryAdd));
              }
              return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
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
                                .collection('secretarys')
                                .doc(data['secretaryKey'])
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowSecretary(
                                  userId: widget.userId,
                                  name: data['secretaryName'],
                                  secretaryKey: data['secretaryKey'],
                                  phoneNumber: data['phoneNumber'],
                                  username: widget.userName,
                                  taskKey: data['secretaryKey'],
                                ),
                              ),
                            );
                          },
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.person,
                                color: const Color(0xff3191f5),
                                size: width * 0.12,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    data['secretaryName'],
                                    style: TextStyle(
                                      fontSize: width * 0.040,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: width * 0.040,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      Text(
                                        data['phoneNumber'],
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
      ),
    );
  }
}
