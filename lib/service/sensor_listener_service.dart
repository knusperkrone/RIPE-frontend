import 'package:flutter/cupertino.dart';
import 'package:ripe/service/mixins/mqtt_client_service.dart';

class SensorListenerService extends MqttClientService {
  static final Map<String, SensorListenerService> _services = {};

  final _subscribed = <String>[];
  final String _broker;

  /*
   * Flyweight constructor
   */

  factory SensorListenerService(String broker) {
    // trim front
    if (broker.startsWith('tcp://')) {
      broker = broker.substring('tcp://'.length);
    }
    // trim end
    if (broker.contains(':')) {
      broker = broker.substring(0, broker.indexOf(':'));
    }

    if (_services[broker] == null) {
      _services[broker] = new SensorListenerService._internal(broker);
    }
    return _services[broker]!;
  }

  SensorListenerService._internal(this._broker);

  /*
   * Business methods
   */

  Future<void> connect() async {
    await MqttClientService.connect(_broker);
  }

  void listenSensor(int id, String key, VoidCallback callback) {
    for (final topic in _buildTopics(id, key)) {
      _subscribed.add(topic);
      subscribe(_broker, topic, (dynamic _) => callback());
    }
  }

  void dispose() {
    _subscribed.forEach((t) => unsubscribe(_broker, t));
    _subscribed.clear();
  }

  List<String> _buildTopics(int id, String key) {
    return ['sensor/cmd/$id/$key', 'sensor/data/$id/$key'];
  }
}
