import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ripe/service/mixins/mqtt_platform_adapter_stub.dart'
    if (dart.library.io) 'package:ripe/service/mixins/mqtt_platform_adapter_mobile.dart'
    if (dart.library.html) 'package:ripe/service/mixins/mqtt_platform_adapter_web.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/util/log.dart';

typedef MqttReceiveFunc = void Function(String);
typedef MqttConnectionFunc = void Function(MqttConnectionState);

class _MqttContext {
  final MqttClient client;
  final connectionController =
      new StreamController<MqttConnectionState>.broadcast();
  final messages = <String, StreamController<String>>{};
  final _subscriptionQueue = [];

  _MqttContext(this.client) : assert(client.onConnected == null) {
    client.onAutoReconnected = () => _broadcastMqttConnectionStatus();
    client.onDisconnected = () => _broadcastMqttConnectionStatus();
    client.onConnected = () {
      client.updates!.listen((msg) => _broadcastMqttMessage(msg));
      _broadcastMqttConnectionStatus();
      _subscriptionQueue.forEach((topic) {
        Log.debug('Subscribing to $topic');
        client.subscribe(topic, MqttQos.atLeastOnce);
      });
      _subscriptionQueue.clear();
    };
  }

  void _broadcastMqttConnectionStatus() {
    connectionController.add(
        client.connectionStatus?.state ?? MqttConnectionState.disconnected);
  }

  void _broadcastMqttMessage(List<MqttReceivedMessage<MqttMessage>> msgBuffer) {
    for (final msg in msgBuffer) {
      final topic = msg.topic;
      final casted = (msg.payload as MqttPublishMessage).payload;
      final payload = MqttPublishPayload.bytesToStringAsString(casted.message);
      Log.debug('Received from $topic');

      messages[topic]!.add(payload);
    }
  }

  Stream<String> getMessageStream(String topic) {
    messages[topic] ??= new StreamController<String>.broadcast();
    if (isConnected) {
      Log.debug('Subscribing to $topic');
      client.subscribe(topic, MqttQos.atLeastOnce);
    } else {
      _subscriptionQueue.add(topic);
    }
    return messages[topic]!.stream;
  }

  bool get isConnected => connectionState == MqttConnectionState.connected;

  MqttConnectionState get connectionState =>
      client.connectionStatus?.state ?? MqttConnectionState.disconnected;
}

abstract class MqttClientService {
  static final Map<BrokersDto, _MqttContext> _contexts = {};
  static bool _isOfflineMode = false;

  @protected
  _MqttContext? connectToBroker(BrokersDto broker) {
    _MqttContext? ctx = _contexts[broker];
    if (ctx == null || !ctx.isConnected) {
      try {
        final client = _createMqttClient(broker);
        if (client == null) {
          return null;
        }

        ctx = new _MqttContext(client);
        _contexts[broker] = ctx;
        if (!_isOfflineMode) {
          Future(() async {
            Log.info('MQTT Connecting ${client.server}:${client.port}');
            try {
              await client.connect();
              Log.info('MQTT Connected ${client.server}:${client.port}');
            } catch (e) {
              Log.error('Failed connect() MQTT $e');
            }
          });
        }
      } catch (e, stacktrace) {
        Log.error('Failed connecting MQTT $e $stacktrace');
        return null;
      }
    }

    return ctx;
  }

  static MqttClient? _createMqttClient(BrokersDto broker) {
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
      assert(client.autoReconnect == true);
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
  Stream<String>? subscribe(BrokersDto broker, String topic) {
    Log.debug('Subscribed: $topic for broker ${broker.hashCode}');
    return _contexts[broker]?.getMessageStream(topic);
  }
}
