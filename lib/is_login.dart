import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/check_sub.dart';
import 'package:mstand/login/select_lang_screen.dart';

class IsUserLogin extends StatefulWidget {
  const IsUserLogin({Key? key}) : super(key: key);

  @override
  State<IsUserLogin> createState() => _IsUserLoginState();
}

class _IsUserLoginState extends State<IsUserLogin> {
  Future isUserLogin() async {
    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const CheckSub(),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const SelectLang(),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      isUserLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      //   StreamBuilder<User?>(
      //     stream: FirebaseAuth.instance.authStateChanges(),
      //     builder: (context, snapshot) {
      //       if (snapshot.hasData) {
      //         return Home();
      //       } else {
      //         return IntroScreen();
      //       }
      //     },
      //   ),
    );
  }
}
