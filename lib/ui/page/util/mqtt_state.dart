import 'package:flutter/material.dart';
import 'package:ripe/service/sensor_listener_service.dart';

abstract class MqttState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  @protected
  SensorListenerService? listenerService;

  void connectToBroker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    listenerService?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && listenerService != null) {
      connectToBroker();
    }
  }
}
