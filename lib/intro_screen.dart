import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mstand/language_constants.dart';
import 'package:mstand/login/login.dart';
import 'package:country_codes/country_codes.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late String countryCode = 'US';
  Future<String?> GetCountryCode() async {
    await CountryCodes
        .init(); // Optionally, you may provide a `Locale` to get countrie's localizadName

    final CountryDetails details = CountryCodes.detailsForLocale();
    countryCode = details.alpha2Code!;
    return null;
    // print(details.alpha2Code); // Displays alpha2Code, for example US.
    // print(details.dialCode); // Displays the dial code, for example +1.
    // print(details.name); // Displays the extended name, for example United States.
    // print(details.localizedName);
    // print('---------------');
  }

  @override
  void initState() {
    super.initState();
    GetCountryCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          showNextButton: true,
          showSkipButton: true,
          skip: Text(
            translation(context).skip,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          next: const Icon(
            Icons.arrow_forward_outlined,
            color: Colors.blue,
          ),
          pages: [
            PageViewModel(
              title: translation(context).easyProgramMange,
              body: translation(context).mangefilepro,
              image: buildImage('assets/intro_images/intro_img_1.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: translation(context).remindYouDocEx,
              body: translation(context).renotification,
              image: buildImage('assets/intro_images/intro_img_2.png'),
              decoration: getPageDecoration(),
            ),
            PageViewModel(
              title: translation(context).strongAccount,
              body: translation(context).allFileSecure,
              image: buildImage('assets/intro_images/intro_img_4.png'),
              decoration: getPageDecoration(),
            ),
          ],
          done: Text(
            translation(context).enter,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onDone: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget buildImage(String path) => Center(
        child: Image.asset(
      path,
      width: 350,
    ));

PageDecoration getPageDecoration() => const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      bodyTextStyle: TextStyle(fontSize: 20),
      bodyPadding: EdgeInsets.all(15),
      imagePadding: EdgeInsets.all(15),
      pageColor: Colors.white,
    );
