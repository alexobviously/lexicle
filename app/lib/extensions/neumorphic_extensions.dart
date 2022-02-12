import 'package:flutter_neumorphic/flutter_neumorphic.dart';

extension GetMaterialTheme on NeumorphicThemeData {
  ThemeData get materialTheme {
    final color = accentColor;

    if (color is MaterialColor) {
      return ThemeData(
        primarySwatch: color,
        textTheme: textTheme,
        iconTheme: iconTheme,
        scaffoldBackgroundColor: baseColor,
      );
    }

    return ThemeData(
      primaryColor: accentColor,
      accentColor: variantColor,
      iconTheme: iconTheme,
      brightness: ThemeData.estimateBrightnessForColor(baseColor),
      primaryColorBrightness: ThemeData.estimateBrightnessForColor(accentColor),
      accentColorBrightness: ThemeData.estimateBrightnessForColor(variantColor),
      textTheme: textTheme,
      scaffoldBackgroundColor: baseColor,
    );
  }
}
