import 'package:common/common.dart';
import 'package:mongo_dart_query/mongo_dart_query.dart';
import 'package:word_game/services/api_client.dart';

class ApiService implements DatabaseService {
  @override
  Future<Result<bool>> delete<T extends Entity>(T entity) async {
    return Result.error('cant_delete');
  }

  @override
  Future<Result<T>> get<T extends Entity>(String id) async {
    final _result = await ApiClient.getEntity<T>(id);
    return _result;
  }

  @override
  Future<Result<T>> getByField<T extends Entity>(String field, value) {
    // TODO: implement getByField
    throw UnimplementedError();
  }

  @override
  Future<Result<T>> write<T extends Entity>(T entity) async {
    return Result.error('cant_write');
  }

  @override
  Future<List<T>> getAll<T extends Entity>({SelectorBuilder? selector}) {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<List<T>> getAllByField<T extends Entity>(String field, value) {
    // TODO: implement getAllByField
    throw UnimplementedError();
  }

  @override
  Future<Result<Challenge>> getCurrentChallenge(int level) async => get<Challenge>(level.toString());

  @override
  Future<Result<Challenge>> getChallenge(int level, int sequence) async => ApiClient.getChallenge(level, sequence);

  @override
  Future<Result<Game>> getChallengeAttempt(String player, String challenge) async =>
      ApiClient.getChallengeAttempt(challenge);

  @override
  Future<Result<T>> getOne<T extends Entity>({SelectorBuilder? selector}) {
    // TODO: implement getOne
    throw UnimplementedError();
  }
}
