import 'dart:convert';

import 'package:shelf/shelf.dart';

class HttpUtils {
  static Response buildResponse({Map<String, dynamic>? data, String? error, List<String> warnings = const []}) {
    data ??= {};
    String status = 'ok';

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

  static Response buildErrorResponse(String error, [List<String> warnings = const []]) =>
      buildResponse(error: error, warnings: warnings);

  static Response invalidRequestResponse() => buildResponse(error: 'invalid_request');

  static Object? toEncodable(dynamic object) {
    if (object is Map) {
      // convert maps that aren't Map<String, dynamic>
      return {
        for (var k in object.keys) '$k': object[k],
      };
    }
  }
}
