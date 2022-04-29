import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class DatabaseService {
  Future<Result<T>> get<T extends Entity>(String id);
  Future<Result<T>> getByField<T extends Entity>(String field, dynamic value);
  Future<List<T>> getAll<T extends Entity>({SelectorBuilder? selector});
  Future<List<T>> getAllByField<T extends Entity>(String field, dynamic value);
  Future<Result<T>> getOne<T extends Entity>({SelectorBuilder? selector});
  Future<Result<T>> write<T extends Entity>(T entity);
  Future<Result<bool>> delete<T extends Entity>(T entity);

  Future<Result<Challenge>> getCurrentChallenge(int level, [bool returnFinished = false]);
  Future<Result<Challenge>> getChallenge(int level, int sequence);
  Future<Result<Game>> getChallengeAttempt(String player, String challenge);
}
