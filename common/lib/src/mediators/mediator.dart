import 'package:common/common.dart';

abstract class Mediator {
  Future<WordValidationResult> validateWord(String word);
  Future<String?> getAnswer();
}

class WordValidationResult {
  final bool valid;
  final WordData? word;
  WordValidationResult({required this.valid, this.word}) : assert(valid == (word != null));
  factory WordValidationResult.invalid() => WordValidationResult(valid: false);

  static const __valid = 'v';
  static const __word = 'w';

  factory WordValidationResult.fromJson(Map<String, dynamic> doc) => WordValidationResult(
        valid: doc[__valid],
        word: doc[__word] != null ? WordData.fromJson(doc[__word]) : null,
      );

  Map<String, dynamic> toMap() => {
        __valid: valid,
        if (word != null) __word: word!.toMap(),
      };
}
