import 'package:flutter/material.dart';

class ScreenSize {
  static late double width;
  static late double height;
  static late double textScale;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;
    textScale = mediaQuery.textScaler.scale(1.0);
  }

  static double wp(double percent) => width * percent / 100;
  static double hp(double percent) => height * percent / 100;
}
