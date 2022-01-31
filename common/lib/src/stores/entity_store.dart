import 'package:common/common.dart';

class EntityStore<T extends Entity> {
  final DatabaseService db;
  EntityStore(this.db);

  Map<String, T> items = {};

  Future<Result<T>> get(String id) async {
    if (items.containsKey(id)) return Result.ok(items[id]!);

    Result<T> result = await db.get<T>(id);
    if (result.ok) items[result.object!.id] = result.object!;
    return result;
  }

  Future<List<T>> getMultiple(List<String> ids) async {
    List<T> _items = [];
    for (String id in ids) {
      Result<T> result = await get(id);
      if (result.ok) _items.add(result.object!);
    }
    return _items;
  }

  List<T> getAllCached() => items.values.toList();

  Future<Result<T>> write(T entity) async {
    Result<T> result = await db.write<T>(entity);
    return result;
  }

  Future<Result<bool>> delete(T entity) async {
    final result = await db.delete<T>(entity);
    if (result.ok) {
      await onDelete(entity.id);
    }
    return result;
  }

  Future<void> onDelete(String id) async {
    items.remove(id);
  }
}
