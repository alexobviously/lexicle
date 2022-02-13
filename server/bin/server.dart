import 'dart:io';

import 'package:dart_dotenv/dart_dotenv.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:yaml/yaml.dart';

import 'handlers/admin_handler.dart';
import 'handlers/auth_handler.dart';
import 'handlers/dictionary_handler.dart';
import 'handlers/game_handler.dart';
import 'handlers/game_server_handler.dart';
import 'handlers/status_handler.dart';
import 'handlers/team_handler.dart';
import 'handlers/user_handler.dart';
import 'services/environment.dart';
import 'services/mongo_service.dart';
import 'services/service_locator.dart';

SecurityContext getSecurityContext() {
  // Bind with a secure HTTPS connection
  final chain = Platform.script.resolve('cert.pem').toFilePath();
  final key = Platform.script.resolve('key.pem').toFilePath();

  return SecurityContext()
    ..useCertificateChain(chain)
    ..usePrivateKey(key, password: '1234');
}

Environment readEnvironment() {
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync());
  String version = pubspec['version'] ?? '0.1.0';

  final dotEnv = DotEnv(filePath: '.env');
  if (!dotEnv.exists()) {
    dotEnv.createNew();
  }
  dotEnv.getDotEnv();

  String _getEnv(String key, [String def = '']) => Platform.environment[key] ?? dotEnv.get(key) ?? def;

  return Environment(
    version: version,
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
    ..get('/meta', StatusHandler.meta)
    ..get('/dict/<w>', DictionaryHandler.validateWord)
    ..get('/ws', gameServerHandler())
    ..post('/auth/register', AuthHandler.register)
    ..post('/auth/login', AuthHandler.login)
    ..post('/auth/change_pw', AuthHandler.changePassword)
    ..get('/users/me', UserHandler.getMe)
    ..get('/users/<id>', UserHandler.getUser)
    ..get('/stats/top_players', UserHandler.getTopPlayers)
    ..get('/ustats/me', UserHandler.getMyStats)
    ..get('/ustats/<id>', UserHandler.getStats)
    ..get('/groups/all', GameHandler.allGroupIds)
    ..post('/groups/create', GameHandler.createGameGroup)
    ..get('/groups/<id>', GameHandler.getGameGroup)
    ..post('/groups/<id>/join', GameHandler.joinGameGroup)
    ..post('/groups/<id>/leave', GameHandler.leaveGameGroup)
    ..post('/groups/<id>/kick', GameHandler.kickPlayer)
    ..post('/groups/<id>/delete', GameHandler.deleteGameGroup)
    ..post('/groups/<id>/setword', GameHandler.setWord)
    ..post('/groups/<id>/start', GameHandler.startGroup)
    ..get('/games/all', GameHandler.allGameIds)
    ..get('/games/active', GameHandler.allActiveGameIds)
    ..get('/games/<id>', GameHandler.getGame)
    ..post('/games/<id>/guess', GameHandler.makeGuess)
    ..get('/teams/all', TeamHandler.getAllTeams)
    ..post('/teams/create', TeamHandler.createTeam)
    ..get('/teams/<id>', TeamHandler.getTeam)
    ..post('/teams/<id>/join', TeamHandler.joinTeam)
    ..post('/teams/leave', TeamHandler.leaveTeam)
    ..post('/admin/change_pw', AdminHandler.changePassword);

  final cascade = Cascade().add(_router);

  final pipeline = Pipeline().addMiddleware(logRequests()).addMiddleware(corsHeaders()).addHandler(cascade.handler);

  final server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4, // Allows external connections
    env.port,
    // securityContext: getSecurityContext(),
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request for "${request.url}"');
