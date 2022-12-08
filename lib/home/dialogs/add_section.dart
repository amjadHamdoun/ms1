import 'package:flutter/material.dart';
import 'package:mstand/language_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddSection extends StatefulWidget {
  const AddSection({
    key,
  });

  @override
  State<AddSection> createState() => _AddSectionState();
}

class _AddSectionState extends State<AddSection> {
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
                translation(context).addNewSection,
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
                        hintText: translation(context).sectionName),
                  ),
                ),
              ),
              const SizedBox(height: 15),
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
                    if (nameController.text.isEmpty) {
                      showSnackBar(
                          translation(context).enterSectionName, Colors.red);
                    } else {
                      final prefs = await SharedPreferences.getInstance();
                      final List<String> sections =
                          prefs.getStringList('mySections') ?? [];
                      sections.add(nameController.text);
                      await prefs
                          .setStringList('mySections', sections)
                          .then((value) {
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Text(
                    translation(context).addSection,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
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
