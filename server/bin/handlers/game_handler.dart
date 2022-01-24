import 'dart:convert';

import 'package:common/common.dart';
import 'package:shelf/shelf.dart';

import '../services/service_locator.dart';
import '../utils/http_utils.dart';

class GameHandler {
  static Future<Response> validateWord(Request request, String word) async {
    bool _valid = dictionary().isValidWord(word);
    return HttpUtils.buildResponse(
      data: {
        'word': word,
        'valid': _valid,
      },
    );
  }

  static Future<Response> createGameGroup(Request request) async {
    try {
      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      GameConfig config = GameConfig.fromJson(data['config']);
      String creator = data['creator'];
      final _result = gameServer().createGameGroup(creator: creator, config: config);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!);
      } else {
        return HttpUtils.buildResponse(data: {
          'group': _result.object!.toMap(),
        });
      }
    } catch (e, s) {
      print('exception in createGameGroup: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> getGameGroup(Request request, String id) async {
    try {
      final _result = gameServer().getGroupController(id);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!);
      } else {
        return HttpUtils.buildResponse(data: {
          'group': _result.object!.toMap(),
        });
      }
    } catch (e, s) {
      print('exception in getGameGroup: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> joinGameGroup(Request request, String id) async {
    try {
      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      final _result = gameServer().joinGroup(id, data['player']);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!);
      } else {
        return HttpUtils.buildResponse(data: {
          'group': _result.object!.toMap(),
        });
      }
    } catch (e, s) {
      print('exception in joinGameGroup: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
