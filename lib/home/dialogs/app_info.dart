import 'package:flutter/material.dart';
import 'package:mstand/language_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfo extends StatefulWidget {
  const AppInfo({
    key,
  });

  @override
  State<AppInfo> createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  TextEditingController nameController = TextEditingController();

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
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
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
                translation(context).aboutApp,
                style: TextStyle(
                  fontSize: width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                translation(context).mangIt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.045,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                translation(context).forInfoCon,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: width * 0.045,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  print('-=-=');
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((MapEntry<String, String> e) =>
                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'onebe923@gmail.com',
                    query: encodeQueryParameters(<String, String>{
                      'subject': translation(context).busBag,
                    }),
                  );
                  launchUrl(emailLaunchUri);
                },
                child: Text(
                  'onebe923@gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.045,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
