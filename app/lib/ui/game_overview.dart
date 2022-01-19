import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:word_game/cubits/game_controller.dart';
import 'package:word_game/word_row.dart';

class GameOverview extends StatefulWidget {
  final GameController game;
  const GameOverview(this.game, {Key? key}) : super(key: key);

  @override
  State<GameOverview> createState() => _GameOverviewState();
}

class _GameOverviewState extends State<GameOverview> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: Colors.grey[500]!),
        // shape: BoxShape.circle,
      ),
      child: BlocBuilder<GameController, GameState>(
        bloc: widget.game,
        builder: (context, state) {
          return ListView(
            controller: _controller,
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
                  child: WordRow(length: state.length, content: state.word),
                )
            ],
          );
        },
      ),
    );
  }
}
