import 'package:word_game/model/word_data.dart';

abstract class Mediator {
  Future<WordValidationResult> validateWord(String word);
}

class WordValidationResult {
  final bool valid;
  final WordData? word;
  WordValidationResult({required this.valid, this.word}) : assert(valid == (word != null));
  factory WordValidationResult.invalid() => WordValidationResult(valid: false);
}
