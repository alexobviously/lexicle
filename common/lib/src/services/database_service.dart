import 'package:common/common.dart';

abstract class DatabaseService {
  Future<Result<T>> get<T extends Entity>(String id);
  Future<Result<T>> getByField<T extends Entity>(String field, dynamic value);
  Future<Result<T>> write<T extends Entity>(T entity);
  Future<Result<bool>> delete<T extends Entity>(T entity);
}
