import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/http_utils.dart';

class StatusHandler {
  static Future<Response> meta(Request request) async {
    return HttpUtils.buildResponse(
      data: {
        'serverName': env().serverName,
        'version': env().version,
        'appMinVersion': '0.5.10',
        'appCurrentVersion': '0.5.10',
        // TODO: store this online somewhere so we don't need to rebuild for app-only changes
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
