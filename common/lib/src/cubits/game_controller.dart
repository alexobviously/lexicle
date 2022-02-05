import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';

class GameController extends Cubit<Game> {
  final Mediator mediator;
  GameController(Game game, this.mediator) : super(game) {
    start();
  }
  factory GameController.initial({
    required String player,
    required int length,
    required Mediator mediator,
    int? endTime,
  }) =>
      GameController(Game.initial(player, length, endTime: endTime), mediator);

  Map<String, dynamic> toMap({bool hideAnswer = false}) => state.toMap(hideAnswer: hideAnswer);
  GameStub get stub => state.stub;

  Timer? endTimer;

  StreamSubscription<int>? highestGuessStream; // listen to highest guess count in the group, for penalty
  int highestGuess = 0;
  void registerHighestGuessStream(Stream<int> stream) => highestGuessStream = stream.listen(_handleHighestGuess);
  void _handleHighestGuess(int count) => highestGuess = count;

  void start() {
    if (state.endTime != null) {
      endTimer = Timer(DateTime.fromMillisecondsSinceEpoch(state.endTime!).difference(DateTime.now()), _timeout);
    }
  }

  void end(int reason) {
    if (state.endReason != reason) {
      // sometimes we set this elsewhere, e.g. guesses
      emit(state.copyWith(endReason: reason));
    }
    endTimer?.cancel();
  }

  void _timeout() {
    print('timeout hit');
    if (state.gameFinished) return;
    int targetScore = max(max(highestGuess + 1, 6), state.guesses.length);
    int penalty = targetScore - state.guesses.length;
    emit(state.copyWith(endReason: EndReasons.timeout, penalty: penalty));
    end(EndReasons.timeout);
  }

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
      int? endReason = _result.word!.solved ? EndReasons.solved : null;
      emit(state.copyWith(
        current: WordData.blank(),
        guesses: List.from(state.guesses)..add(_result.word!),
        endReason: endReason,
      ));
    }
  }

  Future<Result<WordValidationResult>> makeGuess(String word) async {
    if (state.gameFinished) return Result.error('game_finished');
    if (state.guesses.isNotEmpty && state.guesses.first.finalised && state.guesses.first.content == word) {
      return Result.error('duplicate_guess');
    }
    final _result = await mediator.validateWord(word);
    if (state.gameFinished) return Result.error('game_finished'); // no race conditions thx
    if (!_result.valid) {
      emit(state.copyWith(current: WordData.current(word)).copyWithInvalid());
    } else {
      int? endReason = _result.word!.solved ? EndReasons.solved : null;
      emit(state.copyWith(
        current: WordData.blank(),
        guesses: List.from(state.guesses)..add(_result.word!),
        endReason: endReason,
      ));
    }
    if (state.solved) end(EndReasons.solved);
    return Result.ok(_result);
  }

  @override
  Future<void> close() {
    endTimer?.cancel(); // shouldn't happen but possibly could
    highestGuessStream?.cancel();
    return super.close();
  }

  Stream<int> get numRowsStream => stream.map((e) => e.numRows).distinct();
  Stream<bool> get gameFinishedStream => stream.map((e) => e.gameFinished).distinct();
}
