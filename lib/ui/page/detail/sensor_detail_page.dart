import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ripe/service/backend_service.de.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_listener_service.dart';
import 'package:ripe/service/sensor_settings.dart';
import 'package:ripe/ui/component/branded.dart';
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
  late SensorListenerService? _service;
  late SensorDto data;
  late RegisteredSensor info;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    data = widget.data;
    info = widget.sensor;
    _initMqtt();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _service?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initMqtt();
    }
  }

  void _initMqtt() {
    if (data.broker != null) {
      _service = new SensorListenerService(data.broker!);
      _service!.connect().then((_) {
        _service!.listenSensor(info.id, info.key, _refreshData);
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
    final imgFile = new File(widget.sensor.imagePath);
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
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          return SensorDataCard(data.sensorData);
                        }
                        return new AgentDecorator(
                          info: info,
                          agent: data.agents[index - 1],
                          refreshCallback: _refreshData,
                        );
                      },
                      childCount: 1 + data.agents.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      /*
      child: Scaffold(
        appBar: RipeAppBar(
          title: Text(data.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onBack(context),
          ),
        ),
        body: ListView.builder(
          itemCount: 1 + data.agents.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return SensorDataCard(data.sensorData);
            }
            return new AgentDecorator(
              info: info,
              agent: data.agents[index - 1],
              refreshCallback: _refreshData,
            );
          },
        ),
      ),

       */
    );
  }
}
