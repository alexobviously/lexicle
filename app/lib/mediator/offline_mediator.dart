import 'package:common/common.dart';
import 'package:validators/validators.dart';
import 'package:word_game/services/service_locator.dart';

class OfflineMediator implements Mediator {
  final String answer;
  OfflineMediator({required this.answer});

  @override
  Future<WordValidationResult> validateWord(String word) async {
    if (word.length != answer.length || !isAlpha(word)) return WordValidationResult.invalid();
    if (!dictionary().isValidWord(word)) return WordValidationResult.invalid();
    // print('answer: $answer');
    List<int> correct = [];
    List<int> semiCorrect = [];
    for (int i = 0; i < word.length; i++) {
      String letter = word[i];
      List<int> indices = RegExp(letter).allMatches(answer).map((RegExpMatch e) => e.start).toList();
      if (indices.isNotEmpty) {
        if (indices.contains(i)) {
          correct.add(i);
        } else {
          semiCorrect.add(i);
        }
      }
    }
    return WordValidationResult(
      valid: true,
      word: WordData(
        content: word,
        correct: correct,
        semiCorrect: semiCorrect,
        finalised: true,
      ),
    );
  }
}
