import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.33],
                colors: [
                  Theme.of(context).accentColor,
                  Theme.of(context).canvasColor,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Container(
                  height: (constraints.maxHeight / 6) - 40,
                ),
                const Image(
                  image: AssetImage('assets/icon.png'),
                  width: 80,
                  height: 80,
                ),
                Container(height: 20),
                Text(
                  'RIPE',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.w200),
                ),
                Padding(
                  padding: EdgeInsets.all(constraints.maxHeight / 21),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Powered by ',
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(fontWeight: FontWeight.w200),
                      ),
                      TextSpan(
                        text: 'InterFace AG',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.w200,
                            color: const Color(0xffff8100)),
                        recognizer: new TapGestureRecognizer()
                          ..onTap =
                              () => launch('https://www.interface-ag.com/'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(constraints.maxHeight / 21),
                ),
                MaterialButton(
                  child: Text(
                    'Softwarelizenzen',
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .copyWith(fontWeight: FontWeight.w200),
                  ),
                  onPressed: () => showLicensePage(context: context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
