import 'dart:async';
import 'dart:math';

import 'package:common/common.dart';
import 'package:duration/duration.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:validators/validators.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/game_group_controller.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';
import 'package:word_game/ui/entity_future_builder.dart';
import 'package:word_game/ui/game_clock.dart';
import 'package:word_game/ui/game_overview.dart';
import 'package:word_game/views/game_view.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/ui/username_link.dart';

class GroupView extends StatefulWidget {
  final GameGroupController controller;
  const GroupView(this.controller, {Key? key}) : super(key: key);

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  GameGroupController get controller => widget.controller;
  TextEditingController wordController = TextEditingController();
  final _scrollControllerGroup = LinkedScrollControllerGroup();
  List<ScrollController> _scrollControllers = [];
  bool invalidWord = false;

  int? endTime;
  int? timeLeft;
  Timer? timer;

  late int _gameState;
  late int _playerCount;
  late int _wordCount;

  @override
  void initState() {
    if (controller.state.group.words.containsKey(auth().userId)) {
      wordController.text = controller.state.group.words[auth().userId!]!;
    }
    // todo: unfuck this
    for (int i = 0; i < 50; i++) {
      _scrollControllers.add(_scrollControllerGroup.addAndGet());
    }
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      final _controller = _scrollControllers.first;
      if (_controller.positions.isEmpty) return; // ???
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
      );
    });
    _initTimer();
    _gameState = controller.state.group.state;
    _playerCount = controller.state.group.players.length;
    _wordCount = controller.state.group.words.length;
    controller.stream.map((e) => e.group.endTime).distinct().listen((_) => _initTimer());
    controller.stream.map((e) => e.group.state).distinct().listen(_onGameState);
    controller.stream.map((e) => e.group.players.length).distinct().listen(_onPlayerCount);
    controller.stream.map((e) => e.group.words.length).distinct().listen(_onWordCount);
    super.initState();
  }

  void _initTimer() {
    timer?.cancel();
    if (controller.state.group.endTime != null) {
      endTime = controller.state.group.endTime;
      timer = Timer.periodic(Duration(seconds: 1), (_) => _setTimeLeft());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _setTimeLeft() {
    if (endTime == null) return;
    setState(() => timeLeft = max(endTime! - DateTime.now().millisecondsSinceEpoch, 0));
  }

  void _submitWord() async {
    final state = controller.state.group;
    if (!isAlpha(wordController.text) || wordController.text.length != state.config.wordLength) {
      sound().play(Sound.bad);
      return;
    }

    final _result = await controller.setWord(wordController.text);
    if (!_result.ok) {
      setState(() => invalidWord = true);
      sound().play(Sound.bad);
    } else {
      sound().play(Sound.good);
    }
    HapticFeedback.mediumImpact();
  }

  void _onGameState(int state) {
    if (state == _gameState) return;
    if (state == MatchState.playing) sound().play(Sound.clickUp);
    if (state == MatchState.finished) {
      final st = controller.state.group.standings;
      final guesses = controller.state.group.playerGuesses(auth().userId!);
      if (st.first.guesses == guesses) {
        // todo: win sound
        sound().play(Sound.clickDown);
      } else {
        // todo: finish sound
        sound().play(Sound.clickUp);
      }
    }
    _gameState = state;
  }

  void _onPlayerCount(int n) {
    if (n > _playerCount) sound().play(Sound.clickUp);
    if (n < _playerCount) sound().play(Sound.clickDown);
    _playerCount = n;
  }

  void _onWordCount(int n) {
    if (n > _wordCount) sound().play(Sound.good);
    _wordCount = n;
  }

  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      title: 'Group Game',
      body: SafeArea(
        child: BlocBuilder<GameGroupController, GameGroupState>(
          bloc: controller,
          builder: (context, state) {
            if (state.group.state == MatchState.lobby) {
              return _lobbyView(context, state.group);
            } else if (state.group.state == MatchState.playing) {
              return _playView(context, state);
            } else {
              return _resultsView(context, state);
            }
          },
        ),
      ),
    );
  }

  String _timeString(int created) {
    Duration d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(created));
    return prettyDuration(d, abbreviated: true, tersity: DurationTersity.minute);
  }

  Widget _created(BuildContext context, GameGroup group) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Created ${_timeString(group.created)} ago'),
      ],
    );
  }

  Widget _lobbyView(BuildContext context, GameGroup group) {
    final isCreator = auth().userId == group.creator;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool isValid = !invalidWord && isAlpha(wordController.text);
    bool canSubmit = wordController.text.length == group.config.wordLength && isValid;
    InputBorder? wordFieldBorder = (isValid || wordController.text.isEmpty)
        ? null
        : UnderlineInputBorder(borderSide: BorderSide(color: Colours.invalid));
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Neumorphic(
            padding: EdgeInsets.all(8.0),
            style: NeumorphicStyle(
              depth: 2,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12.0)),
            ),
            child: Column(
              children: [
                Text(
                  'Set Word',
                  style: textTheme.headline5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          maxLength: group.config.wordLength,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          onChanged: (x) => setState(() => invalidWord = false), // hmm
                          textCapitalization: TextCapitalization.none,
                          controller: wordController,
                          decoration: InputDecoration(
                            border: wordFieldBorder,
                            enabledBorder: wordFieldBorder,
                            focusedBorder: wordFieldBorder,
                          ),
                        ),
                      ),
                      Container(width: 16.0),
                      NeumorphicButton(
                        onPressed: canSubmit ? _submitWord : null,
                        child: const Icon(MdiIcons.keyboardReturn),
                      ),
                    ],
                  ),
                ),
                if (group.config.timeLimit != null) GameClock(group.config.timeLimit!, fullDetail: true),
              ],
            ),
          ),
        ),
        Container(height: 30),
        Text(
          'Players',
          style: textTheme.headline5,
        ),
        Expanded(
          child: ListView.builder(
            // shrinkWrap: true,
            itemCount: group.players.length,
            itemBuilder: (context, i) {
              String player = group.players[i];
              bool ready = group.playerReady(player);
              return ListTile(
                title: UsernameLink(
                  innerKey: ValueKey('lobby_${group.id}_$player'),
                  id: player,
                  content: (context, u) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('[${u.rating.rating.toStringAsFixed(0)}] ${u.username}'),
                      if (u.team != null) _team(context, u.team!),
                    ],
                  ),
                ),
                trailing: Text(ready ? 'Ready' : 'Not Ready'),
              );
            },
          ),
        ),
        // Spacer(),
        if (isCreator && group.canBegin)
          NeumorphicButton(
            onPressed: controller.start,
            child: Text(
              'Start Group',
              style: textTheme.headline5,
            ),
          ),
        if (isCreator && !group.canBegin)
          Neumorphic(
            padding: EdgeInsets.all(16.0),
            style: NeumorphicStyle(depth: 2),
            child: Text('Waiting for players..', style: textTheme.headline5),
          ),
        _created(context, group),
      ],
    );
  }

  Widget _playView(BuildContext context, GameGroupState state) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    List<GameController> gcs = state.games.entries.map((e) => e.value).toList();
    gcs.sort((a, b) {
      if (a.state.gameFinished == b.state.gameFinished) return 0;
      return b.state.gameFinished ? -1 : 1;
    });
    return SingleChildScrollView(
      child: LayoutBuilder(builder: (context, c) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (timeLeft != null) GameClock(timeLeft!),
            Text(
              'Standings',
              style: textTheme.headline5,
            ),
            SizedBox(
              width: c.maxWidth,
              child: FittedBox(
                child: _standings(context, state.group, c.maxWidth),
              ),
            ),
            GridView.count(
              // controller: _controller,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: gcs
                  .map(
                    (e) => EntityFutureBuilder<User>(
                      key: ValueKey('mpgo_${e.state.id}_${e.state.creator}'),
                      id: e.state.creator,
                      store: userStore(),
                      loadingWidget: SpinKitCubeGrid(size: 128, color: Colours.semiCorrect),
                      errorWidget: (_) => Icon(Icons.error),
                      resultWidget: (u) => GestureDetector(
                        child: GameOverview(
                          e,
                          header: Text(u.username),
                          key: ValueKey('go_${e.state.id}'),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GameView(game: e, title: '${u.username}\'s game'),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            Container(height: 64),
            _created(context, state.group),
          ],
        );
      }),
    );
  }

  Widget _resultsView(BuildContext context, GameGroupState state) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SingleChildScrollView(
      child: LayoutBuilder(builder: (context, c) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Results',
              style: textTheme.headline5,
            ),
            Container(height: 32),
            SizedBox(
              width: c.maxWidth,
              child: FittedBox(
                child: _standings(context, state.group, c.maxWidth, true),
              ),
            ),
            Container(height: 32),
            Text(
              'Answers',
              style: textTheme.headline5,
            ),
            SizedBox(
              width: c.maxWidth,
              child: FittedBox(
                child: _answers(context, state.group, c.maxWidth),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _answers(BuildContext context, GameGroup group, double width) {
    final textTheme = Theme.of(context).textTheme;
    List<AnswerTableRow> _rows =
        group.players.map((e) => AnswerTableRow(e, group.words[e] ?? '', group.wordDifficulty(e))).toList();
    _rows.sort((a, b) => b.difficulty.compareTo(a.difficulty));

    Color _answerColour(double difficulty) {
      if (difficulty < 5.5) {
        return Color.lerp(Colours.correct, Colours.semiCorrect, (difficulty - 2.0) / 3.5)!;
      } else {
        return Color.lerp(Colours.semiCorrect, Colours.invalid.lighten(0.2), (difficulty - 5.5) / 3.5)!;
      }
    }

    return Column(
      children: [
        ..._rows.map(
          (e) => Container(
            width: width,
            height: 48,
            padding: const EdgeInsets.all(8.0),
            color: _answerColour(e.difficulty),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: UsernameLink(
                    innerKey: ValueKey('answers_${group.id}_${e.player}'),
                    id: e.player,
                  ),
                ),
                Text(e.word, style: textTheme.headline6),
                Spacer(),
                Text(e.difficulty.toStringAsFixed(2), style: textTheme.headline6),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _standings(BuildContext context, GameGroup state, double width, [bool finished = false]) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final standings = state.standings;

    Color? _standingColour(Standing st) {
      if (!finished) return null;
      if (st.guesses == standings[0].guesses) {
        return Colours.gold.lighten();
      }
      if (st.guesses == standings[1].guesses) {
        return Colours.silver.lighten(0.05);
      }
      if (standings.length > 2 && st.guesses == standings[2].guesses) {
        return Colours.bronze.lighten();
      }
      return null;
    }

    Color? _boxColour(GameStub g) {
      if (g.id.isEmpty) return Colours.wrong;
      if (g.progress >= 1.0) {
        if (g.endReason == EndReasons.solved) {
          return Colours.correct;
        } else {
          return Colours.invalid.lighten(0.3);
        }
      }
      return Color.lerp(Colours.blank, Colours.semiCorrect, g.progress);
    }

    // exceptionally stupid but it works
    int x = finished ? state.players.length : 0;

    return Column(
      children: [
        ...standings
            .map(
              (e) => Container(
                width: width,
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: finished ? 0.0 : 8.0),
                color: _standingColour(e),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UsernameLink(
                              innerKey: ValueKey('standings_${state.id}_${finished}_${e.player}'),
                              id: e.player,
                              content: finished
                                  ? (context, u) => Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u.username, style: textTheme.headline6),
                                          if (u.team != null) _team(context, u.team!),
                                        ],
                                      )
                                  : null),
                        ],
                      ),
                    ),
                    Text('${e.guesses}', style: textTheme.headline6),
                    Container(width: 32),
                    Expanded(
                      child: ListView(
                        controller: _scrollControllers[x++],
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: state
                            .playerGamesSorted(e.player)
                            .reversed
                            .map((g) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: finished ? 8.0 : 0.0),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: _boxColour(g),
                                    ),
                                    child: g.id.isNotEmpty ? Center(child: Text(g.guesses.toString())) : null,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Container(width: 16),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _team(BuildContext context, String id) {
    return EntityFutureBuilder<Team>(
      id: id,
      store: teamStore(),
      loadingWidget: Container(),
      errorWidget: (_) => Icon(Icons.error),
      resultWidget: (team) => Text(
        team.name,
        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colours.correct.darken(0.4)),
      ),
    );
  }
}

class AnswerTableRow {
  final String player;
  final String word;
  final double difficulty;
  AnswerTableRow(this.player, this.word, this.difficulty);
}
