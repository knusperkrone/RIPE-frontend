import 'package:flutter/cupertino.dart';
import 'package:iftem/service/mixins/mqtt_client_service.dart';

class SensorListenerService extends MqttClientService {
  final _subscribed = <String>[];

  void listenSensor(int id, String key, VoidCallback callback) {
    final topic = _buildTopic(id, key);
    _subscribed.add(topic);
    subscribe(topic, (dynamic _) => callback());
  }

  void dispose() {
    _subscribed.forEach(unsubscribe);
    _subscribed.clear();
  }

  String _buildTopic(int id, String key) {
    return 'sensor/cmd/$id/$key';
  }
}
