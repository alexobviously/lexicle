import 'package:common/common.dart';
import 'package:shelf/shelf.dart';
import 'package:validators/validators.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class ChallengeHandler {
  /// There are three different options here:
  /// 1. getChallenge(id)
  /// 2. getChallenge(level, sequence)
  /// 3. getChallenge(level) - gets the current challenge for the level
  /// This method also includes the user's game in this challenge if they have one.
  static Future<Response> getChallenge(Request request, String first, [String? second]) async {
    try {
      Challenge? challenge;
      if (second != null) {
        int level = int.parse(first);
        int sequence = int.parse(second);
        final result = await challengeStore().getBySequence(level, sequence);
        if (!result.ok) return HttpUtils.buildErrorResponse(result.error!);
        challenge = result.object!;
      } else {
        if (isMongoId(first)) {
          final result = await db().get<Challenge>(first);
          if (!result.ok) return HttpUtils.buildErrorResponse(result.error!);
          challenge = result.object!;
        } else {
          int level = int.parse(first);
          if (!Challenges.allLevels.contains(level)) return HttpUtils.buildErrorResponse(Errors.invalidLevel);
          final result = await challengeStore().getCurrent(level);
          if (!result.ok) return HttpUtils.buildErrorResponse(result.error!);
          challenge = result.object!;
        }
      }
      final authResult = await authenticateRequest(request);
      if (authResult.ok) {
        final result = await db().getChallengeAttempt(authResult.user!.id, challenge.id);
        if (result.hasObject) {
          challenge = challenge.copyWith(hasAttempt: true);
        }
      }
      Map<String, dynamic> data = {
        'challenge': challenge.toMap(hideAnswer: !challenge.finished, showHasAttempt: true),
      };

      return HttpUtils.buildResponse(data: data);
    } catch (e, s) {
      print('exception in getChallenge: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getChallengeAttempt(Request request, String challenge) async {
    try {
      final authResult = await authenticateRequest(request);
      if (!authResult.ok) return authResult.errorResponse;
      final challengeResult = await db().get<Challenge>(challenge);
      if (!challengeResult.ok) return HttpUtils.buildErrorResponse(challengeResult.error!);
      bool finished = challengeResult.object!.finished;
      final result = await db().getChallengeAttempt(authResult.user!.id, challenge);
      Game? game = result.object;
      if (game == null && !finished) {
        game = Game.fromChallenge(challenge: challengeResult.object!, player: authResult.user!.id);
        gameStore().write(game);
      }
      if (game == null) {
        return HttpUtils.buildErrorResponse(Errors.challengeFinished);
      }
      return HttpUtils.buildResponse(
        data: {
          'game': game.toMap(hideAnswer: !finished),
        },
      );
    } catch (e, s) {
      print('exception in getChallengeAttempt: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
