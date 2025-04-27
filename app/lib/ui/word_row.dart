import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/scheme_cubit.dart';

class WordRow extends StatelessWidget {
  final int length;
  final String content;
  final List<int> correct;
  final List<int> semiCorrect;
  final List<int> wrong;
  final bool finalised;
  final bool valid;
  final Color? borderColour;
  final double? borderWidth;
  final double surfaceIntensity;
  final TextStyle? textStyle;
  final bool correctOnTop;
  final Duration? animationDuration;
  final VoidCallback? onLongPress;

  const WordRow({
    super.key,
    required this.length,
    this.content = '',
    this.correct = const [],
    this.semiCorrect = const [],
    this.wrong = const [],
    this.finalised = false,
    this.valid = true,
    this.borderColour,
    this.borderWidth,
    this.surfaceIntensity = 0.25,
    this.textStyle,
    this.correctOnTop = false,
    this.animationDuration,
    this.onLongPress,
  }) : assert(content.length <= length);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchemeCubit, ColourScheme>(
      builder: (context, scheme) {
        List<String> _letters = content.split('')..addAll(List.filled(length - content.length, ''));
        List<LetterData> _letterData = [];
        for (int i = 0; i < length; i++) {
          Color c = scheme.blank;
          if (finalised) {
            if (semiCorrect.contains(i) && (!correctOnTop || !correct.contains(i))) {
              c = scheme.semiCorrect;
            } else if (correct.contains(i)) {
              c = scheme.correct;
            } else {
              c = scheme.wrong;
            }
          }
          _letterData.add(LetterData(_letters[i], c));
        }
        return GestureDetector(
          onLongPress: onLongPress,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _letterData.map((e) => _letter(context, e.content, colour: e.colour)).toList(),
          ),
        );
      },
    );
  }

  Widget _letter(BuildContext context, String letter, {Color? colour}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 60,
        height: 80,
        child: AnimatedContainer(
          duration: animationDuration ?? Duration(milliseconds: valid ? 1000 : 250),
          padding: const EdgeInsets.all(12),
          color: colour ?? theme.scaffoldBackgroundColor,
          child: Center(
            child: Text(
              letter,
              style: textStyle ?? Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class LetterData {
  final String content;
  final Color? colour;
  const LetterData(this.content, [this.colour]);
}
