import 'dart:async';
import 'dart:math';

import 'package:common/common.dart';
import 'package:duration/duration.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:validators/validators.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/game_group_controller.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';
import 'package:word_game/ui/confirmation_dialog.dart';
import 'package:word_game/ui/entity_future_builder.dart';
import 'package:word_game/ui/game_clock.dart';
import 'package:word_game/ui/game_overview.dart';
import 'package:word_game/views/game_view.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/ui/username_link.dart';

class GroupRouteData {
  final GameGroupController? group;
  final String? title;
  GroupRouteData({this.group, this.title});
}

class GroupView extends StatefulWidget {
  // right now a controller must be passed in extras, but eventually I'd like to be able to retrieve
  // groups from demand by id if no controller is provided
  final String id;
  final GroupRouteData data;
  const GroupView({required this.id, required this.data, super.key});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  GameGroupController? controller;
  String? error;
  // GameGroupController get controller => widget.controller;
  TextEditingController wordController = TextEditingController();
  final _scrollControllerGroup = LinkedScrollControllerGroup();
  List<ScrollController> _scrollControllers = [];
  final PageController _pageController = PageController();
  bool invalidWord = false;

  int? endTime;
  int? timeLeft;
  Timer? timer;

  late int _gameState;
  late List<String> _players;
  late int _wordCount;

  int _resultsTab = 0;
  bool get isObserving => controller?.observing ?? true;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() async {
    if (widget.data.group != null) {
      controller = widget.data.group!;
    } else {
      final result = await groupStore().get(widget.id);
      if (result.ok) {
        setState(() => controller = GameGroupController.observer(result.object!));
      } else {
        setState(() => error = result.error!);
      }
    }
    _initController();
  }

  void _initController() {
    if (controller != null) {
      if (controller!.state.group.words.containsKey(auth().userId)) {
        wordController.text = controller!.state.group.words[auth().userId!]!;
      }
      // todo: unfuck this
      for (int i = 0; i < 50; i++) {
        _scrollControllers.add(_scrollControllerGroup.addAndGet());
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        final _controller = _scrollControllers.first;
        if (_controller.positions.isEmpty) return; // ???
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.fastOutSlowIn,
        );
      });
      _initTimer();
      _gameState = controller!.state.group.state;
      _players = controller!.state.group.players;
      _wordCount = controller!.state.group.words.length;
      _cancelStreams();
      _endTimeStream = controller!.stream.map((e) => e.group.endTime).distinct().listen((_) => _initTimer());
      _gameStateStream = controller!.stream.map((e) => e.group.state).distinct().listen(_onGameState);
      _playersStream = controller!.stream.map((e) => e.group.players).distinct().listen(_onPlayers);
      _wordCountStream = controller!.stream.map((e) => e.group.words.length).distinct().listen(_onWordCount);
    }
  }

  void _cancelStreams() {
    _endTimeStream?.cancel();
    _gameStateStream?.cancel();
    _playersStream?.cancel();
    _wordCountStream?.cancel();
  }

  StreamSubscription<int?>? _endTimeStream;
  StreamSubscription<int?>? _gameStateStream;
  StreamSubscription<List<String>?>? _playersStream;
  StreamSubscription<int?>? _wordCountStream;

  void _initTimer() {
    timer?.cancel();
    if (controller!.state.group.endTime != null) {
      endTime = controller!.state.group.endTime;
      timer = Timer.periodic(Duration(seconds: 1), (_) => _setTimeLeft());
    }
  }

  @override
  void dispose() {
    _cancelStreams();
    if (controller?.observing ?? false) controller!.close();
    timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onJoin(GameGroupController? ggc) {
    bool ok = ggc != null;
    print('_onJoin ${ggc?.id}');
    if (ok) {
      sound().play(Sound.clickUp);
      if (!mounted) return;
      _cancelStreams();
      controller?.close();
      controller = ggc;
      _initController();
      setState(() {});
    }
  }

  void _onDelete(bool ok) {
    if (ok) {
      sound().play(Sound.clickDown);
      context.pop();
    }
  }

  void _onLeave(GameGroup? group) {
    bool ok = group != null;
    print('_onLeave $ok');
    if (ok) {
      sound().play(Sound.clickDown);
      if (!mounted) return;
      _cancelStreams();
      controller = GameGroupController.observer(group);
      _initController();
      setState(() {});
    }
  }

  void _setTimeLeft() {
    if (endTime == null) return;
    setState(() => timeLeft = max(endTime! - DateTime.now().millisecondsSinceEpoch, 0));
  }

  void _submitWord() async {
    wordController.text = wordController.text.toLowerCase();
    final state = controller!.state.group;
    if (!isAlpha(wordController.text) || wordController.text.length != state.config.wordLength) {
      sound().play(Sound.bad);
      return;
    }

    final _result = await controller!.setWord(wordController.text);
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
    if (state == GroupState.playing) sound().play(Sound.clickUp);
    if (state == GroupState.finished) {
      final st = controller!.state.group.standings;
      final guesses = controller!.state.group.playerGuesses(auth().userId!);
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

  void _onPlayers(List<String> p) {
    String? player = auth().userId;
    if (p.length > _players.length && p.contains(player) == _players.contains(player)) {
      sound().play(Sound.clickUp);
    }
    if (p.length < _players.length && p.contains(player) == _players.contains(player)) {
      sound().play(Sound.clickDown);
    }
    _players = p;
  }

  void _onWordCount(int n) {
    if (n > _wordCount) sound().play(Sound.good);
    _wordCount = n;
  }

  void _setResultsTab(int t) => setState(() => _resultsTab = t);

  void _kickPlayer(User player) async {
    final ok = await showConfirmationDialog(
      context,
      title: 'Kick ${player.username}',
      body: 'Are you sure?',
      positiveText: 'Kick',
    );
    if (ok) {
      controller!.kickPlayer(player.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null || controller == null) {
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
                        'Error getting group',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        error!,
                        style: Theme.of(context).textTheme.titleLarge,
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
    return StandardScaffold(
      title: 'Group Game',
      body: SafeArea(
        child: BlocBuilder<GameGroupController, GameGroupState>(
          bloc: controller,
          builder: (context, state) {
            if (state.group.state == GroupState.lobby) {
              return _lobbyView(context, state.group);
            } else if (state.group.state == GroupState.playing) {
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
        Text('Created ${_timeString(group.timestamp)} ago'),
      ],
    );
  }

  Widget _setWordBox(BuildContext context, GameGroup group) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool isValid = !invalidWord && isAlpha(wordController.text);
    bool canSubmit = wordController.text.length == group.config.wordLength && isValid;
    InputBorder? wordFieldBorder = (isValid || wordController.text.isEmpty)
        ? null
        : UnderlineInputBorder(borderSide: BorderSide(color: Colours.invalid));
    return SizedBox(
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
              style: textTheme.headlineSmall,
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
    );
  }

  Widget _lobbyView(BuildContext context, GameGroup group) {
    final isCreator = auth().userId == group.creator;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    bool inGroup = group.players.contains(auth().userId);
    final cubit = BlocProvider.of<GameGroupManager>(context);
    return BlocBuilder<SchemeCubit, ColourScheme>(builder: (context, scheme) {
      return Column(
        children: [
          if (inGroup) _setWordBox(context, group),
          Container(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Players',
                  style: textTheme.headlineSmall,
                ),
              ),
              if (auth().loggedIn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: NeumorphicButton(
                    style: NeumorphicStyle(
                      depth: 2,
                    ),
                    onPressed: () {
                      if (isCreator) {
                        cubit.deleteGroup(group.id).then(_onDelete);
                      } else if (group.hasPlayer(auth().userId!)) {
                        cubit.leaveGroup(group.id).then(_onLeave);
                      } else {
                        cubit.joinGroup(group.id).then(_onJoin);
                      }
                    },
                    child: SizedBox(
                      width: 50,
                      child: Text(
                        isCreator
                            ? 'Delete'
                            : group.hasPlayer(auth().userId!)
                                ? 'Leave'
                                : 'Join',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
            ],
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
                    content: (context, u) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCreator)
                          player != auth().userId
                              ? InkWell(
                                  onTap: () => _kickPlayer(u),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(MdiIcons.close),
                                  ),
                                )
                              : SizedBox(width: 32),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('[${u.rating.rating.toStringAsFixed(0)}] ${u.username}'),
                            if (u.team != null) _team(context, u.team!, scheme),
                          ],
                        ),
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
              onPressed: controller!.start,
              child: Text(
                'Start Group',
                style: textTheme.headlineSmall,
              ),
            ),
          if (isCreator && !group.canBegin)
            Neumorphic(
              padding: EdgeInsets.all(16.0),
              style: NeumorphicStyle(depth: 2),
              child: Text('Waiting for players..', style: textTheme.headlineSmall),
            ),
          _created(context, group),
        ],
      );
    });
  }

  Widget _playView(BuildContext context, GameGroupState state) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    List<BaseGameController> gcs = state.games.entries.map((e) => e.value).toList();
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
              style: textTheme.headlineSmall,
            ),
            SizedBox(
              width: c.maxWidth,
              child: FittedBox(
                child: _standings(context, state.group, c.maxWidth),
              ),
            ),
            _games(context, gcs),
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
    List<BaseGameController> gcs = state.games.entries.map((e) => e.value).toList();
    return SingleChildScrollView(
      child: LayoutBuilder(builder: (context, c) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Results',
              style: textTheme.headlineSmall,
            ),
            Container(height: 32),
            SizedBox(
              width: c.maxWidth,
              child: FittedBox(
                child: _standings(context, state.group, c.maxWidth, true),
              ),
            ),
            Container(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: NeumorphicToggle(
                selectedIndex: _resultsTab,
                displayForegroundOnlyIfSelected: true,
                children: [
                  _toggleElement(context, 'Answers'),
                  _toggleElement(context, 'Games'),
                ],
                thumb: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                onChanged: _setResultsTab,
              ),
            ),
            Container(height: 16),
            // TODO: make this smoother - a PageView would be ideal but it doesn't work in a Scrollable
            AnimatedSwitcher(
              duration: Duration(milliseconds: 50),
              child: _resultsTab == 0
                  ? SizedBox(
                      width: c.maxWidth,
                      child: FittedBox(
                        child: _answers(context, state.group, c.maxWidth),
                      ),
                    )
                  : _games(context, gcs),
            ),
          ],
        );
      }),
    );
  }

  ToggleElement _toggleElement(BuildContext context, String text) {
    final _style = Theme.of(context).textTheme.headlineSmall;
    return ToggleElement(
      foreground: Center(
          child: Text(
        text,
        style: _style!.copyWith(fontWeight: FontWeight.bold),
      )),
      background: Center(child: Text(text, style: _style)),
    );
  }

  Widget _answers(BuildContext context, GameGroup group, double width) {
    final textTheme = Theme.of(context).textTheme;
    List<AnswerTableRow> _rows =
        group.players.map((e) => AnswerTableRow(e, group.words[e] ?? '', group.wordDifficulty(e))).toList();
    _rows.sort((a, b) => b.difficulty.compareTo(a.difficulty));

    Color _answerColour(double difficulty, ColourScheme scheme) {
      if (difficulty < 5.5) {
        return Color.lerp(scheme.correct, scheme.semiCorrect, (difficulty - 2.0) / 3.5)!;
      } else {
        return Color.lerp(scheme.semiCorrect, scheme.invalid.lighten(0.2), (difficulty - 5.5) / 3.5)!;
      }
    }

    return BlocBuilder<SchemeCubit, ColourScheme>(builder: (context, scheme) {
      return Column(
        children: [
          ..._rows.map(
            (e) => Container(
              width: width,
              height: 48,
              padding: const EdgeInsets.all(8.0),
              color: _answerColour(e.difficulty, ColourScheme.base(context)),
              child: Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: UsernameLink(
                      innerKey: ValueKey('answers_${group.id}_${e.player}'),
                      id: e.player,
                    ),
                  ),
                  Text(e.word, style: textTheme.titleLarge),
                  Spacer(),
                  Text(e.difficulty.toStringAsFixed(2), style: textTheme.titleLarge),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _games(BuildContext context, List<BaseGameController> gcs) {
    return GridView.count(
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
                onTap: () => context.push(
                  Routes.game(e.state.id),
                  extra: GameRouteData(
                    game: e,
                    title: '${u.username}\'s game',
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
    );
  }

  Widget _standings(BuildContext context, GameGroup state, double width, [bool finished = false]) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final standings = state.standings;

    Color? _standingColour(Standing st, ColourScheme scheme) {
      if (!finished) return null;
      if (st.guesses == standings[0].guesses) {
        return scheme.gold;
      }
      if (st.guesses == standings[1].guesses) {
        return scheme.silver.lighten(0.05);
      }
      if (standings.length > 2 && st.guesses == standings[2].guesses) {
        return scheme.bronze.lighten();
      }
      return null;
    }

    Color? _boxColour(GameStub g, ColourScheme scheme) {
      if (g.id.isEmpty) return scheme.alt;
      if (g.progress >= 1.0 && g.endReason != null) {
        if (g.endReason == EndReasons.solved) {
          return scheme.correct;
        } else {
          return scheme.invalid.lighten(0.3);
        }
      }
      return Color.lerp(scheme.blank, scheme.semiCorrect, g.progress);
    }

    // exceptionally stupid but it works
    int x = finished ? state.players.length : 0;

    return BlocBuilder<SchemeCubit, ColourScheme>(builder: (context, scheme) {
      return Column(
        children: [
          ...standings
              .map(
                (e) => Container(
                  width: width,
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: finished ? 0.0 : 8.0),
                  color: _standingColour(e, ColourScheme.base(context)),
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
                                            Text(u.username, style: textTheme.titleLarge),
                                            if (u.team != null) _team(context, u.team!, scheme),
                                          ],
                                        )
                                    : null),
                          ],
                        ),
                      ),
                      Text('${e.guesses}', style: textTheme.titleLarge),
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
                                    child: GestureDetector(
                                      // TODO: navigate to your own games if it's you
                                      onTap: (e.player != auth().userId && g.creator.isNotEmpty)
                                          ? () => context.push(Routes.game(g.id))
                                          : null,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4.0),
                                          color: _boxColour(g, ColourScheme.base(context)),
                                        ),
                                        child: g.id.isNotEmpty ? Center(child: Text(g.guesses.toString())) : null,
                                      ),
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
    });
  }

  Widget _team(BuildContext context, String id, ColourScheme scheme) {
    return EntityFutureBuilder<Team>(
      id: id,
      store: teamStore(),
      loadingWidget: Container(),
      errorWidget: (_) => Icon(Icons.error),
      resultWidget: (team) => Text(
        team.name,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic),
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
