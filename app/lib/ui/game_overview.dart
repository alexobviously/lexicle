import 'package:common/common.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:word_game/app/colours.dart';
import 'package:word_game/ui/word_row.dart';

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
    return Neumorphic(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      style: NeumorphicStyle(
        depth: -10,
        color: widget.game.state.gameFinished ? Colours.correct.withAlpha(100) : null,
        // border: widget.game.state.gameFinished
        //     ? NeumorphicBorder(color: Colours.correct, width: 2.0)
        //     : const NeumorphicBorder.none(),
        // NeumorphicBorder(color: Colors.black12, width: 0.5), // maybe?
      ),
      child: BlocBuilder<GameController, Game>(
        bloc: widget.game,
        builder: (context, state) {
          return ListView(
            controller: _controller,
            children: [
              Container(height: 10),
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
                        surfaceIntensity: 0.15,
                      ),
                    ),
                  )
                  .toList(),
              if (!state.gameFinished)
                FittedBox(
                  child: WordRow(length: state.length, content: state.word),
                ),
              Container(height: 10),
            ],
          );
        },
      ),
    );
  }
}
