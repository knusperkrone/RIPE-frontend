import 'package:flutter/material.dart';
import 'package:iftem/service/models/dto.dart';
import 'package:iftem/ui/component/time_utils.dart';

class SensorDataCard extends StatelessWidget {
  final SensorDataDto data;

  const SensorDataCard(this.data);

  /*
   * Build
   */

  List<Widget> _buildTile(
    BuildContext context,
    IconData icon,
    String text,
    dynamic value,
    String appendix,
  ) {
    if (value == null) {
      return [];
    }

    final subhead = Theme.of(context).textTheme.subtitle1.copyWith();
    final valTheme = Theme.of(context).textTheme.subtitle1.copyWith(
        //color: Theme.of(context).buttonColor,
        fontWeight: FontWeight.bold,
        color: Colors.black87);
    return [
      ListTile(
        leading: Icon(icon),
        title: RichText(
          text: TextSpan(text: text, style: subhead, children: [
            TextSpan(text: ' $value', style: valTheme),
            TextSpan(text: appendix, style: valTheme),
          ]),
        ),
      ),
      const Divider(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        child: Column(
          children: <Widget>[
            ..._buildTile(
                context, Icons.whatshot, 'Temperatur:', data.temperature, '°C'),
            ..._buildTile(
                context, Icons.pool, 'Feuchtigkeit:', data.moisture, '%'),
            ..._buildTile(context, Icons.power_settings_new, 'Leitbarkeit:',
                data.conductivity, ' μS/cm²'),
            ..._buildTile(
                context, Icons.brightness_4, 'Helligkeit:', data.light, ' lux'),
            ListTile(
              dense: true,
              title: Text('Zeitstempel: ${TimeUtils.toHR(data.timestamp)}'),
              subtitle: Text('Battery: ${data.battery}%'),
            )
          ],
        ),
      ),
    );
  }
}
