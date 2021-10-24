import 'dart:collection';
import 'dart:convert' show utf8;
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:ripe/util/log.dart';
import 'package:typed_data/typed_buffers.dart';

typedef MqttReceiveFunc = void Function(String);

class _MqttContext {
  final MqttServerClient client;
  final Map<String, Set<MqttReceiveFunc>> callbacks = new HashMap();

  _MqttContext(this.client);

  void addCallback(String topic, MqttReceiveFunc callback) {
    if (callbacks[topic] == null) {
      callbacks[topic] = {};
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

  static Future<bool> connect(String broker, String server, int port) async {
    if (!kReleaseMode && Platform.isAndroid && broker == '127.0.0.1') {
      server = '10.0.2.2';
    }

    _MqttContext? ctx = _contexts[broker];
    if (ctx == null || !ctx.isConnected) {
      final id = generateUUID();
      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(id)
          .withWillQos(MqttQos.atLeastOnce);

      final client = new MqttServerClient(server, id)
        ..port = port
        ..secure = false
        ..connectionMessage = connMess
        ..logging(on: false)
        ..keepAlivePeriod = 20;
      client.onConnected = () => _onConnect;
      client.onDisconnected = () => _onDisconnect;

      if (!_isOfflineMode) {
        Log.debug('Connecting MQTT - ${client.server}:${client.port}');
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
    Log.info('Connected to broker $broker');
  }

  static void _onDisconnect(String broker) {
    Log.warn('Disconnected from broker $broker');
  }

  static void _listen(
      _MqttContext ctx, List<MqttReceivedMessage<MqttMessage>> msgBuffer) {
    for (final msg in msgBuffer) {
      final topic = msg.topic;
      final casted = (msg.payload as MqttPublishMessage).payload;
      final payload = MqttPublishPayload.bytesToStringAsString(casted.message);

      final observers = ctx.callbacks[topic];
      if (observers == null) {
        Log.error('No observers for $topic with $payload');
      } else {
        Log.debug('MQTT message for $topic');
        for (final observer in observers) {
          observer(payload);
        }
      }
    }
  }

  /*
   * Class Methods
   */

  static String generateUUID() {
    final rand = new Random();
    return 'APP${DateTime.now().toIso8601String()}-${rand.nextInt(4294967296)}-${rand.nextInt(4294967296)}';
  }

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
      Log.debug('Subscribed: $topic');
      _contexts[broker]?.addCallback(topic, recFunc);
    }
  }

  @protected
  void unsubscribe(String broker, String topic) {
    if (!_isOfflineMode) {
      Log.debug('Unsubscribed: $topic');
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
