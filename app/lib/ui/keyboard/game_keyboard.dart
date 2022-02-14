import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/ui/keyboard/key_button.dart';

class GameKeyboard extends StatelessWidget {
  static const rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
  final Function(String) onTap;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;
  final VoidCallback? onClear;
  final Iterable<String> correct;
  final Iterable<String> semiCorrect;
  final Iterable<String> wrong;
  final bool wordReady;
  final bool wordEmpty;
  const GameKeyboard({
    Key? key,
    required this.onTap,
    required this.onEnter,
    required this.onBackspace,
    this.onClear,
    this.correct = const [],
    this.semiCorrect = const [],
    this.wrong = const [],
    this.wordReady = false,
    this.wordEmpty = false,
  }) : super(key: key);

  Color? getColour(String letter) {
    if (correct.contains(letter)) {
      return Colours.correct;
    }
    if (semiCorrect.contains(letter)) {
      return Colours.semiCorrect;
    }
    if (wrong.contains(letter)) {
      return Colours.wrong;
    }
    return null;
  }

  void _onTap(String l) {
    HapticFeedback.mediumImpact();
    onTap(l);
  }

  void _onEnter() {
    HapticFeedback.vibrate();
    onEnter();
  }

  void _onBackspace() {
    HapticFeedback.mediumImpact();
    onBackspace();
  }

  @override
  Widget build(BuildContext context) {
    List<Row> _rows = [];
    for (String r in rows) {
      List<Widget> _widgets = r.split('').map((e) => _key(context, e, colour: getColour(e))).toList();
      if (r == rows.last) {
        _widgets = [_enterKey(context), ..._widgets, _backspaceKey(context)];
      }
      _rows.add(Row(
        children: _widgets,
        crossAxisAlignment: CrossAxisAlignment.center,
      ));
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: Colours.wrong),
        ),
      ),
      child: Column(
        children: _rows,
      ),
    );
  }

  Widget _key(BuildContext context, String letter, {Color? colour}) {
    TextStyle textStyle = Theme.of(context).textTheme.headline4!;
    // if (wordReady) textStyle = textStyle.copyWith(color: Colors.grey[400]);
    return KeyButton(
      child: Text(letter, style: textStyle),
      colour: colour,
      onTap: wordReady ? null : () => _onTap(letter),
    );
  }

  Widget _enterKey(BuildContext context) {
    return KeyButton(
      width: 75,
      child: Icon(
        MdiIcons.keyboardReturn,
        size: 36,
        color: wordReady ? null : Colors.grey[400],
      ),
      onTap: wordReady ? () => _onEnter() : null,
    );
  }

  Widget _backspaceKey(BuildContext context) {
    return KeyButton(
      width: 75,
      child: Icon(
        MdiIcons.backspaceOutline,
        size: 36,
        color: !wordEmpty ? null : Colors.grey[400],
      ),
      onTap: !wordEmpty ? () => _onBackspace() : null,
      onLongPress: onClear,
    );
  }
}
