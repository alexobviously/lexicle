import 'package:bloc/bloc.dart';
import 'package:common/common.dart';

class GameController extends Cubit<Game> {
  final Mediator mediator;
  GameController(Game game, this.mediator) : super(game);
  factory GameController.initial({required String player, required int length, required Mediator mediator}) =>
      GameController(Game.initial(player, length), mediator);

  void addLetter(String l) {
    if (state.word.length >= state.length || state.gameFinished) return;
    emit(state.copyWith(current: WordData.current('${state.word}$l')));
  }

  void backspace() {
    if (state.word.isEmpty || state.gameFinished) return;
    emit(state.copyWith(current: WordData.current(state.word.substring(0, state.word.length - 1))));
  }

  void enter() async {
    if (state.gameFinished) return;
    final _result = await mediator.validateWord(state.word);
    if (!_result.valid) {
      emit(state.copyWithInvalid());
    } else {
      emit(state.copyWith(current: WordData.blank(), guesses: List.from(state.guesses)..add(_result.word!)));
    }
  }

  Stream<int> get numRowsStream => stream.map((e) => e.numRows).distinct();
  Stream<bool> get gameFinishedStream => stream.map((e) => e.gameFinished).distinct();
}
