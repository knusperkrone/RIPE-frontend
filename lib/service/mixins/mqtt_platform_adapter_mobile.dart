import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:tuple/tuple.dart';

Tuple2<String, int?> _splitURI(String rawString) {
  final splitIndex = rawString.lastIndexOf(':');
  if (splitIndex > 'https:'.length) {
    final uri = rawString.substring(0, splitIndex);
    final port = int.parse(rawString.substring(splitIndex + 1));
    return new Tuple2(uri, port);
  }
  return new Tuple2(rawString, null);
}

MqttClient createMqttClient(
    BrokerDto broker, String id, MqttConnectMessage connMess) {
  final uri = _splitURI(broker.tcp!.substring('tcp://'.length));
  return new MqttServerClient.withPort(uri.item1, id, uri.item2 ?? 1883)
    ..secure = false
    ..connectionMessage = connMess
    ..logging(on: false)
    ..keepAlivePeriod = 20;
}
