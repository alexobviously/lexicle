import 'package:common/common.dart';
import 'package:validators/validators.dart';
import 'package:word_game/services/service_locator.dart';

class RushMediator implements Mediator {
  Map<String, int> counts = {};
  final String Function() getWord;
  late String answer;
  RushMediator({required this.getWord}) {
    _getNewWord();
  }

  void _getNewWord() {
    answer = getWord();
    counts = _countLetters(answer);
  }

  Map<String, int> _countLetters(String answer) {
    Map<String, int> counts = {};
    for (String c in answer.split('')) {
      counts[c] = counts.containsKey(c) ? counts[c]! + 1 : 1;
    }
    return counts;
  }

  @override
  Future<WordValidationResult> validateWord(String word) async {
    if (word.length != answer.length || !isAlpha(word)) return WordValidationResult.invalid();
    if (!dictionary().isValidWord(word)) return WordValidationResult.invalid();
    // print('answer: $answer');
    List<int> correct = [];
    List<int> semiCorrect = [];
    Map<String, int> _counts = Map.from(counts);
    // find correct letters first
    for (int i = 0; i < word.length; i++) {
      String letter = word[i];
      if (letter == answer[i]) {
        _counts[letter] = _counts[letter]! - 1;
        correct.add(i);
      }
    }
    // now find semi-correct letters
    for (int i = 0; i < word.length; i++) {
      if (correct.contains(i)) continue;
      String letter = word[i];
      if (_counts.containsKey(letter) && _counts[letter]! > 0) {
        _counts[letter] = _counts[letter]! - 1;
        semiCorrect.add(i);
      }
    }

    final wd = WordData(
      content: word,
      correct: correct,
      semiCorrect: semiCorrect,
      finalised: true,
    );
    if (wd.solved) _getNewWord();

    return WordValidationResult(
      valid: true,
      word: wd,
    );
  }

  @override
  Future<String?> getAnswer() async => answer;
}
