import 'dart:convert';

import 'package:shelf/shelf.dart';

class HttpUtils {
  static Response buildResponse({Map<String, dynamic>? data}) {
    data ??= {};
    data = {'status': 'ok'}..addAll(data);
    String body = JsonEncoder.withIndent(' ', toEncodable).convert(data);
    return Response.ok(
      body,
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  static Object? toEncodable(dynamic object) {
    if (object is Map) {
      // convert maps that aren't Map<String, dynamic>
      return {
        for (var k in object.keys) '$k': object[k],
      };
    }
  }
}
