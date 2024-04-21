import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/background.dart';
import 'package:ripe/service/sensor_service.dart';
import 'package:ripe/ui/page/sensor/sensor_overview_page.dart';

class SplashScreen extends StatefulWidget {
  final String initialPath;

  const SplashScreen(this.initialPath);

  @override
  State createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _backendService = new BackendService();
  final _sensorService = SensorService.getInstance();

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    Future.wait([
      initBackgroundTasks(),
      _sensorService.init(),
      _backendService.init(),
    ]).then((_) => _onConnect());
  }

/*
   * UI-Callbacks
   */

  Future<void> _onConnect() async {
    if (widget.initialPath == '/') {
      GoRouter.of(context).go(SensorOverviewPage.path);
    } else {
      GoRouter.of(context).go(widget.initialPath);
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    return Container();
  }
}
