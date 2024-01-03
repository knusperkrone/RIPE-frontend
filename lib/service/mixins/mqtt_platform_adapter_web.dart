import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

List<String> getSupportedSchemes() => ['wss'];

MqttClient createMqttClient(Uri uri, String id, MqttConnectMessage connMess) {
  return new MqttBrowserClient.withPort(uri.host, id, uri.port)
    ..connectionMessage = connMess
    ..logging(on: false)
    ..keepAlivePeriod = 20;
}
