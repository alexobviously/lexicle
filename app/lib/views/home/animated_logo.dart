import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_game/ui/word_row.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({Key? key}) : super(key: key);

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> {
  List<int> correct = [];
  List<int> semi = [];

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 500), (_) => _updateColours());
    super.initState();
  }

  void _updateColours() {
    final r = Random();
    bool remove = correct.length + semi.length > 6;
    bool c = r.nextBool();
    if (remove) {
      if (c && correct.isNotEmpty) {
        correct.removeAt(r.nextInt(correct.length));
      } else if (semi.isNotEmpty) {
        semi.removeAt(r.nextInt(semi.length));
      }
    } else {
      if (c && correct.length < 7) {
        correct.add(r.nextInt(7));
      } else if (semi.length < 7) {
        semi.add(r.nextInt(7));
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool dark = theme.brightness == Brightness.dark;
    return FittedBox(
      child: WordRow(
        length: 7,
        content: 'Lexicle',
        textStyle: textTheme.headline3!.copyWith(
          fontFamily: GoogleFonts.comfortaa().fontFamily,
          fontWeight: FontWeight.w900,
          color: dark ? Colors.grey.shade300 : null,
        ),
        correct: correct,
        semiCorrect: semi,
        finalised: true,
      ),
    );
  }
}
