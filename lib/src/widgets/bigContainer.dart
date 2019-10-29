import 'package:flutter/material.dart';

import '../helper/appConfig.dart';

class BigContainer extends StatelessWidget {
  final Widget child;
  final int height;

  final double blockWidth = AppConfig.blockSizeWidth;
  final double blockHeight = AppConfig.blockSizeHeight;

  BigContainer({this.child, this.height = 85});

  Widget build(context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(blockHeight),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(Radius.circular(7.0))),
        width: blockWidth * 80,
        height: blockHeight * height,
        child: child,
      ),
    );
  }
}
