import 'package:common/common.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:validators/validators.dart';
import 'environment.dart';

class MongoService implements DatabaseService {
  late Db db;
  Future<void> init(Environment env) async {
    String connStr =
        'mongodb+srv://${env.mongoUser}:${env.mongoPass}@${env.mongoHost}/${env.mongoDb}?retryWrites=true&w=majority';
    db = await Db.create(connStr);
    await connected;
  }

  Future<void> get connected async {
    while (db.state == State.OPENING) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    if (db.isConnected) return;
    await db.close();
    await db.open();
    return;
  }

  @override
  Future<Result<T>> get<T extends Entity>(String id) async {
    if (!isMongoId(id)) return Result.error('invalid_id');
    await connected;
    final coll = db.collection(Entity.table(T));
    final doc = await coll.findOne(where.id(ObjectId.fromHexString(id)));
    if (doc == null) {
      return Result.error(Errors.notFound);
    } else {
      ObjectId? objectId = doc['_id'];
      doc['id'] = objectId?.id.hexString;
      return Result.ok(Entity.build<T>(doc));
    }
  }

  @override
  Future<List<T>> getAll<T extends Entity>({SelectorBuilder? selector}) async {
    await connected;
    final coll = db.collection(Entity.table(T));
    List<Map<String, dynamic>> results = await coll.find(selector).toList();
    List<T> entities = [];
    for (Map<String, dynamic> d in results) {
      ObjectId? objectId = d['_id'];
      d['id'] = objectId?.id.hexString;
      entities.add(Entity.build<T>(d));
    }
    return entities;
  }

  @override
  Future<List<T>> getAllByField<T extends Entity>(String field, dynamic value) async {
    SelectorBuilder selector = where.eq(field, value);
    return getAll<T>(selector: selector);
  }

  @override
  Future<Result<T>> getByField<T extends Entity>(String field, dynamic value) async {
    await connected;
    final coll = db.collection(Entity.table(T));
    final doc = await coll.findOne(where.eq(field, value));
    if (doc == null) {
      return Result.error(Errors.notFound);
    } else {
      ObjectId? objectId = doc['_id'];
      doc['id'] = objectId?.id.hexString;
      return Result.ok(Entity.build<T>(doc));
    }
  }

  @override
  Future<Result<T>> write<T extends Entity>(T entity) async {
    if (!isMongoId(entity.id)) return Result.error('invalid_id');
    Map<String, dynamic> data = entity.export();
    ObjectId id = ObjectId.fromHexString(data['id']);
    await connected;
    data.remove('id');
    data['_id'] = id;
    final coll = db.collection(Entity.table(T));
    final _result = await coll.replaceOne(where.id(id), data, upsert: true);
    if (_result.hasWriteErrors) {
      return Result.error('write_error');
    }
    return Result.ok(entity);
  }

  @override
  Future<Result<bool>> delete<T extends Entity>(T entity) async {
    if (!isMongoId(entity.id)) return Result.error('invalid_id');
    await connected;
    final coll = db.collection(Entity.table(T));
    final result = await coll.deleteOne(where.id(ObjectId.fromHexString(entity.id)));
    if (result.isSuccess) {
      return Result.ok(true);
    } else {
      return Result.error('write_error');
    }
  }

  @override
  Future<Challenge?> getCurrentChallenge(int level) async {
    final selector = where.eq(ChallengeFields.level, level).sortBy(Fields.timestamp, descending: true).limit(1);
    final r = await getAll<Challenge>(selector: selector);
    return (r.isNotEmpty && !r.first.finished) ? r.first : null;
  }
}
