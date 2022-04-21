import 'package:common/common.dart';
import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class ChallengeHandler {
  static Future<Response> getChallengeAttempt(Request request, String challenge) async {
    try {
      final authResult = await authenticateRequest(request);
      if (!authResult.ok) return authResult.errorResponse;
      final challengeResult = await db().get<Challenge>(challenge);
      if (!challengeResult.ok) return HttpUtils.buildErrorResponse(challengeResult.error!);
      final result = await db().getChallengeAttempt(authResult.user!.id, challenge);
      Game? game = result.object;
      if (game == null) {
        game = Game.fromChallenge(challenge: challengeResult.object!, player: authResult.user!.id);
        gameStore().write(game);
      }
      if (challengeResult.object!.finished) {}
      return HttpUtils.buildResponse(
        data: {
          'game': game.toMap(),
        },
      );
    } catch (e, s) {
      print('exception in getChallengeAttempt: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
