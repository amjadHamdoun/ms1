import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:country_codes/country_codes.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:mstand/home/home.dart';
import 'package:mstand/language_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NameEmail extends StatefulWidget {
  const NameEmail({Key? key}) : super(key: key);

  @override
  State<NameEmail> createState() => _NameEmailState();
}

class _NameEmailState extends State<NameEmail> {
  String countryName = '';
  String userPhone = '';

  FirebaseAuth auth = FirebaseAuth.instance;

  void GetCountryCode() async {
    await CountryCodes.init();

    final CountryDetails details = CountryCodes.detailsForLocale();
    setState(() {
      countryName = details.localizedName!;
    });
  }

  void getUserPhone() async {
    try {
      userPhone = (auth.currentUser?.phoneNumber)!;
    } catch (e) {
      print(e);
    }
  }

  void showSnackBar(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        textDirection: TextDirection.rtl,
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
    ));
  }

  Future<void> setup() async {
    final detroit = tz.getLocation('America/Detroit');
  }

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GetCountryCode();
    getUserPhone();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    CollectionReference<Map<String, dynamic>> db =
        FirebaseFirestore.instance.collection('users');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInRight(
                      child: Text(
                        translation(context).enterYourInfo,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: width * 0.070,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff0260A8),
                        ),
                      ),
                    ),
                    FadeInLeft(
                      child: Image.asset('assets/login_logo/male_avatar.png',
                          width: width * 0.60),
                    ),
                    const SizedBox(height: 30),
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 0),
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
                        child: TextField(
                          controller: nameController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            hintText: translation(context).name,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 0),
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
                        child: TextField(
                          controller: emailController,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: translation(context).email,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUpBig(
                      child: MaterialButton(
                        onPressed: () async {
                          String name = nameController.text;
                          String email = emailController.text;
                          final bool isValid = EmailValidator.validate(email);
                          final user = {
                            'all': '$name $email $userPhone',
                            'name': name,
                            'email': email,
                            'phone': userPhone,
                            'country': countryName,
                            'isSub': false,
                            'isBlock': true,
                            'enterDate': DateTime.now(),
                            'subDate': DateTime.now().add(
                              const Duration(days: 7),
                            ),
                          };
                          if (email.isEmpty) {
                            showSnackBar(
                                translation(context).entrEmail, Colors.red);
                          } else if (!isValid) {
                            showSnackBar(translation(context).entrEmailRight,
                                Colors.red);
                          } else if (name.isEmpty) {
                            showSnackBar(
                                translation(context).entrName, Colors.red);
                          } else if (name.length <= 3) {
                            showSnackBar(
                                translation(context).nameMustFour, Colors.red);
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('notificationOn', true);
                            await db.doc(userPhone).set(user).whenComplete(() {
                              showSnackBar(
                                  translation(context).yourAcoountCreated,
                                  Colors.green);
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const Home()));
                            });
                          }
                          print(user);
                          // await db.doc(userPhone).set(user);
                        },
                        color: const Color(0xff0260A8),
                        child: SizedBox(
                          width: double.infinity,
                          height: height * 0.065,
                          child: Center(
                            child: Text(
                              translation(context).save,
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
                    const SizedBox(height: 50),
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
