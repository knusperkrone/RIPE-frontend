import 'package:flutter/material.dart';

import '../../component/colors.dart';

class TimePaneDecoratorDialogResult {
  final bool isEnabled;
  final int forceSeconds;

  TimePaneDecoratorDialogResult(this.isEnabled, this.forceSeconds);
}

class TimePaneDecoratorDialog extends StatefulWidget {
  final String domainHR;
  final int defaultTimeout;

  const TimePaneDecoratorDialog({
    required this.domainHR,
    required this.defaultTimeout,
  });

  @override
  State<StatefulWidget> createState() => _TimePaneDecoratorState();
}

class _TimePaneDecoratorState extends State<TimePaneDecoratorDialog> {
  late int forceSeconds;

  @override
  void initState() {
    super.initState();
    forceSeconds = widget.defaultTimeout;
  }

  /*
   * UI-Callbacks
   */

  void _onIncrease() {
    setState(() {
      forceSeconds += widget.defaultTimeout;
    });
  }

  void _onDecrease() {
    if (forceSeconds - widget.defaultTimeout >= widget.defaultTimeout) {
      setState(() {
        forceSeconds -= widget.defaultTimeout;
      });
    }
  }

  /*
   * Build
   */

  String _formatPayloadSecond() {
    final pad = (num n) => n < 10 ? '0$n' : '$n';
    if (forceSeconds % 60 == 0 || forceSeconds > 100) {
      return '${forceSeconds ~/ 60}:${pad(forceSeconds % 60)} Minuten';
    }
    return '$forceSeconds Sekunden';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      contentPadding: const EdgeInsets.only(top: 10.0),
      title: Center(
          child: Text(
        '${widget.domainHR}',
        style: Theme.of(context).textTheme.titleLarge,
      )),
      content: Container(
        height: 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: _onIncrease,
                icon: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: ACCENT_COLOR,
                  size: 50,
                )),
            Text(_formatPayloadSecond()),
            IconButton(
              onPressed: _onDecrease,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ACCENT_COLOR,
                size: 50,
              ),
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  child: const Text('Ausschalten'),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      overlayColor: MaterialStateProperty.all(
                        ERROR_COLOR
                            .withBlue(ERROR_COLOR.blue + 15)
                            .withGreen(ERROR_COLOR.green + 15)
                            .withRed(ERROR_COLOR.red + 15),
                      ),
                      backgroundColor: MaterialStateProperty.all(ERROR_COLOR)),
                  onPressed: () => Navigator.of(context)
                      .pop(TimePaneDecoratorDialogResult(false, forceSeconds)),
                ),
                const Padding(padding: EdgeInsets.all(5)),
                OutlinedButton(
                  child: const Text('Einschalten'),
                  style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all(PRIMARY_COLOR)),
                  onPressed: () => Navigator.of(context)
                      .pop(TimePaneDecoratorDialogResult(true, forceSeconds)),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(10)),
          ],
        ),
      ),
    );
  }
}
