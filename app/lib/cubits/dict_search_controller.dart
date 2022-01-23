import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/services/service_locator.dart';

class DictSearchController extends Cubit<DictSearchState> {
  DictSearchController([int length = 5]) : super(DictSearchState.initial(length));

  void addLetter(String l) {
    if (state.current.length >= state.length) return;
    emit(state.copyWith(
      current: '${state.current}$l',
      valid: false,
    ));
    getSuggestions();
  }

  void backspace() {
    if (state.current.isEmpty) return;
    emit(state.copyWith(
      current: state.current.substring(0, state.current.length - 1),
      valid: false,
    ));
    if (state.current.isNotEmpty) {
      getSuggestions();
    } else {
      emit(state.copyWith(suggestions: []));
    }
  }

  void setCurrent(String word) {
    if (word.isEmpty) return;
    emit(state.copyWith(
      current: word,
      length: word.length,
      suggestions: [],
      valid: true,
    ));
  }

  void incLength() => setLength(state.length + 1);
  void decLength() => setLength(state.length - 1);
  void setLength(int length) {
    if (length < Dictionary.minimumLength || length > Dictionary.maximumLength) return;
    emit(state.copyWith(
      length: length,
      current: state.current.length > length ? state.current.substring(0, length) : state.current,
    ));
    getSuggestions();
  }

  void getSuggestions() {
    final _suggestions = dictionary().getSuggestions(state.current, state.length).toList();
    emit(state.copyWith(suggestions: _suggestions, valid: _suggestions.contains(state.current)));
  }
}

class DictSearchState {
  final int length;
  final String current;
  final bool valid;
  final List<String> suggestions;

  bool get canIncLength => length < Dictionary.maximumLength;
  bool get canDecLength => length > Dictionary.minimumLength;

  const DictSearchState({
    this.length = 5,
    required this.current,
    this.valid = false,
    this.suggestions = const [],
  });
  factory DictSearchState.initial([int length = 5]) => DictSearchState(current: '', length: length);

  DictSearchState copyWith({
    int? length,
    String? current,
    bool? valid,
    List<String>? suggestions,
  }) =>
      DictSearchState(
        length: length ?? this.length,
        current: current ?? this.current,
        valid: valid ?? this.valid,
        suggestions: suggestions ?? this.suggestions,
      );
}
