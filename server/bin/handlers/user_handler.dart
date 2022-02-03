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
      print('getMe');
      print('headers: ${request.headers}');
      final tokenData = verifyHeaders(request.headers);
      print(tokenData.toMap(false));
      if (!tokenData.valid) return HttpUtils.buildResponse(tokenData: tokenData);
      String id = tokenData.subject!;
      if (!isMongoId(id)) return HttpUtils.buildErrorResponse('invalid_token');
      final _result = await userStore().get(id);
      if (!_result.ok) return HttpUtils.buildErrorResponse(_result.error!);
      return HttpUtils.buildResponse(
        data: {'user': _result.object!.toMap()},
        tokenData: tokenData,
      );
    } catch (e, s) {
      print('exception in getMe: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
