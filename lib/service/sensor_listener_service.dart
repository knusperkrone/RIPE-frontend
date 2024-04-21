import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:ripe/service/mixins/mqtt_client_service.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/util/log.dart';

typedef ConnectCallback = Function(MqttConnectionState);
typedef MessageCallback = Function(String);

class SensorListenerService extends MqttClientService {
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final RegisteredSensor _sensor;
  final BrokersDto _broker;

  SensorListenerService(this._sensor, this._broker);

  /*
   * Business methods
   */

  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
  }

  void connect({ConnectCallback? callback}) {
    final context = connectToBroker(_broker);
    final sub = context?.connectionController.stream.listen((state) {
      callback?.call(state);
    });
    if (context != null) {
      callback?.call(context.connectionState);
    }

    if (sub != null) {
      _subscriptions.add(sub);
    } else {
      Log.error('Could not subscribe to broker');
    }
  }

  void listenSensorCmd(MessageCallback callback) {
    final topic = 'sensor/cmd/${_sensor.id}/${_sensor.key}';
    _subscriptions.add(subscribe(_broker, topic)!.listen((e) => callback(e)));
  }

  void listenSensorData(MessageCallback callback) {
    final topic = 'sensor/data/${_sensor.id}/${_sensor.key}';
    _subscriptions.add(subscribe(_broker, topic)!.listen((e) => callback(e)));
  }

  void listenSensorLogs(MessageCallback callback) {
    final topic = 'sensor/log/${_sensor.id}/${_sensor.key}';
    _subscriptions.add(subscribe(_broker, topic)!.listen((e) => callback(e)));
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
