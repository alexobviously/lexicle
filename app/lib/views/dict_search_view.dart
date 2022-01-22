import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/dict_search_controller.dart';
import 'package:word_game/ui/dict_word_row.dart';
import 'package:word_game/ui/game_keyboard.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/ui/word_row.dart';

class DictSearchView extends StatefulWidget {
  const DictSearchView({Key? key}) : super(key: key);

  @override
  State<DictSearchView> createState() => _DictSearchViewState();
}

class _DictSearchViewState extends State<DictSearchView> {
  late final DictSearchController _controller;

  @override
  void initState() {
    _controller = DictSearchController(5);
    super.initState();
  }

  int _gridCrossAxis(DictSearchState state) {
    if (state.suggestions.isEmpty) return 2; // don't know why 1 crashes it
    if (state.length > 6) return 1;
    if (state.suggestions.length > 5) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
        title: 'Dictionary',
        body: Center(
          child: SafeArea(
            child: BlocBuilder<DictSearchController, DictSearchState>(
              bloc: _controller,
              builder: (context, state) {
                bool _highlight = state.current.length >= state.length || state.suggestions.isEmpty;
                Color? _hlColour;
                double? _hlBorder;
                if (_highlight) {
                  _hlColour = state.valid ? Colours.correct : Colours.invalid;
                  _hlBorder = state.valid ? 5.0 : 1.0;
                }

                return Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: state.canDecLength ? _controller.decLength : null,
                          icon: const Icon(
                            MdiIcons.chevronLeft,
                            size: 32,
                          ),
                        ),
                        Expanded(
                          child: FittedBox(
                            child: WordRow(
                              length: state.length,
                              content: state.current,
                              borderColour: _hlColour,
                              borderWidth: _hlBorder,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: state.canIncLength ? _controller.incLength : null,
                          icon: const Icon(
                            MdiIcons.chevronRight,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.count(
                          crossAxisCount: _gridCrossAxis(state),
                          childAspectRatio: (state.length * 5) / 6,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          children: state.suggestions
                              .map(
                                (e) => FittedBox(
                                  child: DictWordRow(
                                    content: e,
                                    onTap: () => _controller.setCurrent(e),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          child: GameKeyboard(
                            onTap: (l) => _controller.addLetter(l),
                            onBackspace: () => _controller.backspace(),
                            onEnter: () {},
                            correct: state.current.split(''),
                            wordReady: false,
                            wordEmpty: state.current.isEmpty,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }
}
