import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/game_controller.dart';

class GameKeyboard extends StatelessWidget {
  static const rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
  final Function(String) onTap;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;
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
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: () => _onTap(letter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          width: 50,
          height: 75,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: colour ?? Colors.grey[300],
            borderRadius: BorderRadius.circular(6.0),
            // shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                offset: const Offset(2, 2),
                blurRadius: 10.0,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-2, -2),
                blurRadius: 10.0,
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
      ),
    );
  }

  Widget _enterKey(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: wordReady ? _onEnter : null,
        child: Container(
          width: 75,
          height: 75,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6.0),
            // shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                offset: const Offset(2, 2),
                blurRadius: 10.0,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-2, -2),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              MdiIcons.keyboardReturn,
              size: 36,
              color: wordReady ? null : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _backspaceKey(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onTap: !wordEmpty ? _onBackspace : null,
        child: Container(
          width: 75,
          height: 75,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500,
                offset: const Offset(2, 2),
                blurRadius: 10.0,
              ),
              const BoxShadow(
                color: Colors.white,
                offset: Offset(-2, -2),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              MdiIcons.backspaceOutline,
              size: 36,
              color: !wordEmpty ? null : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }
}
