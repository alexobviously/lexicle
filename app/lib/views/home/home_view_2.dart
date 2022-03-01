import 'package:badges/badges.dart';
import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/auth_controller.dart';
import 'package:word_game/cubits/scheme_cubit.dart';
import 'package:word_game/cubits/server_meta_cubit.dart';
import 'package:word_game/mediator/rush_mediator.dart';
import 'package:word_game/model/server_meta.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/ui/game_clock.dart';
import 'package:word_game/ui/game_creator.dart';
import 'package:word_game/ui/game_creator_dialog.dart';
import 'package:word_game/ui/standard_scaffold.dart';
import 'package:word_game/views/home/animated_logo.dart';
import 'package:word_game/views/home/login_box.dart';
import 'package:word_game/views/home/user_details.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/views/rush_view.dart';

class HomeView2 extends StatefulWidget {
  const HomeView2({Key? key}) : super(key: key);

  @override
  _HomeView2State createState() => _HomeView2State();
}

class _HomeView2State extends State<HomeView2> {
  final List<GameGroup> dummyData = [
    GameGroup(
      id: 'asdf',
      title: 'Steamed Clams',
      config: GameConfig(wordLength: 5, timeLimit: 600000),
      creator: 'buttsystems',
      players: ['buttsystems', 'steve', 'bryce'],
    ),
    GameGroup(
      id: 'qweqewr',
      title: 'Bare Words',
      config: GameConfig(wordLength: 6, timeLimit: 1500000),
      creator: 'alex',
      players: ['alex', 'gpe', 'franc', 'bryce'],
    ),
    GameGroup(
      id: 'qweqewrz',
      title: 'Bare Words 2',
      config: GameConfig(wordLength: 6, timeLimit: 1500000),
      creator: 'alex',
      players: ['alex', 'gpe', 'franc', 'bryce'],
    ),
    GameGroup(
      id: 'qweqewrz',
      title: 'ninny',
      config: GameConfig(wordLength: 5, timeLimit: 1800000),
      creator: 'bryce',
      players: ['bryce'],
    ),
  ];

  static const int _practice = 0;
  static const int _matchmaking = 1;
  static const int _custom = 2;

  int _tab = _practice;

  void _setTab(int tab) {
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return BlocListener<AuthController, AuthState>(
      listener: (context, state) {
        if (!state.loggedIn && _tab != _practice) {
          _setTab(_practice);
        }
      },
      child: StandardScaffold(
        showAppBar: false,
        showBackButton: false,
        body: BlocBuilder<AuthController, AuthState>(builder: (context, state) {
          return Center(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AnimatedLogo(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(onPressed: () => context.push(Routes.settings), icon: Icon(MdiIcons.cog)),
                      IconButton(onPressed: () {}, icon: Icon(MdiIcons.bell)),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        state.loggedIn
                            ? UserDetails(
                                user: state.user!,
                                stats: state.stats ?? UserStats(id: state.userId!),
                              )
                            : LoginBox(),
                        Container(height: 16),
                        _activeGames(context),
                        Container(height: 16),
                        Neumorphic(
                          style: NeumorphicStyle(depth: -2),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                NeumorphicToggle(
                                  selectedIndex: _tab,
                                  children: ['Practice', 'Matchmaking', 'Custom Games']
                                      .map((e) => _toggleElement(context, e))
                                      .toList(),
                                  thumb: Neumorphic(
                                    style: NeumorphicStyle(
                                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.all(Radius.circular(12))),
                                    ),
                                  ),
                                  onChanged: _setTab,
                                ),
                                if (_tab == _practice) _practiceView(),
                                if (_tab == _matchmaking) _matchmakingView(),
                                if (_tab == _custom) _customView(context),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 64,
                        child: GestureDetector(
                          onTap: () => context.push(Routes.about),
                          child: Image.asset('assets/images/logo.png'),
                        ),
                      ),
                    ),
                  ),
                  _version(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _practiceView() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          NeumorphicButton(
            onPressed: () => context.push(Routes.solo),
            style: NeumorphicStyle(
              depth: 2,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            ),
            child: Text('Practice', style: textTheme.headline6),
          ),
          Container(height: 20),
          NeumorphicButton(
            onPressed: () => context.push(
              Routes.rush,
              extra: RushRouteData(
                game: RushController(
                  Rush.initial('alex', GameConfig(wordLength: 5, timeLimit: 300000)),
                  RushMediator(getWord: () => dictionary().randomWord(5)),
                ),
              ),
            ),
            style: NeumorphicStyle(
              depth: 2,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
            ),
            child: Badge(
              position: BadgePosition.topEnd(top: -6, end: -15),
              toAnimate: false,
              shape: BadgeShape.square,
              badgeColor: Colours.victory.darken(0.5).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.all(2.0),
              elevation: 0,
              badgeContent: Text('new', style: TextStyle(color: Colors.white70)),
              child: Text('  Rush  ', style: textTheme.headline6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchmakingView() => Text('Matchmaking\n\nComing soon!');
  Widget _customView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: NeumorphicButton(
            style: NeumorphicStyle(depth: 2),
            onPressed: () => showCreatorDialog(context),
            child: Text('Create Game'),
          ),
        ),
        _gameList(context, dummyData.skip(2).toList(), showCreator: true),
      ],
    );
  }

  ToggleElement _toggleElement(BuildContext context, String text) {
    return ToggleElement(
      foreground: Center(
          child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      background: Center(child: Text(text)),
    );
  }

  Widget _activeGames(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Neumorphic(
      style: NeumorphicStyle(depth: -2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Active Games', style: textTheme.headline6),
          ),
          _gameList(context, dummyData.take(2).toList()),
        ],
      ),
    );
  }

  Widget _gameList(BuildContext context, List<GameGroup> groups, {bool showCreator = false}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return BlocBuilder<SchemeCubit, ColourScheme>(builder: (context, scheme) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: groups.length,
        itemBuilder: (context, i) {
          final group = groups[i];
          return Container(
            color: i % 2 == 0 ? scheme.alt : null,
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Center(
                      child: Text(
                        group.players.length.toString(),
                        style: textTheme.headline6,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        group.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (showCreator) Text(group.creator),
                    ],
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: GameClock(group.config.timeLimit),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: textTheme.bodyText2!.color!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          group.config.wordLength.toString(),
                          style: textTheme.headline6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _version() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return BlocBuilder<ServerMetaCubit, ServerMeta>(
            builder: (context, meta) {
              Version localVersion = Version.parse(snapshot.data!.version);
              bool updateAvailable = meta.loaded && localVersion < Version.parse(meta.appCurrentVersion);
              bool updateNeeded = meta.loaded && localVersion < Version.parse(meta.appMinVersion);
              return Container(
                color: updateNeeded
                    ? Colours.invalid.lighten(0.1)
                    : updateAvailable
                        ? Colours.victory
                        : null,
                child: Row(
                  children: [
                    if (updateAvailable || updateNeeded)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(updateNeeded ? 'Update required' : 'Update available'),
                      ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Version $localVersion'),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Text('Version...');
        }
      },
    );
  }
}
