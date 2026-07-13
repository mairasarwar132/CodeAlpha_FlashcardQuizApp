import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;

  static const BorderRadius smallBorderRadius = BorderRadius.all(
    Radius.circular(small),
  );
  static const BorderRadius mediumBorderRadius = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius largeBorderRadius = BorderRadius.all(
    Radius.circular(large),
  );
}
