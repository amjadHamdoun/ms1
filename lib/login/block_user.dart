import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mstand/intro_screen.dart';
import 'package:mstand/language_constants.dart';

class BlockUser extends StatefulWidget {
  const BlockUser({key});

  @override
  State<BlockUser> createState() => _BlockUserState();
}

class _BlockUserState extends State<BlockUser> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BlockScreen(),
    );
  }
}

class BlockScreen extends StatefulWidget {
  const BlockScreen({key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logos/block_user.png'),
            Text(
              translation(context).usrBlock,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: width * 0.070,
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
                autofocus: true,
                onPressed: () async {
                  await FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IntroScreen(),
                      ),
                    );
                  });
                },
                child: Text(
                  translation(context).singOutSub,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: width * 0.040,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
