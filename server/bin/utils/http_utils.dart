import 'dart:convert';
import 'package:common/common.dart';
import 'package:shelf/shelf.dart';

import 'auth_utils.dart';

class HttpUtils {
  static Response buildResponse({
    Map<String, dynamic>? data,
    String? error,
    List<String> warnings = const [],
    TokenData? tokenData,
  }) {
    data ??= {};
    warnings = List.from(warnings); // because the default const value isn't growable
    String status = 'ok';

    // handle token data
    if (tokenData != null) {
      switch (tokenData.status) {
        case TokenStatus.expired:
          error ??= 'expired_token';
          break;
        case TokenStatus.invalid:
          error ??= 'invalid_token';
          break;
        case TokenStatus.old:
          warnings.add('old_token');
          continue issued;
        issued:
        case TokenStatus.issued:
          data.addAll(tokenData.toMap());
          break;
        case TokenStatus.ok:
          break;
      }
    }

    if (error != null) {
      status = 'error';
      data = {'error': error};
    }

    if (warnings.isNotEmpty) {
      data = {'warnings': warnings}..addAll(data);
    }

    data = {'status': status}..addAll(data);
    String body = JsonEncoder.withIndent(' ', toEncodable).convert(data);
    return Response.ok(
      body,
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  static Response buildErrorResponse(String error, {List<String> warnings = const [], TokenData? tokenData}) =>
      buildResponse(error: error, warnings: warnings, tokenData: tokenData);

  static Response invalidRequestResponse() => buildResponse(error: Errors.invalidRequest);

  static Object? toEncodable(dynamic object) {
    if (object is Map) {
      // convert maps that aren't Map<String, dynamic>
      return {
        for (var k in object.keys) '$k': object[k],
      };
    }
  }
}
