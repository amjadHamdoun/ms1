import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in_right.dart';
import 'package:intl/intl.dart';
import 'package:mstand/home/dialogs/add_offices.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:mstand/language_constants.dart';
// import 'package:whatsapp_share2/whatsapp_share2.dart';

class OfficesScreen extends StatefulWidget {
  String userId;
  OfficesScreen({
    key,
    required this.userId,
  });

  @override
  State<OfficesScreen> createState() => _OfficesScreenState();
}

class _OfficesScreenState extends State<OfficesScreen> {
  SwipeActionController swioeController = SwipeActionController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final db = FirebaseFirestore.instance;
    late Stream<QuerySnapshot> usersStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('offices')
        .orderBy('date', descending: true)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          translation(context).officesDocs,
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
                return const AddOffices();
              });
        },
        child: FadeInRight(child: const Icon(Icons.add)),
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
              return Center(child: Text(translation(context).noOfficesAdd));
            }
            return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return FadeInRight(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: SwipeActionCell(
                    controller: swioeController,
                    key: ValueKey(document),
                    trailingActions: <SwipeAction>[
                      SwipeAction(
                        nestedAction: SwipeNestedAction(
                            title: translation(context).deleteOffices),
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
                              .collection('offices')
                              .doc(data['officeName'])
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
                        onLongPress: () async {
                          // swioeController.openCellAt(index: 4, trailing: false);
                          // await WhatsappShare.share(
                          //   phone: data['phoneNumber'],
                          //   text: '.',
                          // );
                        },
                        onPressed: () {},
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.account_balance,
                              color: const Color(0xff3191f5),
                              size: width * 0.12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['officeName'],
                                  style: TextStyle(
                                    fontSize: width * 0.040,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      data['phoneNumber'],
                                      style: TextStyle(
                                        fontSize: width * 0.035,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                    Icon(
                                      Icons.phone,
                                      size: width * 0.040,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (DateFormat('yyyy-MM-dd').format(
                                            (data['date'] as Timestamp)
                                                .toDate()))
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: width * 0.035,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_sharp,
                                        size: width * 0.040,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      Text(
                                        data['location'],
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
