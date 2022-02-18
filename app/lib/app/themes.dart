import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: GoogleFonts.dmSansTextTheme(),
);
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: GoogleFonts.dmSansTextTheme().apply(
    bodyColor: Colors.grey[300],
    displayColor: Colors.grey[300],
    decorationColor: Colors.grey[300],
  ),
  backgroundColor: const Color(0xFF252525),
);

NeumorphicThemeData neumorphicLight = NeumorphicThemeData(
  baseColor: const Color(0xFFEEEEEE),
  lightSource: LightSource.topLeft,
  depth: 10,
  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
);

NeumorphicThemeData neumorphicDark = NeumorphicThemeData(
  baseColor: const Color(0xFF252525),
  lightSource: LightSource.topLeft,
  intensity: 0.35,
  buttonStyle: NeumorphicStyle(shape: NeumorphicShape.convex),
  depth: 2,
  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
);
