import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/cubits/game_controller.dart';
import 'package:word_game/ui/game_keyboard.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/ui/word_row.dart';

class GamePage extends StatefulWidget {
  final GameController game;
  final String? title;
  const GamePage({Key? key, required this.game, this.title}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameController get game => widget.game;

  final ScrollController _controller = ScrollController();

  void _scrollDown() {
    SchedulerBinding.instance!.addPostFrameCallback(
      (_) {
        if (_controller.positions.isEmpty) return; // ???
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
        );
      },
    );
  }

  @override
  void initState() {
    widget.game.numRowsStream.listen((_) => _scrollDown());
    super.initState();
  }

  void _onEnter() => game.enter();

  void _onBackspace() {
    _scrollDown();
    if (game.state.current.content.isEmpty) setState(() {}); // hack for scroll
    game.backspace();
  }

  void _addLetter(String l) {
    game.addLetter(l);
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      title: widget.title,
      body: Center(
        child: SafeArea(
          child: BlocBuilder<GameController, Game>(
              bloc: game,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Row(
                    //     children: [
                    //       IconButton(
                    //         onPressed: () => Navigator.pop(context),
                    //         icon: const Icon(MdiIcons.arrowLeft),
                    //       ),
                    //       Spacer(),
                    //       Text(
                    //         'Game: ${state.length} letters',
                    //         style: Theme.of(context).textTheme.headline4,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _controller,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...state.guesses
                                .map(
                                  (e) => FittedBox(
                                    child: WordRow(
                                      length: state.length,
                                      content: e.content,
                                      correct: e.correct,
                                      semiCorrect: e.semiCorrect,
                                      finalised: e.finalised,
                                    ),
                                  ),
                                )
                                .toList(),
                            if (!state.gameFinished)
                              FittedBox(
                                child: WordRow(length: state.length, content: state.word, valid: !state.invalid),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                            child: GameKeyboard(
                          onTap: _addLetter,
                          onBackspace: _onBackspace,
                          onEnter: _onEnter,
                          correct: state.correctLetters,
                          semiCorrect: state.semiCorrectLetters,
                          wrong: state.wrongLetters,
                          wordReady: state.wordReady,
                          wordEmpty: state.wordEmpty,
                        )),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
