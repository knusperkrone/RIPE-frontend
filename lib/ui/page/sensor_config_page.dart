import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iftem/service/sensor_server_service.dart';
import 'package:iftem/ui/component/branded.dart';
import 'package:iftem/ui/component/colors.dart';
import 'package:tuple/tuple.dart';

import 'dialog/config_sensor_dialog.dart';

class SensorConfigPage extends StatelessWidget {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _senderService = new SensorServerService();
  final List<String> wifiData = List.filled(2, null, growable: false);

  /*
   * UI-Callbacks
   */

  Future<void> _onAdd(BuildContext context) async {
    final result = await showDialog<Tuple2<String, String>>(
      context: context,
      builder: (_) => ConfigSensorDialog(
        ssid: wifiData[0],
        pwd: wifiData[1],
      ),
    );
    if (result == null) {
      return;
    }
    wifiData[0] = result.item1;
    wifiData[1] = result.item2;

    if (await _senderService.sendWifiConfig(result.item1, result.item2)) {
      Navigator.pop(context);
      return;
    }
    final snackbar = IftemSnackbar(
      context,
      label: 'Konnte nicht verbinden..\nMit dem Sensor WLAN verbunden?',
      action: SnackBarAction(
        label: 'Erneut versuchen',
        onPressed: () => _onAdd(context),
      ),
    );
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      body: LayoutBuilder(builder: (context, constraints) {
        final linePadding = constraints.maxWidth / 9;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                Theme.of(context).canvasColor,
                Theme.of(context).accentColor
              ])),
          alignment: Alignment.center,
          child: ListView(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: Theme.of(context).primaryColor,
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
                'Einen Sensor konfigurieren',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.w200),
              ),
              Container(height: 30),
              Padding(
                padding: EdgeInsets.only(left: linePadding, top: 15),
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ',
                        style: textTheme.subtitle2
                            .copyWith(color: DARK_PRIMARY_COLOR),
                      ),
                      TextSpan(
                          text: 'Sensor ein und wieder ausschalten',
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
                        style: textTheme.subtitle2
                            .copyWith(color: DARK_PRIMARY_COLOR),
                      ),
                      TextSpan(text: 'WLAN mit ', style: textTheme.subtitle1),
                      TextSpan(
                          text: 'InterFace-Bewässerung',
                          style: textTheme.subtitle2),
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
                        style: textTheme.subtitle2
                            .copyWith(color: DARK_PRIMARY_COLOR),
                      ),
                      TextSpan(
                          text: 'Heim WLAN Verbinungsdaten angeben',
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
                child: RaisedButton(
                  color: PRIMARY_COLOR,
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
