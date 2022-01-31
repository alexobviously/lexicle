import 'package:common/common.dart';

abstract class DatabaseService {
  Future<Result<T>> get<T extends Entity>(String id);
  Future<Result<T>> write<T extends Entity>(T entity);
  Future<Result<bool>> delete<T extends Entity>(T entity);
}
