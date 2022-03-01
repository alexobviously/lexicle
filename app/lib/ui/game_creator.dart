import 'package:common/common.dart';
import 'package:duration/duration.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/model/game_creation_data.dart';
import 'package:word_game/ui/length_control.dart';

class GameCreator extends StatefulWidget {
  final bool showTitle;
  final bool showTimeLimit;
  final double depth;
  final VoidCallback? onCancel;
  final Function(GameCreationData) onCreate;
  const GameCreator({
    this.onCancel,
    this.depth = 4,
    this.showTitle = false,
    required this.onCreate,
    this.showTimeLimit = false,
    Key? key,
  }) : super(key: key);

  @override
  _GameCreatorState createState() => _GameCreatorState();
}

class _GameCreatorState extends State<GameCreator> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  static int length = 5;
  static Duration? duration = _durations.first;

  static const List<Duration> _durations = [
    Duration.zero,
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 45),
    Duration(hours: 1),
    Duration(hours: 2),
    Duration(hours: 4),
    Duration(days: 1),
    Duration(days: 3),
  ];

  void _setLength(int l) {
    HapticFeedback.mediumImpact();
    setState(() => length = l);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: widget.depth,
          // boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25.0)),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (widget.onCancel != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 48),
                  Text('New Custom Game', style: textTheme.headline6),
                  IconButton(
                    icon: Icon(MdiIcons.close),
                    onPressed: widget.onCancel,
                  ),
                ],
              ),
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
            DropdownButton<Duration>(
              value: duration,
              items: _durations.map((e) => _menuItem(e)).toList(),
              onChanged: (val) => setState(() => duration = val),
            ),
            OutlinedButton(
              onPressed: () {
                HapticFeedback.vibrate();
                int? _duration;
                if (duration != null && duration!.inSeconds > 0) _duration = duration!.inMilliseconds;
                final config = GameConfig(wordLength: length, timeLimit: _duration);
                widget.onCreate(GameCreationData(
                  config: config,
                  title: _titleController.text,
                ));
              },
              child: Text('Create New Game', style: textTheme.headline6!.copyWith(color: Colours.correct.darken(0.4))),
            ),
          ],
        ),
      ),
    );
  }

  String _timeString(Duration d) {
    if (d.inMilliseconds == 0) return 'No limit';
    return prettyDuration(d, abbreviated: false, tersity: DurationTersity.minute);
  }

  DropdownMenuItem<Duration> _menuItem(Duration d) {
    return DropdownMenuItem<Duration>(
      value: d,
      child: Text(_timeString(d)),
    );
  }
}
