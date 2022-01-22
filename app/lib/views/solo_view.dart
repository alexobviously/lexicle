import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/cubits/game_controller.dart';
import 'package:word_game/cubits/game_manager.dart';
import 'package:word_game/ui/game_creator.dart';
import 'package:word_game/ui/game_overview.dart';
import 'package:word_game/ui/game_page.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class SoloView extends StatefulWidget {
  const SoloView({Key? key}) : super(key: key);

  @override
  _SoloViewState createState() => _SoloViewState();
}

class _SoloViewState extends State<SoloView> {
  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      title: 'Solo Play',
      body: Center(
        child: SafeArea(
          child: BlocBuilder<GameManager, GameManagerState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                        shrinkWrap: true,
                        children: state.games.reversed
                            .map((e) => GestureDetector(
                                  child: GameOverview(e, key: ValueKey('go_${e.state.id}')),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => GamePage(game: e, title: '${e.state.length} letter game'),
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
                  const GameCreator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
