import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_listener_service.dart';
import 'package:ripe/service/sensor_settings.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/page/sensor_log_page.dart';
import 'package:ripe/ui/page/sensor_overview_page.dart';

import 'agent_decorator.dart';
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
  late RegisteredSensor info;
  late Timer connectionCheck;
  bool isConnected = false;
  double bottomPadding = 0.0;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    data = widget.data;
    info = widget.sensor;
    _initMqtt();
    connectionCheck =
        Timer.periodic(const Duration(seconds: 1), (_) => _checkMQTT());

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
    connectionCheck.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initMqtt();
    }
  }

  Future<void> _checkMQTT() async {
    final newIsConnected = service?.isConnected() ?? false;
    if (newIsConnected != isConnected) {
      setState(() => isConnected = newIsConnected);
    }
  }

  void _initMqtt() {
    if (data.broker != null) {
      service = new SensorListenerService(data.broker!);
      isConnected = service!.isConnected();
      service!.connect().then((_) {
        service!.listenSensor(
          info.id,
          info.key,
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
            _backendService.getSensorData(info.id, info.key).then((sensor) {
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
    final sensorData = await _backendService.getSensorData(info.id, info.key);
    if (sensorData != null) {
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
    final imgFile = new File(widget.sensor.thumbPath);
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
                        imageProvider: FileImage(imgFile),
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
                                data.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              trailing: Container(
                                width: 72,
                                child: Row(
                                  children: [
                                    Tooltip(
                                        message: data.broker ?? 'broker',
                                        child: Icon(
                                          isConnected
                                              ? Icons.sensors
                                              : Icons.sensors_off,
                                          color: Colors.white38,
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
                              data.sensorData,
                              key: childKeys[index],
                            );
                          }
                          return new AgentDecorator(
                            info: info,
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
