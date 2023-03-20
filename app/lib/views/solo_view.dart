import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:go_router/go_router.dart';
import 'package:word_game/app/router.dart';
import 'package:word_game/cubits/local_game_manager.dart';
import 'package:word_game/services/service_locator.dart';
import 'package:word_game/services/sound_service.dart';
import 'package:word_game/ui/game_creator.dart';
import 'package:word_game/ui/game_overview.dart';
import 'package:word_game/views/game_view.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class SoloView extends StatefulWidget {
  const SoloView({super.key});

  @override
  _SoloViewState createState() => _SoloViewState();
}

class _SoloViewState extends State<SoloView> {
  final ScrollController _controller = ScrollController();

  void _scrollUp([Duration duration = const Duration(milliseconds: 500)]) {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        if (_controller.positions.isEmpty) return; // ???
        _controller.animateTo(
          _controller.position.minScrollExtent,
          duration: duration,
          curve: Curves.fastOutSlowIn,
        );
      },
    );
  }

  @override
  void initState() {
    BlocProvider.of<LocalGameManager>(context).numGamesStream.listen((_) => _scrollUp());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameManager = BlocProvider.of<LocalGameManager>(context);
    return StandardScaffold(
      title: 'Solo Play',
      body: Center(
        child: SafeArea(
          child: BlocBuilder<LocalGameManager, LocalGameManagerState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                        controller: _controller,
                        shrinkWrap: true,
                        children: state.games.reversed
                            .map((e) => GestureDetector(
                                  child: GameOverview(
                                    e,
                                    onRemove: () {
                                      sound().play(Sound.clickDown);
                                      HapticFeedback.mediumImpact();
                                      gameManager.removeGame(e.state.id);
                                    },
                                    key: ValueKey('go_${e.state.id}'),
                                  ),
                                  onTap: () => context.push(
                                    Routes.game(e.state.id),
                                    extra: GameRouteData(
                                      game: e,
                                      title: '${e.state.length} letter game',
                                    ),
                                  ),
                                ))
                            .toList(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3 / 4,
                      ),
                    ),
                  ),
                  GameCreator(
                    onCreate: (cfg) {
                      sound().play(Sound.clickUp);
                      HapticFeedback.mediumImpact();
                      gameManager.createGame(cfg.config);
                    },
                    showTimeLimit: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
