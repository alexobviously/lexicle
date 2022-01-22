import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/cubits/game_manager.dart';
import 'package:word_game/ui/length_control.dart';

class GameCreator extends StatefulWidget {
  GameCreator({Key? key}) : super(key: key);

  @override
  _GameCreatorState createState() => _GameCreatorState();
}

class _GameCreatorState extends State<GameCreator> {
  final _formKey = GlobalKey<FormState>();

  static int length = 5;

  void _setLength(int l) {
    HapticFeedback.mediumImpact();
    setState(() => length = l);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final gameManager = BlocProvider.of<GameManager>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: 4.0,
          // boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            LengthControl(
              length: length,
              onChanged: _setLength,
            ),
            OutlinedButton(
              onPressed: () {
                HapticFeedback.vibrate();
                gameManager.createLocalGame(GameConfig(wordLength: length));
              },
              child: Text('Create New Game', style: textTheme.headline6!.copyWith(color: theme.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}
