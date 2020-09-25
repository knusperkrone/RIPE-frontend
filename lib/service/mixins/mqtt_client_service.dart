import 'dart:collection';
import 'dart:convert' show utf8;

import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

typedef MqttReceiveFunc = void Function(String);

abstract class MqttClientService {
  static const _BASE_URL = 'retroapp.if-lab.de';

  static final _observers = new HashMap<String, List<MqttReceiveFunc>>();
  static bool _isOfflineMode = false;
  static MqttClient client;

  static Future<bool> init() async {
    if (client == null || !isConnected()) {
      if (client == null) {
        final MqttConnectMessage connMess = MqttConnectMessage()
            .withClientIdentifier('_APP_')
            .keepAliveFor(20)
            .withWillQos(MqttQos.exactlyOnce);
        client = MqttServerClient(_BASE_URL, '_APP_');
        client.connectionMessage = connMess;
        client.keepAlivePeriod = 20;
        client.onConnected = _onConnect;
        client.onDisconnected = _onDisconnect;
      }

      try {
        await client.connect();
      } catch (error) {
        print(error);
        return false;
      }

      client.updates.listen((List<MqttReceivedMessage<MqttMessage>> msgBuffer) {
        for (final msg in msgBuffer) {
          final topic = msg.topic;
          final recMess = msg.payload as MqttPublishMessage;
          final String payload =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          final observers = _observers[topic];
          if (observers == null) {
            print('No observer for $topic - $payload');
          } else {
            for (final observer in observers) {
              observer(payload);
            }
          }
        }
      });
    }
    return true;
  }

  /*
   * Static init methods
   */

  static void _onConnect() {
    // Resubscribe
    print('[INFO] MQTT connected');
    for (final topic in _observers.keys) {
      final status = client.getSubscriptionsStatus(topic);
      if (status == MqttSubscriptionStatus.doesNotExist) {
        client.subscribe(topic, MqttQos.atMostOnce);
      }
    }
  }

  static void _onDisconnect() {
    print('[ERROR] MQTT disconnected');
  }

  /*
   * Static helper method
   */

  static Uint8Buffer _toPayload(String payload) {
    final bytes = utf8.encode(payload);
    final buffer = new Uint8Buffer(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      buffer[i] = bytes[i];
    }
    return buffer;
  }

  /*
   * Class Methods
   */

  static bool isOfflineMode() {
    return _isOfflineMode;
  }

  static void setOfflineMode([bool isOffline = true]) {
    _isOfflineMode = isOffline;
  }

  static bool isConnected() {
    if (client != null) {
      final state = client.connectionStatus.state;
      return state == MqttConnectionState.connected;
    }
    return false;
  }

  @protected
  void subscribe(String topic, MqttReceiveFunc recFunc) {
    if (_isOfflineMode) {
      return;
    }

    if (_observers[topic] == null) {
      _observers[topic] = [];
    }

    _observers[topic].add(recFunc);
    if (_observers[topic].length == 1) {
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  @protected
  void unsubscribe(String topic) {
    if (!_isOfflineMode) {
      client.unsubscribe(topic);
    }
  }

  @protected
  void publish(String topic, String data) {
    if (!_isOfflineMode) {
      client.publishMessage(topic, MqttQos.exactlyOnce, _toPayload(data));
    }
  }
}
