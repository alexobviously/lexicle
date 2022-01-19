import 'package:flutter/material.dart';
import 'package:word_game/app/colours.dart';

class WordRow extends StatelessWidget {
  final int length;
  final String content;
  final List<int> correct;
  final List<int> semiCorrect;
  final List<int> wrong;
  final bool finalised;
  final bool valid;
  const WordRow({
    Key? key,
    required this.length,
    this.content = '',
    this.correct = const [],
    this.semiCorrect = const [],
    this.wrong = const [],
    this.finalised = false,
    this.valid = true,
  })  : assert(content.length <= length),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> _letters = content.split('')..addAll(List.filled(length - content.length, ''));
    List<LetterData> _letterData = [];
    for (int i = 0; i < length; i++) {
      Color? c;
      if (finalised) {
        if (semiCorrect.contains(i)) {
          c = Colours.semiCorrect;
        } else if (correct.contains(i)) {
          c = Colours.correct;
        } else {
          c = Colours.wrong;
        }
      }
      _letterData.add(LetterData(_letters[i], c));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _letterData.map((e) => _letter(context, e.content, colour: e.colour)).toList(),
    );
  }

  Widget _letter(BuildContext context, String letter, {Color? colour}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: valid ? 1000 : 250),
        width: 60,
        height: 80,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colour ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(6.0),
          border: (!valid || (!finalised && letter.isNotEmpty))
              ? Border.all(color: valid ? Colors.grey.shade500 : Colours.invalid)
              : null,
          // shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              offset: const Offset(2, 2),
              blurRadius: 12.0,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-2, -2),
              blurRadius: 12.0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: Theme.of(context).textTheme.headline4,
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
