import 'package:shelf/shelf.dart';
import 'package:validators/validators.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class UserHandler {
  static Future<Response> getUser(Request request, String id) async {
    try {
      final result = await userStore().get(id);
      if (!result.ok) return HttpUtils.buildErrorResponse(result.error!);
      return HttpUtils.buildResponse(
        data: {'user': result.object!.toMap()},
      );
    } catch (e, s) {
      print('exception in getUser: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getMe(Request request) async {
    try {
      final result = await authenticateRequest(request);
      if (!result.ok) return result.errorResponse;
      return HttpUtils.buildResponse(
        data: {'user': result.user!.toMap()},
        tokenData: result.tokenData,
      );
    } catch (e, s) {
      print('exception in getMe: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getStats(Request request, String id) async {
    try {
      final result = await ustatsStore().get(id);
      if (!result.ok) return HttpUtils.buildErrorResponse(result.error!);
      return HttpUtils.buildResponse(
        data: {'stats': result.object!.toMap()},
      );
    } catch (e, s) {
      print('exception in getStats: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getMyStats(Request request) async {
    try {
      final result = await authenticateRequest(request);
      if (!result.ok) return result.errorResponse;
      final sResult = await userStore().get(result.user!.id);
      if (!sResult.ok) return HttpUtils.buildErrorResponse(sResult.error!);
      return HttpUtils.buildResponse(
        data: {'stats': sResult.object!.toMap()},
        tokenData: result.tokenData,
      );
    } catch (e, s) {
      print('exception in getMe: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
