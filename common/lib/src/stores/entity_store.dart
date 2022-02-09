import 'package:common/common.dart';

class EntityStore<T extends Entity> {
  final DatabaseService db;
  EntityStore(this.db);

  Map<String, T> items = {};
  Set<String> cache = {};

  int lastGotAll = 0;
  static const getAllInterval = 120000; // 2 minutes, for now

  Future<Result<T>> get(String id, [bool forceUpdate = false]) async {
    if (!forceUpdate && items.containsKey(id)) return Result.ok(items[id]!);

    Result<T> result = await db.get<T>(id);
    if (result.ok) onGet(result.object!);
    return result;
  }

  Result<T> getLocal(String id) => items.containsKey(id) ? Result.ok(items[id]!) : Result.error('not_found');
  Future<Result<T>> getRemote(String id) => get(id, true);

  Future<List<T>> getMultiple(List<String> ids, [bool forceUpdate = false]) async {
    List<Result<T>> results = await Future.wait(ids.map((e) => get(e, forceUpdate)));
    return results.map((e) => e.object).where((e) => e != null).map((e) => e!).toList();
  }

  /// Use with caution.
  Future<List<T>> getAll() async {
    if (lastGotAll > nowMs() - getAllInterval) {
      return getAllCached();
    }
    final all = await db.getAll<T>();
    for (T e in all) {
      onGet(e);
    }
    print(all.length);
    lastGotAll = nowMs();
    return all;
  }

  Future<Result<T>> getByField(String field, dynamic value) async {
    Result<T> result = await db.getByField<T>(field, value);
    if (result.ok) onGet(result.object!);
    return result;
  }

  Future<void> onGet(T entity) async {
    items[entity.id] = entity;
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
