import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mstand/language_constants.dart';

class BlurryDialog extends StatelessWidget {

  String title;
  String content;
  VoidCallback continueCallBack;

  BlurryDialog(this.title, this.content, this.continueCallBack);
  TextStyle textStyle = TextStyle (color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child:  AlertDialog(
          title:  Text(title,style: textStyle,),
          content:  Text(content, style: textStyle,),
          actions: <Widget>[
             TextButton(
              child:  Text(translation(context).delete),
              onPressed: () {
                Navigator.of(context).pop();
                continueCallBack();
              },
            ),
            TextButton(
              child:  Text(translation(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}