import 'package:common/common.dart';
import 'package:flutter/material.dart';
import '../app/colours.dart';

class PostGamePanel extends StatelessWidget {
  final int guesses;
  final int? reason;

  const PostGamePanel({
    Key? key,
    required this.guesses,
    required this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: 620 / 261,
      child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1, color: Colours.wrong),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(reason == EndReasons.solved ? 'Congratulations!' : 'Too slow!', style: textTheme.headline4),
              Text(
                reason == EndReasons.solved ? 'You figured out the word in $guesses guesses' : 'You ran out of time',
                style: textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ],
          )),
    );
  }
}
