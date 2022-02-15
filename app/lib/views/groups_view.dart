import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/game_group_manager.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';
import 'package:word_game/ui/game_clock.dart';
import 'package:word_game/ui/game_creator.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class GroupsView extends StatefulWidget {
  const GroupsView({Key? key}) : super(key: key);

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  @override
  void initState() {
    final cubit = BlocProvider.of<GameGroupManager>(context);
    cubit.refresh();
    super.initState();
  }

  void _onCreate(bool ok) => ok ? sound().play(Sound.clickUp) : null;
  void _onJoin(bool ok) => _onCreate(ok);
  void _onDelete(bool ok) => ok ? sound().play(Sound.clickDown) : null;
  void _onLeave(bool ok) => _onDelete(ok);

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<GameGroupManager>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return StandardScaffold(
      title: 'Online Play',
      body: Center(
        child: SafeArea(
          child: BlocBuilder<GameGroupManager, GroupManagerState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        NeumorphicButton(
                          onPressed: () => state.working ? null : cubit.refresh(),
                          child: state.working
                              ? SpinKitFadingCircle(size: 24, color: Colors.black87)
                              : const Icon(MdiIcons.refresh),
                        ),
                        NeumorphicButton(
                          onPressed: () => context.push(Routes.topPlayers),
                          child: const Icon(MdiIcons.podium),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 20),
                  Expanded(
                    child: ListView.builder(
                      // shrinkWrap: true,
                      itemCount: state.groups.length,
                      itemBuilder: (context, i) {
                        GameGroup g = state.groups.entries.toList().reversed.toList()[i].value;
                        bool isCreator = g.creator == auth().userId;
                        Color? tileColour = i % 2 == 0 ? Colours.wrong : null;
                        bool joined = state.joined.contains(g.id);
                        if (joined) tileColour = Colours.semiCorrect;
                        if (g.finished) tileColour = Colours.victory;
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.title),
                              Row(
                                children: [
                                  if (g.config.timeLimit != null)
                                    GameClock(
                                      g.config.timeLimit!,
                                      fullDetail: true,
                                      textStyle: textTheme.bodyText1,
                                      iconSize: 16,
                                    ),
                                ],
                              ),
                            ],
                          ),
                          tileColor: tileColour,
                          onTap: joined
                              ? () => context.push(Routes.group(g.id), extra: cubit.getControllerForGroup(g))
                              : null,
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${g.players.length}', style: textTheme.headline5, textAlign: TextAlign.center),
                          ),
                          trailing: !g.started
                              ? NeumorphicButton(
                                  style: NeumorphicStyle(
                                    color: tileColour,
                                    depth: 2,
                                  ),
                                  onPressed: () {
                                    if (isCreator) {
                                      cubit.deleteGroup(g.id).then(_onDelete);
                                    } else if (joined) {
                                      cubit.leaveGroup(g.id).then(_onLeave);
                                    } else {
                                      cubit.joinGroup(g.id).then(_onJoin);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 50,
                                    child: Text(
                                      isCreator
                                          ? 'Delete'
                                          : joined
                                              ? 'Leave'
                                              : 'Join',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                  GameCreator(
                    showTitle: true,
                    showTimeLimit: true,
                    onCreate: (cfg) => cubit.createGroup(cfg.title, cfg.config).then(_onCreate),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
