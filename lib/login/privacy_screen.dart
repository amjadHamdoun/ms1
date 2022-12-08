import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mstand/language_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String priveceText = '';
  Future getPrivce() async {
    final prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('languageCode');
    FirebaseFirestore.instance
        .collection('app')
        .doc("app_root")
        .get()
        .then((value) {
      setState(() {
        priveceText =
            action == "ar" ? value['privacy_ar'] : value['privacy_en'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getPrivce();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translation(context).privacy,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: width,
          child: Text(priveceText),
        ),
      ),
    );
  }
}
