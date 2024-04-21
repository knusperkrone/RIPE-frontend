import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/page/sensor/sensor_overview_page.dart';

class AboutPage extends StatelessWidget {
  static const String path = '/about';
  static const String licensePath = '/about/license';

  final backendService = new BackendService();
  final scaffoldMsgKey = new GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMsgKey,
      child: Scaffold(
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
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => GoRouter.of(context).push(
                        SensorOverviewPage.path,
                      ),
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
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.w200),
                  ),
                  Padding(
                    padding: EdgeInsets.all(constraints.maxHeight / 21),
                  ),
                  Padding(
                    padding: EdgeInsets.all(constraints.maxHeight / 40),
                  ),
                  MaterialButton(
                    child: Text(
                      'Softwarelizenzen',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.w200),
                    ),
                    onPressed: () => showLicensePage(context: context),
                  ),
                  Padding(
                    padding: EdgeInsets.all(constraints.maxHeight / 40),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: (constraints.maxWidth - 250) / 2),
                    width: 10,
                    child: Form(
                      child: TextFormField(
                        // The validator receives the text that the user has entered
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                            labelText: 'Backend URL',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            )),
                        maxLines: 1,
                        initialValue: backendService.baseUrl,
                        validator: (value) {
                          if (value == backendService.baseUrl) {
                            return null;
                          }
                          if (value == null || value.isEmpty) {
                            return 'Keine URL';
                          }
                          try {
                            Uri.parse(value);
                          } catch (e) {
                            return 'invalide URL';
                          }

                          backendService.checkBaseUrl(value).then((isValid) {
                            if (isValid && value != backendService.baseUrl) {
                              backendService.baseUrl = value;
                              scaffoldMsgKey.currentState?.showSnackBar(
                                RipeSnackbar(
                                  context,
                                  label: 'URL geändert',
                                ),
                              );
                            }
                          });
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
