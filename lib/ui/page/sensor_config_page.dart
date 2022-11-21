import 'package:flutter/material.dart';
import 'package:ripe/service/sensor_server_service.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/component/colors.dart';
import 'package:ripe/ui/page/sensor_overview_page.dart';
import 'package:tuple/tuple.dart';

import 'dialog/config_sensor_dialog.dart';

class SensorConfigPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SensorConfigPageState();
}

class SensorConfigPageState extends State<SensorConfigPage> {
  final _senderService = new SensorServerService();
  final List<String?> wifiData = List.filled(2, null, growable: false);

  bool isChecking = false;
  bool canPop = false;

  /*
   * Helpers
   */

  Future<RipeSnackbar> checkForSuccessfulCredentials() async {
    RipeSnackbar snackbar;

    // Wait 5 Seconds, success on no loner available sensor
    setState(() => isChecking = true);
    await Future.delayed(const Duration(seconds: 5), () {});
    if (!await _senderService.checkAvailable()) {
      snackbar = RipeSnackbar(
        context,
        label: 'Sensor erfolgreich mit dem WLAN verbunden',
        duration: const Duration(seconds: 5),
      );
    } else {
      snackbar = RipeSnackbar(
        context,
        label: 'Falsche WLAN Zugangsdaten, versuche es erneute',
      );
    }
    setState(() => isChecking = false);

    return snackbar;
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onAdd(BuildContext context) async {
    RipeSnackbar snackbar;
    if (!await _senderService.checkAvailable()) {
      snackbar = RipeSnackbar(
        context,
        label:
            'Sensor nicht erreichbar. Haben sie sich den Sensor ein und wieder ausgeschalten, sich mit "InterFace-Bewässerung" verbunden und ihre mobilen Daten deaktiviert?',
      );
    } else {
      final result = await showDialog<Tuple2<String, String>>(
          context: context,
          builder: (_) => ConfigSensorDialog(
                ssid: wifiData[0] ?? '',
                pwd: wifiData[1] ?? '',
              ));
      if (result == null) {
        return;
      }
      wifiData[0] = result.item1;
      wifiData[1] = result.item2;

      if (await _senderService.sendWifiConfig(result.item1, result.item2)) {
        snackbar = await checkForSuccessfulCredentials();
      } else {
        snackbar = RipeSnackbar(
          context,
          label: 'Konnte nicht verbinden..\nMit dem Sensor WLAN verbunden?',
          action: SnackBarAction(
            label: 'Erneut versuchen',
            onPressed: () => _onAdd(context),
          ),
        );
      }
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    canPop = Navigator.of(context).canPop();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final linePadding = constraints.maxWidth / 9;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.33],
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).canvasColor,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: ListView(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: canPop
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.white70,
                      )
                    : IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white70,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => SensorOverviewPage(),
                          ),
                        ),
                      ),
              ),
              Container(
                height: (constraints.maxHeight / 6) - 40,
              ),
              Image.asset(
                'assets/icon.png',
                width: 80,
                height: 80,
              ),
              Container(height: 20),
              Text(
                'Sensor mit dem Internet verbinden',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontWeight: FontWeight.w200),
              ),
              Container(height: 30),
              AnimatedOpacity(
                opacity: isChecking ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: const LinearProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(left: linePadding, top: 15),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ',
                        style:
                            textTheme.subtitle2!.copyWith(color: BUTTON_COLOR),
                      ),
                      TextSpan(
                          text: 'Sensor aus und wieder einschalten',
                          style: textTheme.subtitle1)
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: linePadding, top: 15),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ',
                        style:
                            textTheme.subtitle2!.copyWith(color: BUTTON_COLOR),
                      ),
                      TextSpan(text: 'Mit WLAN  ', style: textTheme.subtitle1),
                      TextSpan(
                          text: 'InterFace-Bewässerung',
                          style: textTheme.subtitle1!
                              .copyWith(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' verbinden', style: textTheme.subtitle1),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: linePadding, top: 15),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ',
                        style:
                            textTheme.subtitle2!.copyWith(color: BUTTON_COLOR),
                      ),
                      TextSpan(
                          text: 'Mobile Daten deaktivieren',
                          style: textTheme.subtitle1),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: linePadding, top: 15),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ',
                        style:
                            textTheme.subtitle2!.copyWith(color: BUTTON_COLOR),
                      ),
                      TextSpan(
                          text: 'Ihre WLAN Zugangsdaten eingeben',
                          style: textTheme.subtitle1),
                    ],
                  ),
                ),
              ),
              Container(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth / 6,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).textTheme.button!.color),
                    backgroundColor: MaterialStateProperty.all(PRIMARY_COLOR),
                  ),
                  child: const Text('Sensor konfigurieren'),
                  onPressed: () => _onAdd(context),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
