import 'package:common/common.dart';

class EntityStore<T extends Entity> {
  final DatabaseService db;
  EntityStore(this.db);

  Map<String, T> items = {};
  Set<String> cache = {};

  Future<Result<T>> get(String id) async {
    if (items.containsKey(id)) return Result.ok(items[id]!);

    Result<T> result = await db.get<T>(id);
    if (result.ok) onGet(result.object!);
    return result;
  }

  Result<T> getLocal(String id) => items.containsKey(id) ? Result.ok(items[id]!) : Result.error('not_found');

  Future<void> onGet(T entity) async {
    items[entity.id] = entity;
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

  Future<Result<T>> set(T entity, [bool forceWrite = false]) async {
    if (forceWrite) return write(entity);
    onGet(entity);
    cache.add(entity.id);
    return Result.ok(entity);
  }

  Future<Result<T>> write(T entity) async {
    Result<T> result = await db.write<T>(entity);
    if (result.ok) {
      onGet(entity);
      cache.remove(entity.id);
    }
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

  Future<Result<Iterable<String>>> pushCache() async {
    Set<String> updated = {};
    List<Future> futures = [];
    for (String id in cache) {
      final res = getLocal(id);
      if (res.ok) {
        futures.add(
          write(res.object!).then((v) {
            if (v.ok) updated.add(id);
          }),
        );
      } else {
        cache.remove(id);
      }
    }
    await Future.wait(futures);
    return Result.ok(updated);
  }
}
