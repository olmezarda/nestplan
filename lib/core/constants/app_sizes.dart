import 'package:flutter/material.dart';

class AppSizes {
  // Padding & Margin
  static const double pSmall = 8.0;
  static const double pMedium = 16.0;
  static const double pLarge = 24.0;
  static const double pExtraLarge = 32.0;

  // Border Radius
  static const double rSmall = 8.0;
  static const double rMedium = 16.0;
  static const double rLarge = 24.0;

  // Icon Sizes
  static const double iconSmall = 18.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;

  // Vertical Spacing (Dikey Boşluklar)
  static const SizedBox hBoxLow = SizedBox(height: pSmall);
  static const SizedBox hBoxNormal = SizedBox(height: pMedium);
  static const SizedBox hBoxHigh = SizedBox(height: pLarge);

  // Horizontal Spacing (Yatay Boşluklar)
  static const SizedBox wBoxLow = SizedBox(width: pSmall);
  static const SizedBox wBoxNormal = SizedBox(width: pMedium);
  static const SizedBox wBoxHigh = SizedBox(width: pLarge);
}
