import 'package:common/common.dart';

abstract class Mediator {
  Future<WordValidationResult> validateWord(String word);
}

class WordValidationResult {
  final bool valid;
  final WordData? word;
  WordValidationResult({required this.valid, this.word}) : assert(valid == (word != null));
  factory WordValidationResult.invalid() => WordValidationResult(valid: false);
}
