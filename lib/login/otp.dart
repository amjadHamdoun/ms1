import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:mstand/check_sub.dart';
import 'package:mstand/language_constants.dart';
import 'package:mstand/login/name_email.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Otp extends StatefulWidget {
  String number;

  // String verId;

  Otp({Key? key, required this.number}) : super(key: key);

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  String verId = '';

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


  Future<void> verifyPhone(String number) async {
    if (mounted) {
      try {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: number,
          timeout: const Duration(seconds: 120),
          verificationCompleted: (PhoneAuthCredential credential) async {
            showSnackBar(translation(context).loginComplit, Colors.green);
            try {

              Future<bool> isUserExist = isDocExist(widget.number);
              await FirebaseAuth.instance
                  .signInWithCredential(
                PhoneAuthProvider.credential(
                    verificationId: verId, smsCode: credential.smsCode ?? ''),
              )
                  .then((value) async {
                if (value.user != null) {
                  if (await isUserExist) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const CheckSub()),
                        (Route<dynamic> route) => false);
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const NameEmail()),
                        (Route<dynamic> route) => false);
                  }
                }
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    translation(context).codeNotRight,
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (e.code == 'invalid-phone-number') {
              showSnackBar(
                  translation(context).phoneNumberNotRight, Colors.red);
            } else {
              showSnackBar(translation(context).loginFail, Colors.red);
              print('/////////////');
              print(e);
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            showSnackBar(translation(context).otpSent, Colors.green);
            verId = verificationId;
          },
          codeAutoRetrievalTimeout: (String verification) {
            showSnackBar(translation(context).timeOver, Colors.red);
          },
        );
      } catch (e) {}
    }
  }

  Future<bool> isDocExist(String docName) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await FirebaseFirestore.instance.collection('users').doc(docName).get();
    if (document.exists) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

      verifyPhone(widget.number);


  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInRight(
                      child: Image.asset(
                        'assets/login_logo/otp.png',
                        width: width * 8,
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInDown(
                      child: Text(
                        translation(context).enterOtp,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: width * 0.070,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0260A8),
                        ),
                      ),
                    ),
                    FadeInDown(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.040,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            translation(context).otpSendTo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.040,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInLeft(
                      child: Pinput(
                        length: 6,
                        autofocus: true,
                        androidSmsAutofillMethod:
                            AndroidSmsAutofillMethod.smsUserConsentApi,
                        onCompleted: (pinCode) async {
                          try {
                            Future<bool> isUserExist =
                                isDocExist(widget.number);
                            await FirebaseAuth.instance
                                .signInWithCredential(
                              PhoneAuthProvider.credential(
                                  verificationId: verId, smsCode: pinCode),
                            )
                                .then((value) async {
                              if (value.user != null) {
                                if (await isUserExist) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('notificationOn', true);
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const CheckSub()),
                                      (Route<dynamic> route) => false);
                                }
                                else {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const NameEmail()),
                                      (Route<dynamic> route) => false);
                                }
                              }
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  translation(context).codeNotRight,
                                  textDirection: TextDirection.rtl,
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUpBig(
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                          child: Text(
                            translation(context).changePhoneNumber,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: width * 0.040,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xff0260A8),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
