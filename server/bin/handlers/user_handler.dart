import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';
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
      final uResult = await userStore().get(id);
      if (!uResult.ok) return HttpUtils.buildErrorResponse(uResult.error!);
      final result = await ustatsStore().get(id);
      UserStats stats = UserStats(id: id);
      if (!result.ok) {
        ustatsStore().write(stats);
      } else {
        stats = result.object!;
      }
      return HttpUtils.buildResponse(
        data: {'stats': stats.toMap()},
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
      final sResult = await ustatsStore().get(result.user!.id);
      if (!sResult.ok) return HttpUtils.buildErrorResponse(sResult.error!);
      return HttpUtils.buildResponse(
        data: {'stats': sResult.object!.toMap()},
        tokenData: result.tokenData,
      );
    } catch (e, s) {
      print('exception in getMyStats: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getTopPlayers(Request request) async {
    try {
      final result = await db().getAll<User>(
          selector: where
              .lt('${UserFields.rating}.${UserFields.deviation}', 300)
              .sortBy('${UserFields.rating}.${UserFields.rating}', descending: true)
              // .skip(1)
              .limit(20));
      return HttpUtils.buildResponse(
        data: {
          'users': result.map((e) => e.toMap()).toList(),
        },
      );
    } catch (e, s) {
      print('exception in getTopPlayers: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
