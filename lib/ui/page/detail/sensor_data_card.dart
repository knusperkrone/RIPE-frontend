import 'package:flutter/material.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/ui/component/colors.dart';
import 'package:ripe/ui/component/time_utils.dart';
import 'package:ripe/ui/page/data/data_page.dart';
import 'package:ripe/ui/page/sensor_config_page.dart';

import '../../../service/sensor_setting_service.dart';

class SensorDataCard extends StatefulWidget {
  final RegisteredSensor sensor;
  final SensorDataDto data;

  const SensorDataCard(this.sensor, this.data, {Key? key}) : super(key: key);

  @override
  State createState() => _SensorDataCardState();
}

class _SensorDataCardState extends State<SensorDataCard> {
  bool isUpdating = false;

  @override
  void didUpdateWidget(SensorDataCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      setState(() => isUpdating = true);
      Future.delayed(const Duration(milliseconds: 750), () {
        if (mounted) {
          setState(() => isUpdating = false);
        }
      });
    }
  }

  /*
   * Build
   */

  List<Widget> _buildTile({
    required BuildContext context,
    required IconData icon,
    required String unitName,
    required num? value,
    required String unit,
    required int tabIndex,
  }) {
    if (value == null) {
      return [];
    }

    final subhead = Theme.of(context).textTheme.titleMedium!.copyWith();
    final valTheme = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(fontWeight: FontWeight.bold);
    return [
      ListTile(
        leading: Icon(icon),
        onTap: () => Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (context) => DataPage(widget.sensor, tabIndex),
          ),
        ),
        title: RichText(
          maxLines: 2,
          overflow: TextOverflow.clip,
          text: TextSpan(text: '$unitName:', style: subhead, children: [
            TextSpan(text: ' ${value.toStringAsFixed(1)}', style: valTheme),
            TextSpan(text: ' $unit', style: valTheme),
          ]),
        ),
      ),
      const Divider(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.isEmpty()) {
      return Container(
        width: double.infinity,
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'Sensor ist nicht mit dem Internet verbunden!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: ERROR_COLOR,
                        ),
                  ),
                ),
              ),
              Container(height: 10),
              Center(
                child: OutlinedButton(
                  child: const Text('Sensor über WLAN verbinden'),
                  onPressed: () {
                    Navigator.of(context).push<void>(MaterialPageRoute(
                      builder: (context) => SensorConfigPage(),
                    ));
                  },
                ),
              ),
              Container(height: 20),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      child: Card(
        child: Column(
          children: <Widget>[
            ..._buildTile(
              context: context,
              icon: Icons.whatshot,
              unitName: 'Temperatur',
              value: data.temperature,
              unit: '°C',
              tabIndex: 0,
            ),
            ..._buildTile(
              context: context,
              icon: Icons.pool,
              unitName: 'Feuchtigkeit',
              value: data.moisture,
              unit: '%',
              tabIndex: 1,
            ),
            ..._buildTile(
              context: context,
              icon: Icons.power_settings_new,
              unitName: 'Leitbarkeit',
              value: data.conductivity,
              unit: 'μS/cm²',
              tabIndex: 2,
            ),
            ..._buildTile(
              context: context,
              icon: Icons.brightness_4,
              unitName: 'Helligkeit',
              value: data.conductivity,
              unit: 'lux',
              tabIndex: 2,
            ),
            ListTile(
              dense: true,
              title: Text(
                'Zeitstempel: ${toHR(data.timestamp, withTimezone: true)}',
              ),
              subtitle: data.battery != null
                  ? Text('Battery: ${data.battery}%')
                  : null,
              trailing: AnimatedOpacity(
                opacity: isUpdating ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 750 ~/ 2),
                child: const Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Icon(
                    Icons.sync,
                    size: 20.0,
                    color: BUTTON_COLOR_LIGHT,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
