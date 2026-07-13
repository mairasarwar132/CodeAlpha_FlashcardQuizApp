import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const double xSmall = 4;
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double xLarge = 32;

  static const SizedBox verticalSmall = SizedBox(height: small);
  static const SizedBox verticalMedium = SizedBox(height: medium);
  static const SizedBox verticalLarge = SizedBox(height: large);
}
