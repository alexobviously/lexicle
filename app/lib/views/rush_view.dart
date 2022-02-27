import 'dart:async';
import 'dart:math';
import 'package:duration/duration.dart';
import 'package:flutter/services.dart';

import 'package:common/common.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';
import 'package:word_game/ui/entity_future_builder.dart';
import 'package:word_game/ui/game_clock.dart';
import 'package:word_game/ui/keyboard/game_keyboard.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/ui/word_row.dart';

import '../ui/post_game_panel.dart';

class RushRouteData {
  final RushController? game;
  final String? title;
  RushRouteData({this.game, this.title});
}

class RushView extends StatefulWidget {
  final String id;
  final RushRouteData data;
  const RushView({Key? key, required this.id, required this.data}) : super(key: key);

  @override
  _RushViewState createState() => _RushViewState();
}

class _RushViewState extends State<RushView> {
  // GameController get game => widget.data.game;
  RushController? game;
  String? error;

  int? endTime;
  int? timeLeft;
  Timer? timer;
  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    game?.close();
    super.dispose();
  }

  void _init() async {
    if (widget.data.game != null) {
      game = widget.data.game!;
    } else {
      setState(() => error = 'how did you get here?');
      // final result = await gameStore().get(widget.id);
      // if (result.ok) {
      //   setState(() => game = ObserverGameController(result.object!));
      // } else {
      //   setState(() => error = result.error!);
      // }
    }
    if (game != null) {
      _initTimer(game!.state.endTime);
      game!.endTimeStream.listen((t) => _initTimer(t));
      game!.numRowsStream.listen((_) => _scrollDown());
      WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollDown(Duration(milliseconds: 750)));
    }
  }

  void _initTimer(int? t) {
    timer?.cancel();
    if (t != null) {
      endTime = t;
      timer = Timer.periodic(Duration(seconds: 1), (_) => _setTimeLeft());
    }
  }

  void _setTimeLeft() {
    if (endTime == null) return;
    if (mounted) setState(() => timeLeft = max(endTime! - DateTime.now().millisecondsSinceEpoch, 0));
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
    bool ok = await game!.enter();
    if (ok) {
      sound().play(Sound.pop);
    }
  }

  void _onBackspace() {
    _scrollDown();
    if (game!.state.currentWord.isEmpty && mounted) setState(() {}); // hack for scroll
    game!.backspace();
  }

  void _addLetter(String l) {
    game!.addLetter(l);
    _scrollDown();
  }

  void _clearInput() {
    HapticFeedback.mediumImpact();
    game!.clearInput();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null || game == null) {
      return StandardScaffold(
        body: Center(
          child: SafeArea(
            child: Builder(
              builder: (context) {
                if (error != null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error getting game',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Text(
                        error!,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.go(Routes.home),
                        icon: Icon(MdiIcons.home),
                        label: Text('Go Home'),
                      ),
                    ],
                  );
                }
                return Center(
                  child: SpinKitFadingGrid(
                    color: Colours.correct.darken(0.3),
                    size: 64,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
    return BlocBuilder<RushController, Rush>(
        bloc: game!,
        builder: (context, state) {
          return StandardScaffold(
            title: widget.data.title,
            appBarActions: [_copyButton(context)],
            body: Center(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        if (timeLeft != null) GameClock(timeLeft!),
                        Spacer(),
                        Text('${state.completed.length} solved'),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Neumorphic(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          duration: const Duration(milliseconds: 2000),
                          style: NeumorphicStyle(
                            depth: -10,
                            color: state.finished ? Colours.correct.withAlpha(100) : null,
                            // border: state.solved
                            //     ? NeumorphicBorder(color: Colours.correct, width: 1.0)
                            //     : const NeumorphicBorder.none(),
                          ),
                          child: SingleChildScrollView(
                            controller: _controller,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(height: 16),
                                for (Game g in state.completed) ..._gameBlock(context, g),
                                ..._gameBlock(context, state.current),
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
                              onClear: _clearInput,
                              correct: state.current.correctLetters,
                              semiCorrect: state.current.semiCorrectLetters,
                              wrong: state.current.wrongLetters,
                              wordReady: state.current.wordReady,
                              wordEmpty: state.current.wordEmpty,
                            ),
                          ),
                          secondChild: SizedBox(
                            width: MediaQuery.of(context).size.width - 16.0,
                            child: PostGamePanel(
                              guesses: state.completed.length,
                              reason: state.endReason,
                            ),
                          ),
                          crossFadeState: !state.finished ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _observerBox(BuildContext context, Game game) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: SizedBox(
          width: constraints.maxWidth * 0.95,
          child: Neumorphic(
            style: NeumorphicStyle(depth: -2),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EntityFutureBuilder<User>(
                      id: game.player,
                      store: userStore(),
                      loadingWidget: SpinKitCircle(color: Colours.victory, size: 16),
                      errorWidget: (_) => Icon(Icons.error),
                      resultWidget: (u) => Text('Observing ${u.username}'),
                    ),
                    EntityFutureBuilder<User>(
                      id: game.creator,
                      store: userStore(),
                      loadingWidget: SpinKitCircle(color: Colours.victory, size: 16),
                      errorWidget: (_) => Icon(Icons.error),
                      resultWidget: (u) => Text('${u.username}\'s game'),
                    ),
                  ],
                ),
                Text('${game.guesses.length}', style: Theme.of(context).textTheme.headline5),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _gameBlock(BuildContext context, Game g) {
    return [
      ...g.guesses
          .map(
            (e) => FittedBox(
              child: WordRow(
                length: g.length,
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
      if (!g.gameFinished)
        FittedBox(
          child: WordRow(
            length: g.length,
            content: g.word,
            valid: !g.invalid,
            surfaceIntensity: 0,
            shape: NeumorphicShape.convex,
            onLongPress: _clearInput,
          ),
        ),
      if (g.gameFinished) Container(height: 32),
    ];
  }

  String _timeString(int d) {
    if (d == 0) return '∞';
    return prettyDuration(Duration(milliseconds: d), abbreviated: true, tersity: DurationTersity.minute);
  }

  Widget _copyButton(BuildContext context) {
    bool enabled = game!.state.numRows > 1;
    String d = _timeString(game!.state.config.timeLimit ?? 0);
    String title = '${game!.state.completed.length} words / $d';
    String emojis = game!.state.toEmojis();
    String words = game!.state.completed.map((e) => '✅ ${e.answer}').toList().join('\n');
    words = '$words\n❌ ${game!.state.current.answer}';
    return IconButton(
      onPressed: enabled
          ? () {
              Clipboard.setData(
                ClipboardData(text: '$title\n$emojis\n$words'),
              ).then((_) {
                sound().play(Sound.good);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Game copied to clipboard'), duration: Duration(seconds: 2)));
              });
            }
          : null,
      icon: Icon(
        MdiIcons.contentCopy,
        color: enabled ? null : Colors.grey[400],
      ),
    );
  }
}
