import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/http_utils.dart';

class StatusHandler {
  static Future<Response> meta(Request request) async {
    return HttpUtils.buildResponse(
      data: {
        'version': env().version,
        'appMinVersion': '0.3.0',
        'appCurrentVersion': '0.3.5',
      },
    );
  }

  static Future<Response> serverStatus(Request request) async {
    return HttpUtils.buildResponse(
      data: {
        'version': env().version,
        'numGroups': gameServer().gameGroups.length,
        'numGames': gameServer().games.length,
      },
    );
  }
}
