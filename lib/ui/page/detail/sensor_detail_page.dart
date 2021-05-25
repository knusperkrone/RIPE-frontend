import 'package:flutter/material.dart';
import 'package:ripe/service/backend_service.de.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/service/sensor_listener_service.dart';
import 'package:ripe/service/sensor_settings.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/page/detail/sensor_data_card.dart';
import 'package:ripe/ui/page/sensor_overview_page.dart';

import 'agent_decorator.dart';

class SensorDetailPage extends StatefulWidget {
  final RegisteredSensor sensor;
  final SensorDto data;

  const SensorDetailPage(this.sensor, this.data);

  @override
  State<StatefulWidget> createState() => _SensorDetailPageState();
}

class _SensorDetailPageState extends State<SensorDetailPage> {
  final _backendService = new BackendService();
  late SensorListenerService _service;
  late SensorDto data;
  late RegisteredSensor info;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    data = widget.data;
    info = widget.sensor;
    _service = new SensorListenerService(data.broker);
    _service.connect().then((_) {
      _service.listenSensor(info.id, info.key, _refreshData);
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
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
    final resp = await _backendService.getSensorData(info.id, info.key);
    if (resp != null) {
      setState(() => data = resp);
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
    );
  }
}
