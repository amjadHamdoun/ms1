import 'package:country_codes/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mstand/language_constants.dart';

class AddSecretary extends StatefulWidget {
  String userId;
  AddSecretary({key, required this.userId});

  @override
  State<AddSecretary> createState() => _AddSecretaryState();
}

class _AddSecretaryState extends State<AddSecretary> {
  var imageTime = '';

  TextEditingController nameController = TextEditingController();
  TextEditingController textController = TextEditingController();

  CollectionReference<Map<String, dynamic>> db =
      FirebaseFirestore.instance.collection('users');

  String countryCode = 'US';
  late String phoneCode;
  late String userPhone = '';

  void GetCountryCode() async {
    await CountryCodes.init();

    final CountryDetails details = CountryCodes.detailsForLocale();
    setState(() {
      countryCode = details.alpha2Code!;
    });
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
  void initState() {
    super.initState();
    GetCountryCode();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return StatefulBuilder(builder: (context, setstate) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          width: width,
          height: height * 0.40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translation(context).addNewSecretary,
                  style: TextStyle(
                    fontSize: width * 0.045,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: width - 100,
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xffeeeeee),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black.withOpacity(0.13)),
                  ),
                  child: Center(
                    child: TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration.collapsed(
                          hintText: translation(context).sercertaryName),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: width - 100,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xffeeeeee),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black.withOpacity(0.13)),
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
                const SizedBox(height: 15),
                Container(
                  width: width - 100,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 14, 174, 92),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xffeeeeee),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black.withOpacity(0.13)),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      String nowTime = now.toString();
                      String nameNow = nowTime
                          .split('.')[0]
                          .replaceAll('-', '_')
                          .replaceAll(':', '_')
                          .replaceAll(' ', '_');
                      if (nameController.text.isEmpty) {
                        showSnackBar(translation(context).enterSecretaryName,
                            Colors.red);
                      } else {
                        final companuInfo = {
                          'secretaryName': nameController.text,
                          'addDate': DateTime.now(),
                          'secretaryKey': nameNow,
                          'phoneNumber': userPhone.replaceAll('+', ''),
                        };
                        await db
                            .doc(widget.userId)
                            .collection('secretarys')
                            .doc(nameNow)
                            .set(companuInfo)
                            .then((value) {
                          Navigator.pop(context);
                        });
                      }
                    },
                    child: Text(
                      translation(context).addSecretary,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
