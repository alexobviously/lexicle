import 'dart:io';

import 'package:common/common.dart';
import 'package:dart_dotenv/dart_dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'handlers/auth_handler.dart';
import 'handlers/dictionary_handler.dart';
import 'handlers/game_handler.dart';
import 'handlers/game_server_handler.dart';
import 'handlers/status_handler.dart';
import 'services/environment.dart';
import 'services/mongo_service.dart';
import 'services/service_locator.dart';

Environment readEnvironment() {
  final dotEnv = DotEnv(filePath: '.env');
  if (!dotEnv.exists()) {
    dotEnv.createNew();
  }
  dotEnv.getDotEnv();

  String _getEnv(String key, [String def = '']) => Platform.environment[key] ?? dotEnv.get(key) ?? def;

  return Environment(
    port: int.parse(_getEnv('PORT', '8080')),
    mongoUser: _getEnv('MONGO_USER'),
    mongoPass: _getEnv('MONGO_PASS'),
    mongoDb: _getEnv('MONGO_DB'),
    mongoHost: _getEnv('MONGO_HOST'),
    jwtSecret: _getEnv('JWT_SECRET'),
  );
}

Future main() async {
  print('Reading .env...');
  final env = readEnvironment();
  print('Connecting to MongoDB...');
  final _db = MongoService();
  await _db.init(env);
  print('MongoDB ready!');
  await setUpServiceLocator(environment: env, db: _db);

  final _router = shelf_router.Router()
    ..get('/hello', _echoRequest)
    ..get('/', StatusHandler.serverStatus)
    ..get('/status', StatusHandler.serverStatus)
    ..get('/dict/<w>', DictionaryHandler.validateWord)
    ..get('/ws', gameServerHandler())
    ..post('/auth/register', AuthHandler.register)
    ..post('/auth/login', AuthHandler.login)
    ..get('/groups/all', GameHandler.allGroupIds)
    ..get('/groups/<id>', GameHandler.getGameGroup)
    ..post('/groups/create', GameHandler.createGameGroup)
    ..post('/groups/<id>/join', GameHandler.joinGameGroup)
    ..post('/groups/<id>/leave', GameHandler.leaveGameGroup)
    ..post('/groups/<id>/delete', GameHandler.deleteGameGroup)
    ..post('/groups/<id>/setword', GameHandler.setWord)
    ..post('/groups/<id>/start', GameHandler.startGroup)
    ..get('/games/all', GameHandler.allGameIds)
    ..get('/games/active', GameHandler.allActiveGameIds)
    ..get('/games/<id>', GameHandler.getGame)
    ..post('/games/<id>/guess', GameHandler.makeGuess);

  final cascade = Cascade().add(_router);

  final pipeline = Pipeline().addMiddleware(logRequests()).addMiddleware(corsHeaders()).addHandler(cascade.handler);

  final server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4, // Allows external connections
    env.port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request for "${request.url}"');
