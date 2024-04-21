import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/sensor_listener_service.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/component/platform.dart';
import 'package:ripe/ui/page/sensor/sensor_overview_page.dart';
import 'package:ripe/ui/page/util/mqtt_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'decorator/agent_decorator.dart';
import 'sensor_app_bar.dart';
import 'sensor_data_card.dart';

class SensorDetailPage extends StatefulWidget {
  static const String path = '/sensor/:id';

  static String route(RegisteredSensor sensor) => '/sensor/${sensor.id}';

  final RegisteredSensor sensor;

  const SensorDetailPage(this.sensor);

  @override
  State<StatefulWidget> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends MqttState<SensorDetailPage> {
  final _backendService = new BackendService();
  final _stateStream = StreamController<SensorDto>.broadcast();

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    final key = 'UI_CACHE_SENSOR_${widget.sensor.id}';
    bool hasValue = false;

    SharedPreferences.getInstance().then((prefs) {
      if (!hasValue) {
        final cache = prefs.getString(key);
        if (cache != null) {
          final data = SensorDto.fromJson(jsonDecode(cache));
          _stateStream.add(data);
        }
      }
    });

    _backendService.getSensorStatus(widget.sensor).then((data) {
      hasValue = true;
      _stateStream.add(data);
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(key, jsonEncode(data.toJson()));
      });
      listenerService = SensorListenerService(widget.sensor, data.broker);
      connectToBroker();
    });
  }

  @override
  void connectToBroker() {
    listenerService!.connect();
    listenerService!.listenSensorCmd((_) => _fetchData());
    listenerService!.listenSensorData((_) => _fetchData());
  }

  /*
   * Callbacks
   */

  void _onBack() {
    GoRouter.of(context).pushReplacement(SensorOverviewPage.path);
  }

  Future<void> _fetchData() async {
    try {
      final data = await _backendService.getSensorStatus(widget.sensor);
      _stateStream.add(data);
    } catch (e) {
      final snackbar = RipeSnackbar(
        context,
        label: 'Sensor konnte nicht aktualisiert werden',
        action: SnackBarAction(
          label: 'Erneut versuchen',
          onPressed: _fetchData,
        ),
      );
      try {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      } catch (_) {}
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (_) => _onBack(),
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _fetchData,
          displacement: 10.0,
          edgeOffset: 180.0,
          color: Theme.of(context).colorScheme.secondary,
          child: Container(
            child: StreamBuilder(
                stream: _stateStream.stream,
                builder: (context, snapshot) {
                  final host = (snapshot.data?.broker.items.isEmpty ?? true
                      ? null
                      : snapshot.requireData.broker.items.first.host);

                  return CustomScrollView(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SensorAppBar(
                          expandedHeight: 180.0,
                          topPadding: MediaQuery.of(context).viewPadding.top,
                          onBack: (_) => _onBack(),
                          imageProvider:
                              PlatformAssetImage(widget.sensor.thumbPath),
                          name: widget.sensor.name,
                          textSize: 40.0,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          child: Card(
                            child: Column(children: [
                              ListTile(
                                title: Text(
                                  widget.sensor.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                trailing: Tooltip(
                                  message: host ?? 'Kein Broker verfügbar',
                                  child: _MqttConnectionIcon(
                                      sensor: widget.sensor,
                                      brokers: snapshot.data?.broker),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      if (snapshot.hasData)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == 0) {
                                return SensorDataCard(
                                  widget.sensor,
                                  snapshot.requireData.sensorData,
                                );
                              }
                              return new AgentDecorator(
                                info: widget.sensor,
                                agent: snapshot.requireData.agents[index - 1],
                              );
                            },
                            childCount: 1 + snapshot.requireData.agents.length,
                          ),
                        )
                      else if (snapshot.hasError)
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'Sensor konnte nicht geladen werden',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      if (snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Container(
                            height: max(
                              0,
                              MediaQuery.of(context).size.height -
                                  kToolbarHeight -
                                  (100 *
                                      snapshot
                                          .requireData.sensorData.fieldCount),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}

class _MqttConnectionIcon extends StatefulWidget {
  final RegisteredSensor sensor;
  final BrokersDto? brokers;

  const _MqttConnectionIcon({
    required this.sensor,
    required this.brokers,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MqttConnectionIconState();
}

class _MqttConnectionIconState extends MqttState<_MqttConnectionIcon> {
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    if (widget.brokers != null) {
      listenerService = SensorListenerService(widget.sensor, widget.brokers!);
      connectToBroker();
    }
  }

  @override
  void connectToBroker() {
    listenerService?.connect(callback: (event) {
      if (mounted) {
        setState(() => isConnected = event == MqttConnectionState.connected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      crossFadeState:
          isConnected ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 400),
      firstChild: const Icon(Icons.sensors),
      secondChild: const Icon(Icons.sensors_off),
    );
  }

  @override
  void didUpdateWidget(covariant _MqttConnectionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listenerService == null && widget.brokers != null) {
      listenerService = SensorListenerService(widget.sensor, widget.brokers!);
      connectToBroker();
    }
  }
}
