import 'dart:convert';

import 'package:common/common.dart';
import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class AdminHandler {
  static Future<Response> changePassword(Request request) async {
    try {
      final result = await authenticateRequest(request, needAdmin: true);
      if (!result.ok) return result.errorResponse;
      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      String username = data[UserFields.username];
      if (!isValidUsername(username)) return HttpUtils.buildErrorResponse('invalid_username');
      final userResult = await userStore().getByUsername(username);
      if (!userResult.ok) return HttpUtils.buildErrorResponse(Errors.notFound);
      String password = data[UserFields.password];
      password = encrypt(password);
      final aResult = await authStore().get(userResult.object!.id);
      if (!aResult.ok) return HttpUtils.buildErrorResponse(Errors.unknown);
      AuthData a = aResult.object!.copyWith(password: password);
      await authStore().write(a);
      return HttpUtils.buildResponse();
    } catch (e, s) {
      print('exception in resetPassword: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> restoreGroup(Request request) async {
    try {
      final result = await authenticateRequest(request, needAdmin: true);
      if (!result.ok) return result.errorResponse;
      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      String groupId = data['group'];
      final restoreResult = await gameServer().restoreGroup(groupId);
      if (!restoreResult.ok) return HttpUtils.buildErrorResponse(restoreResult.error!);
      return HttpUtils.buildResponse(data: {'group': restoreResult.object!.toMap()});
    } catch (e, s) {
      print('exception in restoreGame: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
