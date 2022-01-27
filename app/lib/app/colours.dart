import 'package:flutter/material.dart';

// original
// class Colours {
//   static const Color correct = Color(0xFFC8E6C9);
//   static const Color semiCorrect = Color(0xFFFFECB3);
//   static const Color wrong = Color(0xFFBDBDBD);
//   static const Color invalid = Colors.red;
// }

// bright
// class Colours {
//   static const Color correct = Color(0xFFA1EF8B);
//   static const Color semiCorrect = Color(0xFFFFBF00);
//   static const Color wrong = Color(0xFFB2B4BD);
//   static const Color invalid = Color(0xFFBA1200);
// }

// compromise
class Colours {
  static const Color correct = Color(0xFFC3EDC0);
  static const Color semiCorrect = Color(0xFFF9E08A);
  static const Color wrong = Color(0xFFC8CAD0);
  static const Color invalid = Color(0xFFD8464B);
  static const Color victory = Color(0xFFA1E1F7);
  static const Color blank = Color(0xFFE0E0E0);
  static const Color gold = Color(0xFFD4C05F);
  static const Color silver = Color(0xFFCECECE);
  static const Color bronze = Color(0xFFBEA278);
}

extension Lightness on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
