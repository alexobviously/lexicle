import 'dart:convert';

import 'package:common/common.dart';
import 'package:word_game/model/api_response.dart';
import 'package:rest_client/rest_client.dart' as rc;

typedef Unwrapper<T> = T Function(Map<String, dynamic> data);

class ApiClient {
  // todo: put this in .env
  static const String host = 'http://localhost:8080';

  static Future<Result<List<String>>> allGroups() =>
      getAndUnwrap('/groups/all', unwrapper: (data) => coerceList(data['groups']));
  static Future<Result<GameGroup>> getGroup(String id) => getAndUnwrap('/groups/$id', unwrapper: unwrapGameGroup);
  static Future<Result<GameGroup>> createGroup(String creator, GameConfig config) => postAndUnwrap(
        '/groups/create',
        body: {'creator': creator, 'config': config.toMap()},
        unwrapper: unwrapGameGroup,
      );
  static Future<Result<GameGroup>> joinGroup(String id, String player) => postAndUnwrap(
        '/groups/$id/join',
        body: {'player': player},
        unwrapper: unwrapGameGroup,
      );
  static Future<Result<GameGroup>> leaveGroup(String id, String player) => postAndUnwrap(
        '/groups/$id/leave',
        body: {'player': player},
        unwrapper: unwrapGameGroup,
      );
  static Future<Result<GameGroup>> startGroup(String id) =>
      postAndUnwrap('/groups/$id/start', unwrapper: unwrapGameGroup);
  static Future<Result<GameGroup>> setWord(String group, String player, String word) => postAndUnwrap(
        '/groups/$group/setword',
        body: {'player': player, 'word': word},
        unwrapper: unwrapGameGroup,
      );

  static Future<Result<List<String>>> allGames() =>
      getAndUnwrap('/games/all', unwrapper: (data) => coerceList(data['games']));
  static Future<Result<List<String>>> activeGames() =>
      getAndUnwrap('/games/active', unwrapper: (data) => coerceList(data['games']));
  static Future<Result<Game>> getGame(String id) => getAndUnwrap('/games/$id', unwrapper: unwrapGame);
  static Future<Result<Game>> makeGuess(String game, String guess) => postAndUnwrap(
        '/games/$game/guess',
        body: {'guess': guess},
        unwrapper: unwrapGame,
      );

  static Future<ApiResponse> get(String path) async {
    try {
      final req = rc.Request(
        url: '$host$path',
        method: rc.RequestMethod.get,
      );
      final resp = await rc.Client().execute(request: req);
      if (resp.statusCode != 200) return ApiResponse.error('http_${resp.statusCode}');
      return parseBody(resp.body);
    } catch (e, _) {
      return ApiResponse.unknownError();
    }
  }

  static Future<ApiResponse> post(String path, [Map<String, dynamic> body = const {}]) async {
    try {
      final req = rc.Request(
        url: '$host$path',
        method: rc.RequestMethod.post,
        body: jsonEncode(body),
      );
      final resp = await rc.Client().execute(request: req);
      if (resp.statusCode != 204) return ApiResponse.error('http_${resp.statusCode}');
      return parseBody(resp.body);
    } catch (e, _) {
      return ApiResponse.unknownError();
    }
  }

  static ApiResponse parseBody(Map<String, dynamic> body) {
    if (!body.containsKey('status') || body['status'] is! String) return ApiResponse.unknownError();
    String status = body['status'];
    body.remove('status');
    String? error = body['error'];
    if (body.containsKey('error')) body.remove('error');
    List<String> warnings = body['warnings'] ?? [];
    if (body.containsKey('warnings')) body.remove('warnings');
    return ApiResponse(
      status,
      error: error,
      warnings: warnings,
      data: body,
    );
  }

  static Result<T> unwrapResponse<T>(ApiResponse response, Unwrapper<T> unwrapper) {
    if (!response.ok) {
      return Result.error(response.error!, response.warnings);
    }
    return Result.ok(unwrapper(response.data));
  }

  static Future<Result<T>> getAndUnwrap<T>(String path, {required Unwrapper<T> unwrapper}) async =>
      unwrapResponse(await get(path), unwrapper);

  static Future<Result<T>> postAndUnwrap<T>(
    String path, {
    required Unwrapper<T> unwrapper,
    Map<String, dynamic> body = const {},
  }) async =>
      unwrapResponse(await post(path, body), unwrapper);

  static GameGroup unwrapGameGroup(Map<String, dynamic> data) => GameGroup.fromJson(data['group']);
  static Game unwrapGame(Map<String, dynamic> data) => Game.fromJson(data['game']);
}
