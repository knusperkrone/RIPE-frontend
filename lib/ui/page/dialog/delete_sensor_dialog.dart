import 'package:flutter/material.dart';

class DeleteSensorDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      contentPadding: const EdgeInsets.only(top: 10.0),
      content: Container(
        height: 80,
        child: Column(
          children: [
            const Text('Sensor wirklich löschen?'),
            Expanded(
              child: Container(),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12.0),
                        ),
                      ),
                      child:
                          const Text('Abbrechen', textAlign: TextAlign.center),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).errorColor,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                      child: const Text('Löschen', textAlign: TextAlign.center),
                    ),
                    onTap: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
