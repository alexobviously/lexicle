import 'dart:convert';

import 'package:common/common.dart';
import 'package:word_game/model/api_response.dart';
import 'package:rest_client/rest_client.dart' as rc;
import 'package:word_game/services/service_locator.dart';

typedef Unwrapper<T> = T Function(Map<String, dynamic> data);

class ApiClient {
  static String host = 'https://word-w7y24cao7q-ew.a.run.app'; //'http://localhost:8080';

  static Future<Result<List<String>>> allGroups() =>
      getAndUnwrap('/groups/all', unwrapper: (data) => coerceList(data['groups']));
  static Future<Result<GameGroup>> getGroup(String id) => getAndUnwrap('/groups/$id', unwrapper: unwrapGameGroup);
  static Future<Result<GameGroup>> createGroup(String creator, String title, GameConfig config) => postAndUnwrap(
        '/groups/create',
        body: {'creator': creator, 'title': title, 'config': config.toMap()},
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
  static Future<Result<bool>> deleteGroup(String id, String player) => postAndUnwrap(
        '/groups/$id/delete',
        body: {'player': player},
        unwrapper: (_) => true,
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
  static Future<Result<WordValidationResult>> makeGuess(String game, String guess) => postAndUnwrap(
        '/games/$game/guess',
        body: {'guess': guess},
        unwrapper: (data) => WordValidationResult.fromJson(data['result']),
      );

  static Future<ApiResult<User>> login(String username, String password) => postAndUnwrap(
        '/auth/login',
        body: {UserFields.username: username, UserFields.password: password},
        unwrapper: unwrapUser,
      );

  static Future<Result<bool>> validateWord(String word) =>
      getAndUnwrap('/dict/$word', unwrapper: (data) => data['valid']);

  static Map<Type, String Function(String)> getEndpoints = {
    Game: (id) => '/games/$id',
    GameGroup: (id) => '/groups/$id',
    User: (id) => '/users/$id',
  };

  static Map<Type, Function(Map<String, dynamic>)> unwrappers = {
    Game: (doc) => ApiClient.unwrapGame(doc),
    GameGroup: (doc) => ApiClient.unwrapGameGroup(doc),
    User: (doc) => ApiClient.unwrapUser(doc),
    AuthData: (doc) => AuthData.fromJson(doc), // not used
  };

  static T unwrap<T extends Entity>(Map<String, dynamic> doc) => unwrappers[T]!(doc);

  static Future<ApiResult<T>> getEntity<T extends Entity>(String id) async =>
      getAndUnwrap(getEndpoints[T]!(id), unwrapper: unwrap<T>);

  static Future<ApiResponse> get(String path, [bool needAuth = false]) async {
    try {
      Map<String, String> headers = {};
      if (needAuth) {
        if (auth().hasToken) {
          headers['Authorization'] = 'Bearer ${auth().token}';
        } else {
          return ApiResponse.error('unauthorised');
        }
      }

      final req = rc.Request(
        url: '$host$path',
        method: rc.RequestMethod.get,
        headers: headers,
      );
      final resp = await rc.Client().execute(request: req);
      if (resp.statusCode != 200) return ApiResponse.error('http_${resp.statusCode}');
      return parseBody(resp.body);
    } catch (e, s) {
      print('ApiClient.get($path), error $e\n$s');
      return ApiResponse.unknownError();
    }
  }

  static Future<ApiResponse> post(String path, {Map<String, dynamic> body = const {}, bool needAuth = false}) async {
    try {
      Map<String, String> headers = {};
      if (needAuth) {
        if (auth().hasToken) {
          headers['Authorization'] = 'Bearer ${auth().token}';
        } else {
          return ApiResponse.error('unauthorised');
        }
      }

      final req = rc.Request(
        url: '$host$path',
        method: rc.RequestMethod.post,
        body: jsonEncode(body),
        headers: headers,
      );
      final resp = await rc.Client().execute(request: req);
      if (resp.statusCode != 200) return ApiResponse.error('http_${resp.statusCode}');
      return parseBody(resp.body);
    } catch (e, s) {
      print('ApiClient.post($path), error $e\n$s');
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
    String? token = body['token'];
    if (body.containsKey('token')) body.remove('token');
    int? expiry = body['expiry'];
    if (body.containsKey('expiry')) body.remove('expiry');
    return ApiResponse(
      status,
      error: error,
      warnings: warnings,
      data: body,
      token: token,
      expiry: expiry,
    );
  }

  static ApiResult<T> unwrapResponse<T>(ApiResponse response, Unwrapper<T> unwrapper) {
    if (!response.ok) {
      return ApiResult.error(response.error!, response.warnings);
    }
    return ApiResult.ok(
      unwrapper(response.data),
      token: response.token,
      expiry: response.expiry,
      warnings: response.warnings,
    );
  }

  static Future<ApiResult<T>> getAndUnwrap<T>(String path, {required Unwrapper<T> unwrapper}) async =>
      unwrapResponse(await get(path), unwrapper);

  static Future<ApiResult<T>> postAndUnwrap<T>(
    String path, {
    required Unwrapper<T> unwrapper,
    Map<String, dynamic> body = const {},
  }) async =>
      unwrapResponse(await post(path, body: body), unwrapper);

  static GameGroup unwrapGameGroup(Map<String, dynamic> data) => GameGroup.fromJson(data['group']);
  static Game unwrapGame(Map<String, dynamic> data) => Game.fromJson(data['game']);
  static User unwrapUser(Map<String, dynamic> data) => User.fromJson(data['user']);
}
