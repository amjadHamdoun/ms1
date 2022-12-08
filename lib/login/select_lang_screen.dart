import 'package:flutter/material.dart';
import 'package:mstand/intro_screen.dart';

import '../language_constants.dart';
import '../main.dart';

class SelectLang extends StatefulWidget {
  const SelectLang({key});

  @override
  State<SelectLang> createState() => _SelectLangState();
}

class _SelectLangState extends State<SelectLang> {
  String langSelect = 'ar';
  Future setLang(String lang) async {
    Locale locale = await setLocale(lang);
    MyApp.setLocale(context, locale);
  }

  @override
  void initState() {
    super.initState();
    setLang(langSelect);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                SizedBox(
                  width: width,
                  child: Image.asset(
                    'assets/login_logo/select_lang.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: Colors.black.withOpacity(0.1),
                ),
                Center(
                    child: Text(
                  translation(context).busBag,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.11,
                    fontWeight: FontWeight.w900,
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: width,
              color: Colors.grey.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Choose a language',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'الرجاء اختيار اللغة',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: width * 0.07,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: width - 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              Locale locale = await setLocale("ar");
                              MyApp.setLocale(context, locale);
                              setState(() {
                                langSelect = "ar";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: langSelect == 'en'
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 33, 105, 181),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'العربية',
                                  style: TextStyle(
                                    color: langSelect == 'en'
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: width * 0.040,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () async {
                              Locale locale = await setLocale("en");
                              MyApp.setLocale(context, locale);
                              setState(() {
                                langSelect = "en";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: langSelect == 'ar'
                                    ? const Color.fromARGB(255, 255, 255, 255)
                                    : const Color.fromARGB(255, 33, 105, 181),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                    color: langSelect == 'ar'
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: width * 0.040,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IntroScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: width - 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 33, 105, 181),
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          translation(context).next,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.040,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
