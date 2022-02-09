import 'dart:convert';

import 'package:common/common.dart';
import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class TeamHandler {
  static Future<Response> getTeam(Request request, String id) async {
    try {
      final result = await teamStore().get(id);
      if (!result.ok) return HttpUtils.buildErrorResponse(result.error!);
      return HttpUtils.buildResponse(
        data: {'team': result.object!.toMap()},
      );
    } catch (e, s) {
      print('exception in getTeam: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getAllTeams(Request request) async {
    try {
      final result = await teamStore().getAll();
      return HttpUtils.buildResponse(data: {
        'teams': result.map((e) => e.toMap(includeMembers: false)).toList(),
      });
    } catch (e, s) {
      print('exception in getAllTeams: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> createTeam(Request request) async {
    try {
      final authResult = await authenticateRequest(request);
      if (!authResult.ok) return authResult.errorResponse;

      User user = authResult.user!;
      if (user.team != null) return HttpUtils.buildErrorResponse('already_in_team');

      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      String name = data[TeamFields.name];
      if (!isValidTeamName(name)) return HttpUtils.buildErrorResponse('invalid_name');

      Team team = Team(name: name, leader: user.id, members: [user.id]);

      final result = await teamStore().write(team);
      if (!result.ok) return HttpUtils.buildErrorResponse(result.error!);

      await userStore().write(user.copyWith(team: team.id));

      return HttpUtils.buildResponse(
        data: {
          'team': team.toMap(),
        },
      );
    } catch (e, s) {
      print('exception in createTeam: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
