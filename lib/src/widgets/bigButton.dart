import 'package:flutter/material.dart';

import '../helper/appConfig.dart';

class BigButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double blockHeight = AppConfig.blockSizeHeight;
  final double width = AppConfig.blockSizeWidth * 55;
  final double height = AppConfig.blockSizeHeight * 8;
  final double fontSize = AppConfig.blockSizeHeight * 3;

  BigButton({
    this.text,
    this.onPressed,
    this.backgroundColor = Colors.orange,
    this.textColor = Colors.white,
  });

  Widget build(context) {
    return Container(
      margin: EdgeInsets.only(bottom: blockHeight * 2),
      width: width,
      height: height,
      child: RaisedButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        color: backgroundColor,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
