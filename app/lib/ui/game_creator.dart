import 'package:common/common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/cubits/local_game_manager.dart';
import 'package:word_game/model/game_creation_data.dart';
import 'package:word_game/ui/length_control.dart';

class GameCreator extends StatefulWidget {
  final bool showTitle;
  final Function(GameCreationData) onCreate;
  const GameCreator({this.showTitle = false, required this.onCreate, Key? key}) : super(key: key);

  @override
  _GameCreatorState createState() => _GameCreatorState();
}

class _GameCreatorState extends State<GameCreator> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  static int length = 5;

  void _setLength(int l) {
    HapticFeedback.mediumImpact();
    setState(() => length = l);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final gameManager = BlocProvider.of<LocalGameManager>(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Neumorphic(
        style: const NeumorphicStyle(
          depth: 4.0,
          // boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (widget.showTitle)
              Neumorphic(
                style: NeumorphicStyle(depth: -2),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter a title',
                  ),
                ),
              ),
            LengthControl(
              length: length,
              onChanged: _setLength,
            ),
            OutlinedButton(
              onPressed: () {
                HapticFeedback.vibrate();
                final config = GameConfig(wordLength: length);
                widget.onCreate(GameCreationData(
                  config: config,
                  title: _titleController.text,
                ));
              },
              child: Text('Create New Game', style: textTheme.headline6!.copyWith(color: theme.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}
