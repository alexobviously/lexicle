import 'package:common/common.dart';
import 'package:validators/validators.dart';
import 'package:word_game/services/api_client.dart';

class OnlineMediator implements Mediator {
  final String gameId;
  final int wordLength;

  OnlineMediator({required this.gameId, required this.wordLength});

  @override
  Future<WordValidationResult> validateWord(String word) async {
    if (word.length != wordLength || !isAlpha(word)) return WordValidationResult.invalid();
    final _result = await ApiClient.makeGuess(gameId, word);
    if (!_result.ok) {
      return WordValidationResult.invalid();
    }
    return _result.object!;
  }
}
