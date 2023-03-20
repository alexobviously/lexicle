import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/app/colours.dart';

class DictWordRow extends StatelessWidget {
  final String content;
  final VoidCallback? onTap;
  int get length => content.length;
  const DictWordRow({
    super.key,
    this.content = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<String> _letters = content.split('')..addAll(List.filled(length - content.length, ''));
    return InkWell(
      onTap: onTap,
      highlightColor: Colours.semiCorrect,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _letters.map((e) => _letter(context, e)).toList(),
      ),
    );
  }

  Widget _letter(BuildContext context, String letter) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 60,
        height: 80,
        child: Neumorphic(
          duration: const Duration(milliseconds: 1000),
          padding: const EdgeInsets.all(12.0),
          style: NeumorphicStyle(
            // color: Colors.grey[300],
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(6.0)),
            depth: 1.0,
            intensity: 0.6,
            border: NeumorphicBorder(
              color: Colours.wrong,
              width: 2.0,
            ),
          ),
          child: Center(
            child: Text(
              letter,
              style: Theme.of(context).textTheme.headlineMedium,
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
