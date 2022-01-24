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

  static Future<Response> leaveGameGroup(Request request, String id) async {
    try {
      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      final _result = gameServer().leaveGroup(id, data['player']);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!);
      } else {
        return HttpUtils.buildResponse(data: {
          'group': _result.object!.toMap(),
        });
      }
    } catch (e, s) {
      print('exception in leaveGameGroup: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> setWord(Request request, String id) async {
    try {
      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      final _result = gameServer().setWord(id, data['player'], data['word']);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!);
      } else {
        return HttpUtils.buildResponse(data: {
          'group': _result.object!.toMap(),
        });
      }
    } catch (e, s) {
      print('exception in setWord: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> startGroup(Request request, String id) async {
    try {
      // TODO: authenticate this
      final _result = gameServer().startGroup(id);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!, _result.warnings);
      } else {
        return HttpUtils.buildResponse(data: {
          'group': _result.object!.toMap(),
        });
      }
    } catch (e, s) {
      print('exception in startGroup: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> allGroupIds(Request request) async {
    List<String> allIds = gameServer().getAllGroupIds();
    return HttpUtils.buildResponse(data: {
      'count': allIds.length,
      'groups': allIds,
    });
  }

  static Future<Response> allGameIds(Request request) async {
    List<String> allIds = gameServer().getAllGameIds();
    return HttpUtils.buildResponse(data: {
      'count': allIds.length,
      'games': allIds,
    });
  }

  static Future<Response> allActiveGameIds(Request request) async {
    List<String> allIds = gameServer().getAllActiveGameIds();
    return HttpUtils.buildResponse(data: {
      'count': allIds.length,
      'games': allIds,
    });
  }

  static Future<Response> getGame(Request request, String id) async {
    try {
      final _result = gameServer().getGameController(id);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!);
      } else {
        return HttpUtils.buildResponse(data: {
          'game': _result.object!.toMap(hideAnswer: true),
        });
      }
    } catch (e, s) {
      print('exception in getGame: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }

  static Future<Response> makeGuess(Request request, String id) async {
    try {
      final String payload = await request.readAsString();
      Map<String, dynamic> data = json.decode(payload);
      final _result = await gameServer().makeGuess(id, data['guess']);
      if (!_result.ok) {
        return HttpUtils.buildErrorResponse(_result.error!);
      } else {
        return HttpUtils.buildResponse(data: {
          'game': _result.object!.toMap(hideAnswer: true),
        });
      }
    } catch (e, s) {
      print('exception in makeGuess: $e\n$s');
      return HttpUtils.invalidRequestResponse();
    }
  }
}
