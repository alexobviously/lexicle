import 'package:shelf/shelf.dart';
import 'package:validators/validators.dart';

import '../services/service_locator.dart';
import '../utils/auth_utils.dart';
import '../utils/http_utils.dart';

class UserHandler {
  static Future<Response> getUser(Request request, String id) async {
    try {
      final _result = await userStore().get(id);
      if (!_result.ok) return HttpUtils.buildErrorResponse(_result.error!);
      return HttpUtils.buildResponse(
        data: {'user': _result.object!.toMap()},
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
}
