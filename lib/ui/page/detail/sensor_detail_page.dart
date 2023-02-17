import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_listener_service.dart';
import 'package:ripe/service/sensor_setting_service.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/page/sensor_log_page.dart';
import 'package:ripe/ui/page/sensor_overview_page.dart';

import '../../component/platform.dart';
import 'decorator/agent_decorator.dart';
import 'sensor_app_bar.dart';
import 'sensor_data_card.dart';

class SensorDetailPage extends StatefulWidget {
  final RegisteredSensor sensor;
  final SensorDto data;

  const SensorDetailPage(this.sensor, this.data);

  @override
  State<StatefulWidget> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage>
    with WidgetsBindingObserver {
  final _backendService = new BackendService();
  SensorListenerService? service;
  late List<GlobalKey> childKeys;
  late SensorDto data;
  bool isConnected = false;
  double bottomPadding = 0.0;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    data = widget.data;
    WidgetsBinding.instance.addObserver(this);
    _initMqtt();

    childKeys =
        List.generate(widget.data.agents.length + 1, (_) => GlobalKey());
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        bottomPadding = MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            kToolbarHeight -
            childKeys.fold<double>(0.0,
                (prev, el) => prev + (el.currentContext?.size?.height ?? 0.0));
        bottomPadding = max(0.0, bottomPadding);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    service?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initMqtt();
    }
  }

  void _onMqttConnect() {
    if (mounted) {
      setState(() => isConnected = true);
    }
  }

  void _onMqttDisconnect() {
    if (mounted) {
      setState(() => isConnected = false);
      service!.reconnect();
    }
  }

  void _initMqtt() {
    if (data.broker.wss != null) {
      service = new SensorListenerService(data.broker);
      service!
          .connect(onConnect: _onMqttConnect, onDisconnect: _onMqttDisconnect)
          .then((_) {
        service!.listenSensorData(
          widget.sensor.id,
          widget.sensor.key,
          () => Future.delayed(const Duration(milliseconds: 500), _refreshData),
        );
      });
    } else {
      final snackbar = RipeSnackbar(
        context,
        label: 'Sensor ist nicht erreichbar',
        action: SnackBarAction(
          label: 'Erneut verbinden',
          onPressed: () {
            _backendService
                .getSensorStatus(widget.sensor.id, widget.sensor.key)
                .then((sensor) {
              if (sensor != null) {
                data = sensor;
                _initMqtt();
              }
            });
          },
        ),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  /*
   * Callbacks
   */

  void _onBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute(builder: (_) => SensorOverviewPage()),
      );
    }
  }

  void _onLogs() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => SensorLogPage(
          widget.sensor,
          widget.data,
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    final sensorData = await _backendService.getSensorStatus(
        widget.sensor.id, widget.sensor.key);
    if (!mounted) {
      return;
    } else if (sensorData != null) {
      setState(() => data = sensorData);
    } else {
      final snackbar = RipeSnackbar(
        context,
        label: 'Sensor konnte nicht aktualisiert werden',
        action: SnackBarAction(
          label: 'Erneut versuchen',
          onPressed: _refreshData,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onBack(context);
        return true;
      },
      child: Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          bottom: false,
          child: Material(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              displacement: 10.0,
              edgeOffset: 180.0,
              color: Theme.of(context).colorScheme.secondary,
              child: Container(
                child: CustomScrollView(
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SensorAppBar(
                        expandedHeight: 180.0,
                        onBack: _onBack,
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
                              trailing: Container(
                                width: 72,
                                child: Row(
                                  children: [
                                    Tooltip(
                                        message: data.broker.tcp ?? 'broker',
                                        child: Icon(
                                          isConnected
                                              ? Icons.sensors
                                              : Icons.sensors_off,
                                        )),
                                    IconButton(
                                      onPressed: _onLogs,
                                      icon:
                                          const Icon(Icons.analytics_outlined),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return SensorDataCard(
                              widget.sensor,
                              data.sensorData,
                              key: childKeys[index],
                            );
                          }
                          return new AgentDecorator(
                            info: widget.sensor,
                            agent: data.agents[index - 1],
                            key: childKeys[index],
                            refreshCallback: _refreshData,
                          );
                        },
                        childCount: 1 +
                            (data.sensorData.isEmpty()
                                ? 0
                                : data.agents.length),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(height: bottomPadding),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
