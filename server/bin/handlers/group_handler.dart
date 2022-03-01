import 'package:common/common.dart';
import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class GroupHandler {
  static Future<Response> getActiveGroupsForPlayer(Request request) async {
    try {
      final authResult = await authenticateRequest(request);
      if (!authResult.ok) return authResult.errorResponse;
      List<GameGroup> groups = gameServer().gameGroups.entries.map((e) => e.value.state).toList();
      groups.removeWhere((e) => !e.players.contains(authResult.user!.id));
      return HttpUtils.buildResponse(
        data: {
          'groups': groups.map((e) => e.toMap(hideAnswers: true)).toList(),
        },
      );
    } catch (e, s) {
      print('exception in getActiveGroupsForPlayer: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getAvailableGroups(Request request) async {
    try {
      final authResult = await authenticateRequest(request);
      List<GameGroup> groups = gameServer().gameGroups.entries.map((e) => e.value.state).toList();
      groups.removeWhere((e) => e.started);
      if (authResult.ok) groups.removeWhere((e) => e.players.contains(authResult.user!.id));
      return HttpUtils.buildResponse(
        data: {
          'groups': groups.map((e) => e.toMap(hideAnswers: true)).toList(),
        },
      );
    } catch (e, s) {
      print('exception in getAvailableGroups: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

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
