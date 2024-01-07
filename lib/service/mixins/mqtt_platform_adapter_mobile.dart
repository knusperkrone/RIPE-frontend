import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:ripe/service/models/dto.dart';

List<String> getSupportedSchemes() => ['tcp', 'wss'];

MqttClient createMqttClient(
  BrokerConnectionDetailsDto broker,
  String id,
  MqttConnectMessage connMess,
) {
  if (broker.scheme == 'tcp') {
    return new MqttServerClient(broker.host, id)
      ..port = broker.port
      ..connectionMessage = connMess
      ..logging(on: false)
      ..keepAlivePeriod = 20;
  }
  final wssServer = '${broker.scheme}://${broker.host}';
  return new MqttServerClient.withPort(wssServer, id, broker.port)
    ..useWebSocket = true
    ..connectionMessage = connMess
    ..logging(on: false)
    ..keepAlivePeriod = 20;
}
