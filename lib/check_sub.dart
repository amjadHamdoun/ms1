import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/home/home.dart';
import 'package:mstand/login/block_user.dart';
import 'package:mstand/sub_block.dart';

class CheckSub extends StatefulWidget {
  const CheckSub({key});

  @override
  State<CheckSub> createState() => _CheckSubState();
}

class _CheckSubState extends State<CheckSub> {
  static FirebaseAuth auth = FirebaseAuth.instance;

  Future getUser() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.phoneNumber)
        .get()
        .then((value) {
      if (value['isBlock']) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser!.phoneNumber)
            .get()
            .then((value) {
          if ((value['subDate'] as Timestamp)
              .toDate()
              .isBefore(DateTime.now())) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>  const SubBlock(
                  showToast: true,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            );
          }
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BlockUser(),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
