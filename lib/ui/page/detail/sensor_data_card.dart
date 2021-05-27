import 'package:flutter/material.dart';
import 'package:ripe/service/models/dto.dart';
import 'package:ripe/ui/component/colors.dart';
import 'package:ripe/ui/component/time_utils.dart';

class SensorDataCard extends StatefulWidget {
  final SensorDataDto data;

  const SensorDataCard(this.data);

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
        setState(() => isUpdating = false);
      });
    }
  }

  /*
   * Build
   */

  List<Widget> _buildTile(
    BuildContext context,
    IconData icon,
    String text,
    num? value,
    String appendix,
  ) {
    if (value == null) {
      return [];
    }

    final subhead = Theme.of(context).textTheme.subtitle1!.copyWith();
    final valTheme = Theme.of(context)
        .textTheme
        .subtitle1!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black87);
    return [
      ListTile(
        leading: Icon(icon),
        title: RichText(
          text: TextSpan(text: text, style: subhead, children: [
            TextSpan(text: ' ${value.toStringAsFixed(1)}', style: valTheme),
            TextSpan(text: appendix, style: valTheme),
          ]),
        ),
      ),
      const Divider(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
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
              title: Text(
                'Zeitstempel: ${toHR(data.timestamp, withTimezone: true)}',
              ),
              subtitle: Text('Battery: ${data.battery}%'),
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
