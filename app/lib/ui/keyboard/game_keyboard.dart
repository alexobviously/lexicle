import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
import 'package:word_game/ui/keyboard/key_button.dart';

class GameKeyboard extends StatefulWidget {
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
    super.key,
    required this.onTap,
    required this.onEnter,
    required this.onBackspace,
    this.onClear,
    this.correct = const [],
    this.semiCorrect = const [],
    this.wrong = const [],
    this.wordReady = false,
    this.wordEmpty = false,
  });

  @override
  State<GameKeyboard> createState() => _GameKeyboardState();
}

class _GameKeyboardState extends State<GameKeyboard> {
  final String _keys = GameKeyboard.rows.fold('', (p, e) => '$p$e');

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _focusNode.addListener(_handleFocusNodeUpdate);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color? getColour(String letter, ColourScheme scheme) {
    if (widget.correct.contains(letter)) {
      return scheme.correct;
    }
    if (widget.semiCorrect.contains(letter)) {
      return scheme.semiCorrect;
    }
    if (widget.wrong.contains(letter)) {
      return scheme.wrong;
    }
    return scheme.blank;
  }

  void _onTap(String l) {
    HapticFeedback.mediumImpact();
    widget.onTap(l);
  }

  void _onEnter() {
    HapticFeedback.vibrate();
    widget.onEnter();
  }

  void _onBackspace() {
    HapticFeedback.mediumImpact();
    widget.onBackspace();
  }

  void _handleFocusNodeUpdate() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  // TODO: propagate this to animations somehow
  void _handleKeyboardEvent(RawKeyEvent event) {
    if (!(event is RawKeyDownEvent || event.repeat)) return;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      widget.onBackspace();
      return;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      widget.onEnter();
      return;
    }
    String? _key = event.character?.toLowerCase();
    if (_key != null && _keys.contains(_key)) {
      widget.onTap(_key);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKey: _handleKeyboardEvent,
      child: BlocBuilder<SchemeCubit, ColourScheme>(
        builder: (context, scheme) {
          List<Row> _rows = [];
          for (String r in GameKeyboard.rows) {
            List<Widget> _widgets = r.split('').map((e) => _key(context, e, colour: getColour(e, scheme))).toList();
            if (r == GameKeyboard.rows.last) {
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
      ),
    );
  }

  Widget _key(BuildContext context, String letter, {Color? colour}) {
    TextStyle textStyle = Theme.of(context).textTheme.headline4!;
    bool dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) textStyle = textStyle.copyWith(color: Colors.white);
    return KeyButton(
      child: Text(letter, style: textStyle),
      colour: colour,
      onTap: widget.wordReady ? null : () => _onTap(letter),
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
        color: widget.wordReady ? null : scheme.wrong,
      ),
      onTap: widget.wordReady ? () => _onEnter() : null,
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
        color: !widget.wordEmpty ? null : scheme.wrong,
      ),
      onTap: !widget.wordEmpty ? () => _onBackspace() : null,
      onLongPress: widget.onClear,
      colour: scheme.blank,
      blurRadius: dark ? 2 : 10,
      depth: dark ? 1 : 2,
    );
  }
}
