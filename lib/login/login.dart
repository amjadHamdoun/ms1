import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:country_codes/country_codes.dart';
import 'package:mstand/home/home.dart';
import 'package:mstand/language_constants.dart';
import 'package:mstand/login/privacy_screen.dart';

import 'otp.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String countryCode = 'US';
  String verId = '';
  late String phoneCode;
  late String userPhone;
  late String fullUserPhone;

  void GetCountryCode() async {
    await CountryCodes.init();

    final CountryDetails details = CountryCodes.detailsForLocale();
    setState(() {
      countryCode = details.alpha2Code!;
    });
  }

  @override
  void initState() {
    super.initState();
    GetCountryCode();
  }

  Future<void> verifyPhone(String number) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: number,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) {
        showSnackBar(translation(context).loginComplit, Colors.green);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          showSnackBar(translation(context).phoneNumberNotRight, Colors.red);
        } else {
          showSnackBar(translation(context).loginFail, Colors.red);
          print(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        showSnackBar(translation(context).otpSent, Colors.green);
        verId = verificationId;
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Otp(number: number, verId: verId),
        //   ),
        // );
      },
      codeAutoRetrievalTimeout: (String verification) {
        showSnackBar(translation(context).timeOver, Colors.red);
      },
    );
  }

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
                        'assets/login_logo/login.png',
                        width: width * 8,
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInDown(
                      child: Text(
                        translation(context).login,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: width * 0.070,
                          fontWeight: FontWeight.w600,
                          color: const Color(0x000000ff),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
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
                        child: InternationalPhoneNumberInput(
                          initialValue: PhoneNumber(isoCode: countryCode),
                          onInputChanged: (value) {
                            setState(() {
                              countryCode = value.isoCode!;
                              phoneCode = value.dialCode!;
                              userPhone = value.phoneNumber!;
                            });
                          },
                          cursorColor: Colors.black,
                          formatInput: false,
                          textAlign: TextAlign.right,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          ),
                          inputDecoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            border: InputBorder.none,
                            hintText: translation(context).phoneNumber,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUpBig(
                      child: MaterialButton(
                        onPressed: () {
                          // verifyPhone(userPhone);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Otp(number: userPhone),
                            ),
                          );
                        },
                        color: const Color(0xff0260A8),
                        child: SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: Center(
                            child: Text(
                              translation(context).login,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUpBig(
                      child: MaterialButton(
                        onPressed: () {
                          // verifyPhone(userPhone);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                          );
                        },
                        color: const Color(0xff0260A8),
                        child: SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: Center(
                            child: Text(
                              translation(context).skip,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacyScreen(),
                            ),
                          );
                        },
                        child: Text(
                          translation(context).privacy,
                          style: TextStyle(
                            fontSize: width * 0.040,
                            color: const Color(0xff0260A8),
                          ),
                        ))
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
