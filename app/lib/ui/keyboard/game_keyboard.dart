import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
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

  Color? getColour(String letter, ColourScheme scheme) {
    if (correct.contains(letter)) {
      return scheme.correct;
    }
    if (semiCorrect.contains(letter)) {
      return scheme.semiCorrect;
    }
    if (wrong.contains(letter)) {
      return scheme.wrong;
    }
    return scheme.blank;
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
    print(Theme.of(context).scaffoldBackgroundColor);
    return BlocBuilder<SchemeCubit, ColourScheme>(
      builder: (context, scheme) {
        List<Row> _rows = [];
        for (String r in rows) {
          List<Widget> _widgets = r.split('').map((e) => _key(context, e, colour: getColour(e, scheme))).toList();
          if (r == rows.last) {
            _widgets = [_enterKey(context, scheme), ..._widgets, _backspaceKey(context, scheme)];
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
      },
    );
  }

  Widget _key(BuildContext context, String letter, {Color? colour}) {
    TextStyle textStyle = Theme.of(context).textTheme.headline4!;
    bool dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) textStyle = textStyle.copyWith(color: Colors.white);
    return KeyButton(
      child: Text(letter, style: textStyle),
      colour: colour,
      onTap: wordReady ? null : () => _onTap(letter),
      blurRadius: dark ? 2 : 10,
      depth: dark ? 1 : 2,
    );
  }

  Widget _enterKey(BuildContext context, ColourScheme scheme) {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    return KeyButton(
      width: 75,
      child: Icon(
        MdiIcons.keyboardReturn,
        size: 36,
        color: wordReady ? null : scheme.wrong,
      ),
      onTap: wordReady ? () => _onEnter() : null,
      colour: scheme.blank,
      blurRadius: dark ? 2 : 10,
      depth: dark ? 1 : 2,
    );
  }

  Widget _backspaceKey(BuildContext context, ColourScheme scheme) {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    return KeyButton(
      width: 75,
      child: Icon(
        MdiIcons.backspaceOutline,
        size: 36,
        color: !wordEmpty ? null : scheme.wrong,
      ),
      onTap: !wordEmpty ? () => _onBackspace() : null,
      onLongPress: onClear,
      colour: scheme.blank,
      blurRadius: dark ? 2 : 10,
      depth: dark ? 1 : 2,
    );
  }
}
