import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Handler gameServerHandler() {
  return webSocketHandler(
    (WebSocketChannel socket) {
      socket.stream.listen(
        (message) async {
          socket.sink.add("echo $message");
        },
      );
    },
    pingInterval: Duration(seconds: 10),
  );
}
