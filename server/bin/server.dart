import 'dart:io';

import 'package:dart_dotenv/dart_dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'handlers/dictionary_handler.dart';
import 'handlers/game_handler.dart';
import 'handlers/game_server_handler.dart';
import 'handlers/status_handler.dart';
import 'services/environment.dart';
import 'services/service_locator.dart';

Environment readEnvironment() {
  final dotEnv = DotEnv(filePath: '.env');
  print(dotEnv.getDotEnv());
  if (!dotEnv.exists()) {
    dotEnv.createNew();
  }
  return Environment(
    port: int.parse(dotEnv.get('PORT') ?? '8080'),
    mongoUser: dotEnv.get('MONGO_USER') ?? '',
    mongoPass: dotEnv.get('MONGO_PASS') ?? '',
  );
}

Future main() async {
  final env = readEnvironment();
  await setUpServiceLocator(environment: env);

  final _router = shelf_router.Router()
    ..get('/hello', _echoRequest)
    ..get('/', StatusHandler.serverStatus)
    ..get('/status', StatusHandler.serverStatus)
    ..get('/dict/<w>', DictionaryHandler.validateWord)
    ..get('/ws', gameServerHandler())
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

  print('env: ${env.port} ${env.mongoUser} ${env.mongoPass}');

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request for "${request.url}"');
