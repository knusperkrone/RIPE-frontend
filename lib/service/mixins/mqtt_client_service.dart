import 'dart:collection';
import 'dart:convert' show utf8;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ripe/service/mixins/mqtt_platform_adapter_stub.dart'
    if (dart.library.io) 'package:ripe/service/mixins/mqtt_platform_adapter_mobile.dart'
    if (dart.library.html) 'package:ripe/service/mixins/mqtt_platform_adapter_web.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/util/log.dart';
import 'package:typed_data/typed_buffers.dart';

typedef MqttReceiveFunc = void Function(String);

class _MqttContext {
  final MqttClient client;
  final Map<String, Set<MqttReceiveFunc>> messageCallbacks = new HashMap();
  final Set<VoidCallback> connectedCallbacks = {};
  final Set<VoidCallback> disconnectedCallbacks = {};

  _MqttContext(this.client);

  void addMessageCallback(String topic, MqttReceiveFunc callback) {
    messageCallbacks[topic] ??= {};
    messageCallbacks[topic]!.add(callback);
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void removeMessageCallback(String topic) {
    messageCallbacks[topic]?.clear();
    client.unsubscribe(topic);
  }

  void addConnectedCallback(VoidCallback callback) {
    connectedCallbacks.add(callback);
  }

  void addDisconnectedCallback(VoidCallback callback) {
    disconnectedCallbacks.add(callback);
  }

  void removeConnectedCallback(VoidCallback callback) {
    connectedCallbacks.remove(callback);
  }

  void removeDisconnectedCallback(VoidCallback callback) {
    disconnectedCallbacks.remove(callback);
  }

  void reconnect() {
    for (final sub in messageCallbacks.entries) {
      client.subscribe(sub.key, MqttQos.atLeastOnce);
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
  static final Map<BrokersDto, _MqttContext> _contexts =
      {}; // < BrokerUrl, Ctx>
  static bool _isOfflineMode = false;

  @protected
  Future<bool> listenFromBroker(BrokersDto broker, VoidCallback onConnect,
      VoidCallback onDisconnect) async {
    _MqttContext? ctx = _contexts[broker];
    if (ctx == null || !ctx.isConnected) {
      try {
        final client = await _initMqttClient(broker);
        if (client == null) {
          return false;
        }

        ctx = new _MqttContext(client);
        _contexts[broker] = ctx;
        client.updates!.listen((msg) => _dispatchMqttMessage(ctx!, msg));
        client.onConnected = () => _dispatchMqttConnect(ctx!);
        client.onDisconnected = () => _dispatchMqttDisconnect(ctx!);
      } catch (e) {
        Log.error('Failed connecting MQTT $e');
        return false;
      }
    }

    ctx.addConnectedCallback(onConnect);
    ctx.addDisconnectedCallback(onDisconnect);
    if (!_isOfflineMode) {
      onConnect();
    }

    return true;
  }

  @protected
  void unlistenFromBroker(
      BrokersDto broker, VoidCallback onConnect, VoidCallback onDisconnect) {
    _contexts[broker]?.removeConnectedCallback(onConnect);
    _contexts[broker]?.removeDisconnectedCallback(onConnect);
  }

  static void _dispatchMqttConnect(_MqttContext ctx) {
    ctx.connectedCallbacks.forEach((callback) => callback());
  }

  static void _dispatchMqttDisconnect(_MqttContext ctx) {
    ctx.disconnectedCallbacks.forEach((callback) => callback());
  }

  static void _dispatchMqttMessage(
      _MqttContext ctx, List<MqttReceivedMessage<MqttMessage>> msgBuffer) {
    for (final msg in msgBuffer) {
      final topic = msg.topic;
      final casted = (msg.payload as MqttPublishMessage).payload;
      final payload = MqttPublishPayload.bytesToStringAsString(casted.message);

      final observers = ctx.messageCallbacks[topic];
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

  static Future<MqttClient?> _initMqttClient(BrokersDto broker) async {
    final id = _generateUUID();
    MqttClient? client;

    for (final broker in broker.items
        .where((element) => getSupportedSchemes().contains(element.scheme))) {
      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(id)
          .withWillQos(MqttQos.atLeastOnce)
          .authenticateAs(
            broker.credentials?.username,
            broker.credentials?.password,
          );

      client = createMqttClient(broker, id, connMess);
      assert(client.autoReconnect == false);
    }

    if (!_isOfflineMode && client != null) {
      Log.info('MQTT Connecting ${client.server}:${client.port}');
      await client.connect();
      Log.info('MQTT Connected ${client.server}:${client.port}');
    }
    return client;
  }

  static String _generateUUID() {
    const maxVal = 4294967296;
    final rand = new Random();
    return 'APP${DateTime.now().toIso8601String()}-${rand.nextInt(maxVal)}-${rand.nextInt(maxVal)}';
  }

  /*
   * Class Methods
   */

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
  void subscribe(BrokersDto broker, String topic, MqttReceiveFunc recFunc) {
    if (!_isOfflineMode) {
      Log.debug('Subscribed: $topic for broker ${broker.hashCode}');

      _contexts[broker]?.addMessageCallback(topic, recFunc);
    }
  }

  @protected
  void unsubscribe(BrokersDto broker, String topic) {
    if (!_isOfflineMode) {
      Log.debug('Unsubscribed: $topic for broker ${broker.hashCode}');
      _contexts[broker]?.removeMessageCallback(topic);
    }
  }

  @protected
  void publish(BrokersDto broker, String topic, String data) {
    if (!_isOfflineMode) {
      Log.debug('Publish for broker ${broker.hashCode}');
      _contexts[broker]?.publish(topic, data);
    }
  }
}
