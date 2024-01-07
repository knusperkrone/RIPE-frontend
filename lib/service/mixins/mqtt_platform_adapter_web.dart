import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ripe/service/models/dto.dart';

List<String> getSupportedSchemes() => ['wss'];

MqttClient createMqttClient(
  BrokerConnectionDetailsDto broker,
  String id,
  MqttConnectMessage connMess,
) {
  final wssServer = '${broker.scheme}://${broker.host}';
  final client = MqttBrowserClient.withPort(wssServer, id, broker.port)
    ..connectionMessage = connMess
    ..logging(on: false)
    ..doAutoReconnect(force: false)
    ..keepAlivePeriod = 20;


  if (broker.credentials != null) {

  }

  return client;
}
