import 'package:flutter/material.dart';

class ColourSchemePair {
  final String name; // idk if needed
  final ColourScheme light;
  final ColourScheme dark;
  const ColourSchemePair({required this.name, required this.light, required this.dark});

  static const List<ColourSchemePair> all = [normal, colourBlind];

  static const normal = ColourSchemePair(
    name: 'Normal',
    light: ColourScheme.light,
    dark: ColourScheme.dark,
  );

  static const colourBlind = ColourSchemePair(
    name: 'Colour Blind',
    light: ColourScheme.colourBlindLight,
    dark: ColourScheme.colourBlindDark,
  );

  @override
  int get hashCode => light.hashCode ^ dark.hashCode;

  @override
  bool operator ==(Object? other) => other is ColourSchemePair && other.light == light && other.dark == dark;
}

class ColourScheme {
  final Color correct;
  final Color semiCorrect;
  final Color wrong;
  final Color invalid;
  final Color victory;
  final Color blank;
  final Color gold;
  final Color silver;
  final Color bronze;

  const ColourScheme({
    required this.correct,
    required this.semiCorrect,
    required this.wrong,
    required this.invalid,
    required this.victory,
    required this.blank,
    required this.gold,
    required this.silver,
    required this.bronze,
  });

  static const light = ColourScheme(
    correct: Color(0xFFC3EDC0),
    semiCorrect: Color(0xFFF9E08A),
    wrong: Color(0xFFC8CAD0),
    invalid: Color(0xFFD8464B),
    victory: Color(0xFFA1E1F7),
    blank: Color(0xFFE0E0E0),
    gold: Color(0xFFD4C05F),
    silver: Color(0xFFCECECE),
    bronze: Color(0xFFBEA278),
  );

  static const dark = ColourScheme(
    correct: Color(0xFF349F2D),
    semiCorrect: Color(0xFFAE8809),
    wrong: Color(0xFF252525),
    invalid: Color(0xFFD8464B),
    victory: Color(0xFFA1FFF7),
    blank: Color(0xFF343434),
    gold: Color(0xFFDFF05F),
    silver: Color(0xFFCFFFFE),
    bronze: Color(0xFF00A278),
  );

  static const colourBlindLight = ColourScheme(
    correct: Color(0xFFF89462),
    semiCorrect: Color(0xFF85B4FF),
    wrong: Color(0xFFC8CAD0),
    invalid: Color(0xFFD8464B),
    victory: Color(0xFFA1E1F7),
    blank: Color(0xFFE0E0E0),
    gold: Color(0xFFD4C05F),
    silver: Color(0xFFCECECE),
    bronze: Color(0xFFBEA278),
  );

  static const colourBlindDark = ColourScheme(
    correct: Color(0xFFB13F06),
    semiCorrect: Color(0xFF0056E0),
    wrong: Color(0xFF252525),
    invalid: Color(0xFFD8464B),
    victory: Color(0xFFA1E1F7),
    blank: Color(0xFF343434),
    gold: Color(0xFFD4C05F),
    silver: Color(0xFFCECECE),
    bronze: Color(0xFFBEA278),
  );

  @override
  int get hashCode =>
      correct.hashCode ^
      semiCorrect.hashCode ^
      wrong.hashCode ^
      invalid.hashCode ^
      victory.hashCode ^
      blank.hashCode ^
      gold.hashCode ^
      silver.hashCode ^
      bronze.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! ColourScheme) return false;
    return correct == other.correct &&
        semiCorrect == other.semiCorrect &&
        wrong == other.wrong &&
        invalid == other.invalid &&
        victory == other.victory &&
        blank == other.blank &&
        gold == other.gold &&
        silver == other.silver &&
        bronze == other.bronze;
  }
}

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
