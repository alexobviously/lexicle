import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'handlers/dictionary_handler.dart';
import 'handlers/game_server_handler.dart';
import 'services/service_locator.dart';

Future main() async {
  await setUpServiceLocator();
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  final _router = shelf_router.Router()
    ..get('/hello', _echoRequest)
    ..get('/dict/<w>', DictionaryHandler.validateWord)
    ..get('/ws', gameServerHandler());
  final cascade = Cascade().add(_router);

  final pipeline = Pipeline().addMiddleware(logRequests()).addMiddleware(corsHeaders()).addHandler(cascade.handler);

  final server = await shelf_io.serve(
    pipeline,
    InternetAddress.anyIPv4, // Allows external connections
    port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request for "${request.url}"');
