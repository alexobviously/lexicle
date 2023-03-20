import 'dart:math';

import 'package:flutter/material.dart';
import 'package:word_game/ui/word_row.dart';

class WordRowButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const WordRowButton({required this.text, required this.onTap, super.key});

  @override
  State<WordRowButton> createState() => _WordRowButtonState();
}

class _WordRowButtonState extends State<WordRowButton> with SingleTickerProviderStateMixin {
  late AnimationController ac;
  List<int> semi = [];
  List<int> correct = [];

  @override
  void initState() {
    ac = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
      reverseDuration: Duration(milliseconds: 1000),
    )..addListener(_animateLetters);
    super.initState();
  }

  void _animate(bool a) {
    if (a) {
      ac.forward();
    } else {
      ac.reverse();
    }
  }

  void _animateLetters() {
    setState(() {
      semi = List.generate(min(widget.text.length, ac.value * widget.text.length * 2).round(), (i) => i);
      correct = List.generate((max(0.0, ac.value - 0.5) * widget.text.length * 2).round(), (i) => i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: GestureDetector(
        onTapDown: (_) => _animate(true),
        onTapCancel: () => _animate(false),
        onTapUp: (_) => _animate(false),
        onTap: widget.onTap,
        // onTap: widget.onTap,
        child: WordRow(
          content: widget.text,
          length: widget.text.length,
          semiCorrect: semi,
          correct: correct,
          finalised: true,
          correctOnTop: true,
          animationDuration: Duration(milliseconds: 500),
        ),
      ),
    );
  }
}
