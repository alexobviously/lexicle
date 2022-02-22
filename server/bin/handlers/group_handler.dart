import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class GroupHandler {
  static Future<Response> getPlayerGroups(Request request, String player) async {
    try {
      String playerId = player;
      if (player == 'me') {
        final authResult = await authenticateRequest(request);
        if (!authResult.ok) return authResult.errorResponse;
        playerId = authResult.user!.id;
      }
      final groups = await groupStore().getForPlayer(playerId);
      return HttpUtils.buildResponse(
        data: {'groups': groups.map((e) => e.toMap()).toList()},
      );
    } catch (e, s) {
      print('exception in getPlayerGroups: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
