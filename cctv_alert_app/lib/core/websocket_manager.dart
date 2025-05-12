import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  final WebSocketChannel channel;
  WebSocketManager(this.channel);

  Stream<String> listen() {
    return channel.stream.map((message) => message as String);
  }

  void send(String message) {
    channel.sink.add(message);
  }

  void close() {
    channel.sink.close();
  }

  void reconnect(String url, Function onReconnect) {
    close();
    Future.delayed(const Duration(seconds: 3), () {
      onReconnect();
    });
  }
}
