import 'package:flutter/material.dart';

class AppConfig {
  static double width;
  static double height;
  static double blockSizeWidth;
  static double blockSizeHeight;

  AppConfig(context) {
    AppConfig.width = MediaQuery.of(context).size.width;
    AppConfig.height = MediaQuery.of(context).size.height;
    AppConfig.blockSizeWidth = AppConfig.width / 100;
    AppConfig.blockSizeHeight = AppConfig.height / 100;
  }
}
