import 'dart:async';
import 'dart:math';

import 'package:common/common.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';
import 'package:word_game/ui/game_clock.dart';
import 'package:word_game/ui/game_keyboard.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/ui/word_row.dart';

import '../ui/post_game_panel.dart';

class GameView extends StatefulWidget {
  final GameController game;
  final String? title;
  const GameView({Key? key, required this.game, this.title}) : super(key: key);

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  GameController get game => widget.game;

  int? endTime;
  int? timeLeft;
  Timer? timer;

  @override
  void initState() {
    _initTimer();
    game.stream.map((e) => e.endTime).distinct().listen((_) => _initTimer());
    widget.game.numRowsStream.listen((_) => _scrollDown());
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollDown(Duration(milliseconds: 750)));
    super.initState();
  }

  void _initTimer() {
    timer?.cancel();
    if (game.state.endTime != null) {
      endTime = game.state.endTime;
      timer = Timer.periodic(Duration(seconds: 1), (_) => _setTimeLeft());
    }
  }

  void _setTimeLeft() {
    if (endTime == null) return;
    setState(() => timeLeft = max(endTime! - DateTime.now().millisecondsSinceEpoch, 0));
  }

  final ScrollController _controller = ScrollController();

  void _scrollDown([Duration duration = const Duration(milliseconds: 250)]) {
    SchedulerBinding.instance!.addPostFrameCallback(
      (_) {
        if (_controller.positions.isEmpty) return; // ???
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: duration,
          curve: Curves.fastOutSlowIn,
        );
      },
    );
  }

  void _onEnter() async {
    bool ok = await game.enter();
    if (ok) {
      sound().play(Sound.pop);
    }
  }

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
                    if (timeLeft != null) GameClock(timeLeft!),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Neumorphic(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          duration: const Duration(milliseconds: 2000),
                          style: NeumorphicStyle(
                            depth: -10,
                            color: state.gameFinished
                                ? state.endReason == EndReasons.solved
                                    ? Colours.correct.withAlpha(100)
                                    : Colours.wrong.withAlpha(150)
                                : null,
                            border: state.solved
                                ? NeumorphicBorder(color: Colours.correct, width: 1.0)
                                : const NeumorphicBorder.none(),
                          ),
                          child: SingleChildScrollView(
                            controller: _controller,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(height: 16),
                                ...state.guesses
                                    .map(
                                      (e) => FittedBox(
                                        child: WordRow(
                                          length: state.length,
                                          content: e.content,
                                          correct: e.correct,
                                          semiCorrect: e.semiCorrect,
                                          finalised: e.finalised,
                                          shape: NeumorphicShape.convex,
                                          surfaceIntensity: e.solved ? 0.4 : 0.25,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                if (!state.gameFinished)
                                  FittedBox(
                                    child: WordRow(
                                      length: state.length,
                                      content: state.word,
                                      valid: !state.invalid,
                                      surfaceIntensity: 0,
                                      shape: NeumorphicShape.convex,
                                    ),
                                  ),
                                Container(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedCrossFade(
                          duration: Duration(milliseconds: 1000),
                          firstChild: FittedBox(
                            child: GameKeyboard(
                              onTap: _addLetter,
                              onBackspace: _onBackspace,
                              onEnter: _onEnter,
                              correct: state.correctLetters,
                              semiCorrect: state.semiCorrectLetters,
                              wrong: state.wrongLetters,
                              wordReady: state.wordReady,
                              wordEmpty: state.wordEmpty,
                            ),
                          ),
                          secondChild: SizedBox(
                            width: MediaQuery.of(context).size.width - 16.0,
                            child: PostGamePanel(
                              guesses: state.guesses.length,
                              reason: state.endReason,
                            ),
                          ),
                          crossFadeState: !state.gameFinished ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        ),
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
