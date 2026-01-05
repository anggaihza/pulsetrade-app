import 'dart:async';
import 'dart:convert';
import 'dart:io';


class SurveyWebSocketDataSource {
  const SurveyWebSocketDataSource(this.websocketUrl);

  final String websocketUrl;

  Stream<String> connect() async* {
    final uri = Uri.parse('$websocketUrl/survey');
    try {
      final socket = await WebSocket.connect(uri.toString());
      yield* socket.map((event) => event is List<int> ? utf8.decode(event) : event.toString());
    } catch (_) {
      // Swallow connection errors; caller can handle empty stream.
      yield* const Stream<String>.empty();
    }
  }
}
