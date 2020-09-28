import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iftem/service/backend_service.de.dart';
import 'package:iftem/service/mixins/mqtt_client_service.dart';
import 'package:iftem/service/sensor_settings.dart';
import 'package:iftem/ui/component/branded.dart';
import 'package:iftem/ui/page/detail/sensor_detail_page.dart';
import 'package:iftem/ui/page/sensor_overview_page.dart';
import 'package:iftem/ui/page/sensor_register_page.dart';

class SplashScreen extends StatefulWidget {
  final ImageProvider logo;

  const SplashScreen(this.logo);

  @override
  State createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _sensorService = new SensorSettingService();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<void> _delayFut;
  Future<bool> _mqttConnectFut;
  bool isDirty = false;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    _mqttConnectFut = MqttClientService.init();
    _delayFut = Future.delayed(const Duration(milliseconds: 1500), () {});
    _sensorService.init().then((_) => _onConnect());
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onConnect() async {
    final sensorsList = _sensorService.getSensors();
    if (sensorsList.isEmpty) {
      // No sensor - register!
      Navigator.pushReplacement<void, void>(
          context, MaterialPageRoute(builder: (_) => SensorRegisterPage()));
    } else {
      // Has sensors - show overview
      final isMqttConnected = await _mqttConnectFut;
      if (isMqttConnected) {
        // Only fetch sensor failed - show overview, with context options
        if (sensorsList.value.isEmpty || !isDirty) {
          final first = sensorsList.value.first;
          final data =
              await BackendService().getSensorData(first.id, first.key);
          if (data.isPresent) {
            await _delayFut;
            return Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute(
                    builder: (_) => SensorDetailPage(first, data.value)));
          }
        } else {
          await _delayFut;
          return Navigator.pushReplacement<void, void>(
              context, MaterialPageRoute(builder: (_) => SensorOverviewPage()));
        }
      }

      // Cannot connect - notify user
      isDirty = true;
      final snackbar = IftemSnackbar(
        context,
        label: 'Sensor-Daten konnten nicht abgerufen werden',
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: 'Erneut versuchen',
          onPressed: () {
            _mqttConnectFut = MqttClientService.init();
            _onConnect();
          },
        ),
      );
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).canvasColor,
              Theme.of(context).accentColor
            ])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: widget.logo,
                height: 200,
              ),
              Text(
                'Iftem',
                style: Theme.of(context)
                    .textTheme
                    .headline2
                    .copyWith(fontWeight: FontWeight.w200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
