import 'package:flutter/material.dart';
import '../app/colours.dart';

class PostGamePanel extends StatelessWidget {
  final int guesses;

  const PostGamePanel({
    Key? key,
    required this.guesses,
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
              Text('Congratulations!', style: textTheme.headline4),
              Text(
                'You figured out the word in $guesses guesses',
                style: textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ],
          )),
    );
  }
}
