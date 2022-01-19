import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/mediator/mediator.dart';

class GameController extends Cubit<Game> {
  final Mediator mediator;
  GameController({required String player, required int length, required this.mediator})
      : super(Game.initial(player, length));

  void addLetter(String l) {
    if (state.word.length >= state.length) return;
    emit(state.copyWith(current: WordData.current('${state.word}$l')));
  }

  void backspace() {
    if (state.word.isEmpty) return;
    emit(state.copyWith(current: WordData.current(state.word.substring(0, state.word.length - 1))));
  }

  void enter() async {
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

class GameState {
  final int length;
  final List<WordData> guesses;
  final WordData current;
  final bool valid;

  String get word => current.content;
  bool get wordReady => word.length == length;
  bool get wordEmpty => word.isEmpty;
  Set<String> get correctLetters => Set<String>.from(guesses.expand((e) => e.correctLetters));
  Set<String> get semiCorrectLetters =>
      Set<String>.from(guesses.expand((e) => e.semiCorrectLetters))..removeWhere((e) => correctLetters.contains(e));
  Set<String> get wrongLetters => Set<String>.from(guesses.expand((e) => e.wrongLetters));
  bool get gameFinished => guesses.isNotEmpty && guesses.last.correctLetters.length == length;
  int get numRows => guesses.length + (gameFinished ? 0 : 1);

  GameState({required this.length, required this.guesses, required this.current, this.valid = true});
  factory GameState.initial(int length) => GameState(length: length, guesses: [], current: WordData.blank());

  GameState copyWith({
    int? length,
    List<WordData>? guesses,
    WordData? current,
    bool valid = true,
  }) =>
      GameState(
        length: length ?? this.length,
        guesses: guesses ?? this.guesses,
        current: current ?? this.current,
        valid: valid,
      );
  GameState withInvalid() => copyWith(valid: false);
}
