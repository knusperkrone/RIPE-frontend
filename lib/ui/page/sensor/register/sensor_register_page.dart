import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/service/sensor_service.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/component/colors.dart';
import 'package:ripe/ui/component/validator.dart';
import 'package:ripe/ui/page/dialog/add_photo_dialog.dart';
import 'package:ripe/ui/page/sensor/register/registered_sensor_config_page.dart';
import 'package:ripe/ui/page/sensor/sensor_overview_page.dart';

class SensorRegisterPage extends StatefulWidget {
  static const String path = '/sensor/register';

  @override
  State createState() => new _SensorRegisterPageState();
}

class _SensorRegisterPageState extends State<SensorRegisterPage> {
  final _settingService = SensorService.getInstance();
  final _backendService = new BackendService();
  final _formKey = new GlobalKey<FormState>();

  late TextEditingController _idController;
  late TextEditingController _pwdController;
  late TextEditingController _nameController;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    _idController = new TextEditingController();
    _pwdController = new TextEditingController();
    _nameController = new TextEditingController();
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onRegister(BuildContext context) async {
    // Validate input
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Call backend
    final id = int.parse(_idController.value.text);
    final key = _pwdController.value.text;
    String name = _nameController.value.text;

    try {
      await _backendService.getSensorStatus(
        RegisteredSensor(id, key, name, '', Colors.white, null),
      );
    } catch (e) {
      final snackBar = RipeSnackbar(context,
          label: 'Registerung fehlgeschlagen - falsche ID oder Passwort',
          action: SnackBarAction(
            onPressed: () => GoRouter.of(context).pushReplacement(
              SensorOverviewPage.path,
            ),
            label: 'Abbrechen',
          ));

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // Notify user
    if (name.trim().isEmpty) {
      name = 'Sensor ${_settingService.getSensors().length + 1}';
    }

    // Ask for photo
    File? file;
    if (!kIsWeb) {
      file = await showDialog<File>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddPhotoDialog(
          _settingService.placeholderPath,
          _settingService.placeholderThumbnailColor,
        ),
      );
    }

    final registered =
        await _settingService.addSensor(id, key, name, file?.path);
    if (registered != null && kIsWeb) {
      GoRouter.of(context).pushReplacement(SensorOverviewPage.path);
    } else if (registered != null) {
      GoRouter.of(context).pushReplacement(RegisteredSensorConfigPage.path);
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
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
                  onPressed: () => GoRouter.of(context).pushReplacement(
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
                'Sensor hinzufügen',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.w200),
              ),
              Container(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth / 7,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        maxLines: 1,
                        controller: _idController,
                        validator: (val) => Validator.chain(
                            val, [Validator.notEmpty, Validator.number]),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Id',
                          icon: RipeIcon(Icons.mobile_screen_share),
                        ),
                      ),
                      TextFormField(
                        maxLines: 1,
                        controller: _pwdController,
                        validator: Validator.notEmpty,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          hintText: 'Passwort',
                          icon: RipeIcon(Icons.security),
                        ),
                      ),
                      TextFormField(
                        maxLines: 1,
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          icon: RipeIcon(Icons.local_florist),
                        ),
                      ),
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
                    foregroundColor: WidgetStateProperty.all(
                        Theme.of(context).textTheme.labelLarge!.color),
                    backgroundColor: WidgetStateProperty.all(PRIMARY_COLOR),
                  ),
                  child: const Text('Bestätigen'),
                  onPressed: () => _onRegister(context),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
