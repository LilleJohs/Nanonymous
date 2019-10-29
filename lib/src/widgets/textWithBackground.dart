import 'package:flutter/material.dart';

import '../helper/appConfig.dart';

class TextWithBackground extends StatelessWidget {
  final String text;
  final int width;
  final int fontMultiplier;

  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  TextWithBackground({this.text, this.width, this.fontMultiplier});

  Widget build(context) {
    return Container(
      width: blockWidth * width,
      padding: EdgeInsets.all(blockHeight * 2),
      decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(Radius.circular(7.0))),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: blockWidth * fontMultiplier,
          color: Colors.white,
        ),
      ),
    );
  }
}
