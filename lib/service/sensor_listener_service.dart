import 'package:flutter/cupertino.dart';
import 'package:ripe/service/mixins/mqtt_client_service.dart';
import 'package:ripe/service/models/dto.dart';

void _noOp() {}

class SensorListenerService extends MqttClientService {
  final Set<String> _subscribedTopics = {};
  final BrokersDto _broker;
  VoidCallback? _onConnect;
  VoidCallback? _onDisconnect;

  SensorListenerService(this._broker);

  /*
   * Business methods
   */

  Future<void> connect(
      {VoidCallback onDisconnect = _noOp,
      VoidCallback onConnect = _noOp}) async {
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
      _subscribedTopics.forEach((t) => unsubscribe(_broker, t));
    }
  }

  void listenSensorData(int id, String key, VoidCallback callback) {
    for (final topic in ['sensor/cmd/$id/$key', 'sensor/data/$id/$key']) {
      _subscribedTopics.add(topic);
      subscribe(_broker, topic, (dynamic _) => callback());
    }
  }

  void unlistenSensorData(int id, String key) {
    for (final topic in ['sensor/cmd/$id/$key', 'sensor/data/$id/$key']) {
      _subscribedTopics.remove(topic);
      unsubscribe(_broker, topic);
    }
  }

  void listenSensorLogs(int id, String key, VoidCallback callback) {
    final topic = 'sensor/log/$id/$key';
    _subscribedTopics.add(topic);
    subscribe(_broker, topic, (dynamic _) => callback());
  }

  void unlistenSensorLogs(int id, String key) {
    final topic = 'sensor/log/$id/$key';
    _subscribedTopics.remove(topic);
    unsubscribe(_broker, topic);
  }

  /*
   * equality
   */

  @override
  int get hashCode {
    return _broker.hashCode + _onConnect.hashCode + _onDisconnect.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is SensorListenerService) {
      return hashCode == other.hashCode;
    }
    return false;
  }
}
