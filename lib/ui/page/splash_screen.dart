import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ripe/service/backend_service.de.dart';
import 'package:ripe/service/sensor_settings.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/page/detail/sensor_detail_page.dart';
import 'package:ripe/ui/page/sensor_overview_page.dart';
import 'package:ripe/ui/page/sensor_register_page.dart';

class SplashScreen extends StatefulWidget {
  final ImageProvider logo;

  const SplashScreen(this.logo);

  @override
  State createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _backendService = new BackendService();
  final _sensorService = new SensorSettingService();
  late Future<void> _delayFut;
  bool isDirty = false;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    _delayFut = new Future.delayed(const Duration(milliseconds: 1250), () {});
    Future(() async {
      await _sensorService.init();
      await _backendService.init();
      _onConnect();
    });
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onConnect() async {
    final sensorsList = _sensorService.getSensors();
    if (sensorsList == null) {
      // No sensor - register!
      await _delayFut;
      Navigator.pushReplacement<void, void>(
          context, MaterialPageRoute(builder: (_) => SensorRegisterPage()));
    } else if (!isDirty && sensorsList.length == 1) {
      final first = sensorsList.first;
      final data = await BackendService().getSensorData(first.id, first.key);
      if (data != null) {
        await _delayFut;
        return Navigator.pushReplacement<void, void>(context,
            MaterialPageRoute(builder: (_) => SensorDetailPage(first, data)));
      } else {
        isDirty = true;
        return _notifyFetchError();
      }
    } else {
      await _delayFut;
      return Navigator.pushReplacement<void, void>(
          context, MaterialPageRoute(builder: (_) => SensorOverviewPage()));
    }
  }

  void _notifyFetchError() {
    isDirty = true;
    final snackbar = RipeSnackbar(
      context,
      label: 'Sensor-Daten konnten nicht abgerufen werden',
      duration: const Duration(days: 1),
      action: SnackBarAction(
        label: 'Erneut versuchen',
        onPressed: () {
          _onConnect();
        },
      ),
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [theme.canvasColor, theme.accentColor],
          ),
        ),
        child: Center(
          child: Image(
            image: widget.logo,
            height: 200.0,
            width: 200.0,
          ),
        ),
      ),
    );
  }
}
