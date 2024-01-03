import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

List<String> getSupportedSchemes() => ['tcp', 'wss'];

MqttClient createMqttClient(Uri uri, String id, MqttConnectMessage connMess) {
  return new MqttServerClient.withPort(uri.host, id, uri.port)
    ..useWebSocket = uri.isScheme('wss')
    ..connectionMessage = connMess
    ..logging(on: false)
    ..keepAlivePeriod = 20;
}
