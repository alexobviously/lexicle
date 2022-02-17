import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';

class RushController extends Cubit<Rush> {
  static const int solvedBonus = 10000;
  static const int guessPenalty = -2000;

  final Mediator mediator;
  RushController(Rush rush, this.mediator) : super(rush) {
    start();
  }

  Timer? endTimer;

  void _resetTimer(int? endTime) {
    endTimer?.cancel();
    if (endTime == null) return;
    endTimer = Timer(DateTime.fromMillisecondsSinceEpoch(endTime).difference(DateTime.now()), _timeout);
  }

  void start() {
    _resetTimer(state.endTime);
  }

  void end(int reason) {
    if (state.endReason != reason) {
      // sometimes we set this elsewhere, e.g. guesses
      emit(state.copyWith(endReason: reason));
    }
    endTimer?.cancel();
  }

  void _timeout() async {
    if (state.finished) return;
    String answer = await mediator.getAnswer() ?? '*' * state.config.wordLength;
    emit(state.copyWith(endReason: EndReasons.timeout, current: state.current.copyWith(answer: answer)));
    end(EndReasons.timeout);
  }

  void addLetter(String l) {
    if (state.currentWord.length >= state.length || state.finished) return;
    emit(state.withCurrent(state.current.copyWith(current: WordData.current('${state.currentWord}$l'))));
  }

  void backspace() {
    if (state.currentWord.isEmpty || state.finished) return;
    emit(state.withCurrent(state.current.copyWith(
      current: WordData.current(
        state.currentWord.substring(0, state.currentWord.length - 1),
      ),
    )));
  }

  Future<bool> enter() async {
    if (state.finished) return false;
    final _result = await mediator.validateWord(state.currentWord);
    if (!_result.valid) {
      emit(state.withCurrent(state.current.copyWithInvalid()));
    } else {
      bool solved = _result.word!.solved;
      int? endReason = solved ? EndReasons.solved : null;
      final _current = state.current.copyWith(
        current: WordData.blank(),
        guesses: List.from(state.current.guesses)..add(_result.word!),
        endReason: endReason,
        answer: solved ? _result.word!.content : state.current.answer,
      );
      if (solved) {
        emit(state
            .withCurrent(_current)
            .withNewWord(Game.initial(_current.player, state.config.wordLength))
            .timeAdjusted(solvedBonus));
      } else {
        emit(state.withCurrent(_current).timeAdjusted(guessPenalty));
      }
      _resetTimer(state.endTime);
    }
    return true;
  }

  void clearInput() {
    if (state.currentWord.isNotEmpty) {
      emit(state.withCurrent(state.current.copyWith(current: WordData.current(''))));
    }
  }

  @override
  Future<void> close() {
    endTimer?.cancel();
    return super.close();
  }

  Stream<int> get numRowsStream => stream.map((e) => e.numRows).distinct();
  Stream<bool> get gameFinishedStream => stream.map((e) => e.finished).distinct();
  Stream<int?> get endTimeStream => stream.map((e) => e.endTime).distinct();
}
