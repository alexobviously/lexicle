import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/cubits/game_controller.dart';
import 'package:word_game/cubits/game_manager.dart';
import 'package:word_game/game_keyboard.dart';
import 'package:word_game/mediator/mediator.dart';
import 'package:word_game/mediator/offline_mediator.dart';
import 'package:word_game/model/word_data.dart';
import 'package:word_game/ui/game_creator.dart';
import 'package:word_game/ui/game_overview.dart';
import 'package:word_game/ui/game_page.dart';
import 'package:word_game/word_row.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Mediator mediator;
  late GameController gc;

  @override
  void initState() {
    mediator = OfflineMediator(answer: 'hours');
    gc = GameController(length: 5, mediator: mediator);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
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
                        children: state.games
                            .map((e) => GestureDetector(
                                  child: GameOverview(e),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => GamePage(game: e),
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
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: state.games.length,
                  //   itemBuilder: (context, i) {
                  //     return Padding(
                  //       padding: const EdgeInsets.all(24.0),
                  //       child: _gameTile(context, state.games[i], 'Game ${i + 1}'),
                  //     );
                  //     return Center(
                  //       child: GestureDetector(
                  //         child: Text('Game ${i + 1}'),
                  //         onTap: () => Navigator.of(context).push(
                  //           MaterialPageRoute(
                  //             builder: (context) => GamePage(game: state.games[i]),
                  //           ),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                  GameCreator(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _gameTile(BuildContext context, GameController gc, String title) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GamePage(game: gc),
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(6.0),
          // shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade500,
              offset: const Offset(2, 2),
              blurRadius: 12.0,
            ),
            // ignore: prefer_const_constructors
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-2, -2),
              blurRadius: 12.0,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: textTheme.headline5),
          ],
        ),
      ),
    );
  }
}
