import 'package:flutter/cupertino.dart';
import 'package:ripe/service/mixins/mqtt_client_service.dart';

void _NoOp() {}

class SensorListenerService extends MqttClientService {
  late String _broker;
  Set<String> topics = {};
  VoidCallback? _onConnect;
  VoidCallback? _onDisconnect;

  SensorListenerService(String broker) {
    if (broker.startsWith('tcp://')) {
      broker = broker.substring('tcp://'.length);
    }
    _broker = broker;
  }

  /*
   * Business methods
   */

  Future<void> connect(
      {required VoidCallback onDisconnect,
      VoidCallback onConnect = _NoOp}) async {
    dispose(); // Remove old callback first
    _onConnect = onConnect;
    _onDisconnect = onDisconnect;
    await listenFromBroker(_broker, onConnect, onDisconnect);
  }

  void reconnect() {
    if (_onConnect != null && _onDisconnect != null) {
      listenFromBroker(_broker, _onConnect!, _onDisconnect!);
    }
  }

  void dispose() {
    if (_onConnect != null && _onDisconnect != null) {
      unlistenFromBroker(_broker, _onConnect!, _onDisconnect!);
      topics.forEach((topic) => unsubscribe(_broker, topic));
    }
  }

  void listenSensorData(int id, String key, VoidCallback callback) {
    for (final topic in ['sensor/cmd/$id/$key', 'sensor/data/$id/$key']) {
      topics.add(topic);
      subscribe(_broker, topic, (dynamic _) => callback());
    }
  }

  void unlistenSensorData(int id, String key) {
    for (final topic in ['sensor/cmd/$id/$key', 'sensor/data/$id/$key']) {
      topics.remove(topic);
      unsubscribe(_broker, topic);
    }
  }

  void listenSensorLogs(int id, String key, VoidCallback callback) {
    final topic = 'sensor/log/$id/$key';
    topics.add(topic);
    subscribe(_broker, topic, (dynamic _) => callback());
  }

  void unlistenSensorLogs(int id, String key) {
    final topic = 'sensor/log/$id/$key';
    topics.remove(topic);
    unsubscribe(_broker, topic);
  }

  /*
   * equality
   */

  @override
  int get hashCode {
    return _broker.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is SensorListenerService) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}
