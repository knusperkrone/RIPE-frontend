import 'dart:collection';
import 'dart:convert' show utf8;

import 'package:meta/meta.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:ripe/util/log.dart';
import 'package:typed_data/typed_buffers.dart';

typedef MqttReceiveFunc = void Function(String);

class _MqttContext {
  final MqttServerClient client;
  final Map<String, List<MqttReceiveFunc>> callbacks = new HashMap();

  _MqttContext(this.client);

  void addCallback(String topic, MqttReceiveFunc callback) {
    if (callbacks[topic] == null) {
      callbacks[topic] = [];
    }
    callbacks[topic]!.add(callback);
    if (callbacks[topic]!.length == 1) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void removeCallback(String topic) {
    client.unsubscribe(topic);
    callbacks[topic]?.clear();
  }

  void reconnect() {
    for (final sub in callbacks.entries) {
      sub.value.forEach((callback) {
        addCallback(sub.key, callback);
      });
    }
  }

  void publish(String topic, String msg) {
    final bytes = utf8.encode(msg);
    final data = new Uint8Buffer(bytes.length);
    for (int i = 0; i < bytes.length; i++) {
      data[i] = bytes[i];
    }
    client.publishMessage(topic, MqttQos.atLeastOnce, data);
  }

  bool get isConnected =>
      client.connectionStatus?.state == MqttConnectionState.connected;
}

abstract class MqttClientService {
  static final Map<String, _MqttContext> _contexts = {}; // < BrokerUrl, Ctx>
  static bool _isOfflineMode = false;

  static Future<bool> connect(String broker) async {
    _MqttContext? ctx = _contexts[broker];

    if (ctx == null || !ctx.isConnected) {
      const id = '_APP_'; // TODO(knukro): generate
      final client = new MqttServerClient(broker, id);
      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(id)
          .withWillQos(MqttQos.exactlyOnce);
      client.connectionMessage = connMess;
      client.keepAlivePeriod = 20;
      client.onConnected = () => _onConnect;
      client.onDisconnected = () => _onDisconnect;

      if (!_isOfflineMode) {
        try {
          await client.connect();
        } catch (e) {
          Log.error('Failed connecting MQTT - $e');
          return false;
        }
      }

      ctx = new _MqttContext(client);
      client.updates!.listen((msg) => _listen(ctx!, msg));
      _contexts[broker] = ctx;
    }
    return true;
  }

  /*
   * Static init methods
   */

  static void _onConnect(String broker) {
    Log.debug('Connected to broker $broker');
    _contexts[broker]?.reconnect();
  }

  static void _onDisconnect(String broker) {
    Log.debug('Disconnected from broker $broker');
  }

  static void _listen(
      _MqttContext ctx, List<MqttReceivedMessage<MqttMessage>> msgBuffer) {
    for (final msg in msgBuffer) {
      final topic = msg.topic;
      final casted = (msg.payload as MqttPublishMessage).payload;
      final payload = MqttPublishPayload.bytesToStringAsString(casted.message!);

      final observers = ctx.callbacks[topic];
      if (observers == null) {
        Log.error('No observers for $topic with $payload');
      } else {
        for (final observer in observers) {
          observer(payload);
        }
      }
    }
  }

  /*
   * Class Methods
   */

  static bool isOfflineMode() {
    return _isOfflineMode;
  }

  static void setOfflineMode([bool isOffline = true]) {
    _isOfflineMode = isOffline;
    for (final ctx in _contexts.values) {
      if (isOffline) {
        ctx.client.disconnect();
      } else {
        ctx.client.connect();
      }
    }
  }

  @protected
  static bool isConnected(String broker) {
    return _contexts[broker]?.isConnected ?? false;
  }

  @protected
  void subscribe(String broker, String topic, MqttReceiveFunc recFunc) {
    if (!_isOfflineMode) {
      _contexts[broker]?.addCallback(topic, recFunc);
    }
  }

  @protected
  void unsubscribe(String broker, String topic) {
    if (!_isOfflineMode) {
      _contexts[broker]?.removeCallback(topic);
    }
  }

  @protected
  void publish(String broker, String topic, String data) {
    if (!_isOfflineMode) {
      _contexts[broker]?.publish(topic, data);
    }
  }
}
