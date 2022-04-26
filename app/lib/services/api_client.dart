import 'dart:convert';

import 'package:common/common.dart';
import 'package:word_game/model/api_response.dart';
import 'package:rest_client/rest_client.dart' as rc;
import 'package:word_game/model/server_meta.dart';
import 'package:word_game/services/service_locator.dart';

typedef Unwrapper<T> = T Function(Map<String, dynamic> data);

class ApiClient {
  static String host = 'https://api.lexicle.xyz'; //'http://localhost:8080';

  static Future<ApiResult<ServerMeta>> getMeta() async => getAndUnwrap('/meta', unwrapper: unwrapServerMeta);
  static Future<ApiResult<User>> getUser(String id) => getAndUnwrap('/users/$id', unwrapper: unwrapUser);
  static Future<ApiResult<User>> getMe() =>
      getAndUnwrap('/users/me', unwrapper: unwrapUser, authType: AuthType.required);
  static Future<ApiResult<UserStats>> getMyStats() =>
      getAndUnwrap('/ustats/me', unwrapper: unwrapUserStats, authType: AuthType.required);

  static Future<Result<List<String>>> allGroups() => getAndUnwrap(
        '/groups/all',
        unwrapper: (data) => coerceList(data['groups']),
      );
  static Future<Result<List<GameGroup>>> availableGroups() => getAndUnwrap(
        '/groups/available',
        unwrapper: unwrapGroupList,
        authType: AuthType.optional,
      );
  static Future<Result<List<GameGroup>>> joinedGroups() => getAndUnwrap(
        '/groups/joined',
        unwrapper: unwrapGroupList,
        authType: AuthType.required,
      );
  static Future<Result<GameGroup>> getGroup(String id) => getAndUnwrap(
        '/groups/$id',
        unwrapper: unwrapGameGroup,
        authType: AuthType.optional,
      );
  static Future<Result<GameGroup>> createGroup(String creator, String title, GameConfig config) => postAndUnwrap(
        '/groups/create',
        body: {'creator': creator, 'title': title, 'config': config.toMap()},
        unwrapper: unwrapGameGroup,
        authType: AuthType.required,
      );
  static Future<Result<GameGroup>> joinGroup(String id, String player) => postAndUnwrap(
        '/groups/$id/join',
        body: {'player': player},
        unwrapper: unwrapGameGroup,
        authType: AuthType.required,
      );
  static Future<Result<GameGroup>> leaveGroup(String id, String player) => postAndUnwrap(
        '/groups/$id/leave',
        body: {'player': player},
        unwrapper: unwrapGameGroup,
        authType: AuthType.required,
      );
  static Future<Result<bool>> deleteGroup(String id, String player) => postAndUnwrap(
        '/groups/$id/delete',
        body: {'player': player},
        unwrapper: (_) => true,
        authType: AuthType.required,
      );
  static Future<ApiResult<GameGroup>> kickPlayer(String group, String player) async => postAndUnwrap(
        '/groups/$group/kick',
        body: {GameFields.player: player},
        unwrapper: unwrapGameGroup,
        authType: AuthType.required,
      );
  static Future<Result<GameGroup>> startGroup(String id) => postAndUnwrap(
        '/groups/$id/start',
        unwrapper: unwrapGameGroup,
        authType: AuthType.required,
      );
  static Future<Result<GameGroup>> setWord(String group, String player, String word) => postAndUnwrap(
        '/groups/$group/setword',
        body: {'player': player, 'word': word},
        unwrapper: unwrapGameGroup,
        authType: AuthType.required,
      );
  static Future<Result<Challenge>> getChallenge(int level, int sequence) => getAndUnwrap(
        '/challenges/$level/$sequence',
        unwrapper: unwrapChallenge,
      );
  static getChallengeAttempt(String challenge) => getAndUnwrap(
        '/challenges/$challenge/attempt',
        unwrapper: unwrapGame,
      );

  static Future<Result<List<String>>> allGames() =>
      getAndUnwrap('/games/all', unwrapper: (data) => coerceList(data['games']));
  static Future<Result<List<String>>> activeGames() =>
      getAndUnwrap('/games/active', unwrapper: (data) => coerceList(data['games']));

  static Future<Result<WordValidationResult>> makeGuess(String game, String guess) => postAndUnwrap(
        '/games/$game/guess',
        body: {'guess': guess},
        unwrapper: (data) => WordValidationResult.fromJson(data['result']),
        authType: AuthType.required,
      );

  static Future<ApiResult<User>> login(String username, String password) => postAndUnwrap(
        '/auth/login',
        body: {UserFields.username: username, UserFields.password: password},
        unwrapper: unwrapUser,
      );

  static Future<ApiResult<User>> register(String username, String password) => postAndUnwrap(
        '/auth/register',
        body: {UserFields.username: username, UserFields.password: password},
        unwrapper: unwrapUser,
      );

  static Future<ApiResult<bool>> changePassword(String oldPassword, String newPassword) async => postAndUnwrap(
        '/auth/change_pw',
        body: {'old': oldPassword, 'new': newPassword},
        unwrapper: (_) => true,
      );

  static Future<Result<bool>> validateWord(String word) =>
      getAndUnwrap('/dict/$word', unwrapper: (data) => data['valid']);

  static Future<Result<List<User>>> getTopPlayers() async => getAndUnwrap('/stats/top_players',
      unwrapper: (data) => data['users'].map<User>((e) => User.fromJson(e)).toList());

  static Future<ApiResult<User>> joinTeam(String id) async => postAndUnwrap(
        '/teams/$id/join',
        unwrapper: unwrapUser,
        authType: AuthType.required,
      );

  static Future<ApiResult<User>> leaveTeam() async => postAndUnwrap(
        '/teams/leave',
        unwrapper: unwrapUser,
        authType: AuthType.required,
      );

  static Map<Type, String Function(String)> getEndpoints = {
    Game: (id) => '/games/$id',
    GameGroup: (id) => '/groups/$id',
    User: (id) => '/users/$id',
    UserStats: (id) => '/ustats/$id',
    Team: (id) => '/teams/$id',
    Challenge: (id) => '/challenges/$id',
  };

  static Map<Type, Function(Map<String, dynamic>)> unwrappers = {
    Game: unwrapGame,
    GameGroup: unwrapGameGroup,
    User: unwrapUser,
    UserStats: unwrapUserStats,
    Team: unwrapTeam,
    AuthData: AuthData.fromJson, // not used
    Challenge: unwrapChallenge,
  };

  static T unwrap<T extends Entity>(Map<String, dynamic> doc) => unwrappers[T]!(doc);

  static Future<ApiResult<T>> getEntity<T extends Entity>(String id) async => getAndUnwrap(
        getEndpoints[T]!(id),
        unwrapper: unwrap<T>,
        authType: AuthType.optional,
      );

  static Future<ApiResponse> get(String path, [AuthType authType = AuthType.optional]) async {
    try {
      Map<String, String> headers = {};
      if (authType != AuthType.none) {
        if (auth().hasToken) {
          headers['Authorization'] = 'Bearer ${auth().token}';
        } else if (authType != AuthType.optional) {
          return ApiResponse.error(Errors.unauthorised);
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

  static Future<ApiResponse> post(
    String path, {
    Map<String, dynamic> body = const {},
    AuthType authType = AuthType.optional,
  }) async {
    try {
      Map<String, String> headers = {};
      if (authType != AuthType.none) {
        if (auth().hasToken) {
          headers['Authorization'] = 'Bearer ${auth().token}';
        } else if (authType != AuthType.optional) {
          return ApiResponse.error(Errors.unauthorised);
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
    if (token != null && expiry != null) {
      // the server will occasionally issue new tokens if they expire
      auth().updateToken(token, expiry);
    }
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

  static Future<ApiResult<T>> getAndUnwrap<T>(
    String path, {
    required Unwrapper<T> unwrapper,
    AuthType authType = AuthType.optional,
  }) async =>
      unwrapResponse(await get(path, authType), unwrapper);

  static Future<ApiResult<T>> postAndUnwrap<T>(
    String path, {
    required Unwrapper<T> unwrapper,
    Map<String, dynamic> body = const {},
    AuthType authType = AuthType.optional,
  }) async =>
      unwrapResponse(await post(path, body: body, authType: authType), unwrapper);

  static GameGroup unwrapGameGroup(Map<String, dynamic> data) => GameGroup.fromJson(data['group']);
  static Game unwrapGame(Map<String, dynamic> data) => Game.fromJson(data['game']);
  static User unwrapUser(Map<String, dynamic> data) => User.fromJson(data['user']);
  static UserStats unwrapUserStats(Map<String, dynamic> data) => UserStats.fromJson(data['stats']);
  static Team unwrapTeam(Map<String, dynamic> data) => Team.fromJson(data['team']);
  static Challenge unwrapChallenge(Map<String, dynamic> data) => Challenge.fromJson(data['challenge']);
  static ServerMeta unwrapServerMeta(Map<String, dynamic> data) => ServerMeta.fromJson(data);
  static List<T> unwrapList<T>(List<Map<String, dynamic>> data, Unwrapper unwrapper) =>
      data.map<T>((e) => unwrapper(e)).toList();
  static List<GameGroup> unwrapGroupList(Map<String, dynamic> data) =>
      unwrapList<GameGroup>(coerceList<Map<String, dynamic>>(data['groups']), (data) => GameGroup.fromJson(data));
}

enum AuthType {
  none,
  optional,
  required,
}
