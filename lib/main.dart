import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:ripe/ui/page/sensor/sensor_notification_page.dart';

import 'service/sensor_service.dart';
import 'theme.dart';
import 'ui/page/about_page.dart';
import 'ui/page/sensor/agent/agent_config_page.dart';
import 'ui/page/sensor/chart/data_page.dart';
import 'ui/page/sensor/detail/sensor_detail_page.dart';
import 'ui/page/sensor/register/registered_sensor_config_page.dart';
import 'ui/page/sensor/register/sensor_register_page.dart';
import 'ui/page/sensor/sensor_log_page.dart';
import 'ui/page/sensor/sensor_overview_page.dart';
import 'ui/page/splash_screen.dart';

String? _checkSensorExistsRouter(BuildContext context, GoRouterState state) {
  final sensorId = state.pathParameters['id'] ?? '';
  final sensor = SensorService.getInstance().getById(sensorId);
  if (sensor == null) {
    return SensorOverviewPage.path;
  }
  return null;
}

void main() {
  int navigationCount = 0;
  String initialPath = '/';
  if (kIsWeb) {
    usePathUrlStrategy();
    initialPath = Uri.base.toString().substring(Uri.base.origin.length);
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        if (navigationCount++ == 0) {
          return '/';
        } else if (state.path == '/') {
          return SensorOverviewPage.path;
        }
        return null;
      },
      errorBuilder: (context, state) {
        GoRouter.of(context).go(SensorOverviewPage.path);
        return Container();
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => SplashScreen(initialPath),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Text('Login'),
        ),
        GoRoute(
            path: SensorOverviewPage.path,
            redirect: (context, state) {
              final sensors = SensorService.getInstance().getSensors();
              if (sensors.isEmpty) {
                return SensorRegisterPage.path;
              } else if (sensors.length == 1 && navigationCount == 2) {
                return SensorDetailPage.route(sensors.first);
              }
              return null;
            },
            builder: (context, state) => SensorOverviewPage()),
        GoRoute(
          path: SensorRegisterPage.path,
          builder: (context, state) => SensorRegisterPage(),
        ),
        GoRoute(
            path: RegisteredSensorConfigPage.path,
            builder: (context, state) => RegisteredSensorConfigPage()),
        GoRoute(
            path: SensorDetailPage.path,
            redirect: _checkSensorExistsRouter,
            builder: (context, state) {
              final sensorId = state.pathParameters['id'] ?? '';
              final sensor = SensorService.getInstance().getById(sensorId)!;
              return SensorDetailPage(sensor);
            }),
        GoRoute(
            path: SensorNotificationPage.path,
            redirect: _checkSensorExistsRouter,
            builder: (context, state) {
              final sensorId = state.pathParameters['id'] ?? '';
              final sensor = SensorService.getInstance().getById(sensorId)!;
              return SensorNotificationPage(sensor);
            }),
        GoRoute(
            path: AgentConfigPage.path,
            redirect: _checkSensorExistsRouter,
            builder: (context, state) {
              final sensorId = state.pathParameters['id'] ?? '';
              final sensor = SensorService.getInstance().getById(sensorId)!;
              final domain = state.pathParameters['domain'] ?? '';
              return AgentConfigPage(sensor, domain);
            }),
        GoRoute(
            path: SensorLogPage.path,
            redirect: _checkSensorExistsRouter,
            builder: (context, state) {
              final sensorId = state.pathParameters['id'] ?? '';
              final sensor = SensorService.getInstance().getById(sensorId)!;
              return SensorLogPage(sensor);
            }),
        GoRoute(
            path: SensorChartPage.path,
            redirect: _checkSensorExistsRouter,
            builder: (context, state) {
              final sensorId = state.pathParameters['id'] ?? '';
              final selectedStr = state.uri.queryParameters['selected'] ?? '';
              final sensor = SensorService.getInstance().getById(sensorId)!;
              return SensorChartPage(
                sensor,
                int.tryParse(selectedStr) ?? 0,
              );
            }),
        GoRoute(
          path: AboutPage.path,
          builder: (context, state) => AboutPage(),
        ),
        GoRoute(
            path: AboutPage.licensePath,
            builder: (context, state) => const LicensePage()),
      ]);

  runApp(MaterialApp.router(
    title: 'Ripe',
    themeMode: ThemeMode.dark,
    darkTheme: buildTheme(ThemeData.dark()),
    routerConfig: router,
  ));
}
