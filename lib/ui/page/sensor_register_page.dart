import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iftem/service/backend_service.de.dart';
import 'package:iftem/service/models/dto.dart';
import 'package:iftem/service/sensor_settings.dart';
import 'package:iftem/ui/component/branded.dart';
import 'package:iftem/ui/component/colors.dart';
import 'package:iftem/ui/component/validator.dart';
import 'package:iftem/ui/page/dialog/add_photo_dialog.dart';
import 'package:iftem/ui/page/sensor_overview_page.dart';

class SensorRegisterPage extends StatefulWidget {
  @override
  State createState() => new _SensorRegisterPageState();
}

class _SensorRegisterPageState extends State<SensorRegisterPage> {
  final _settingService = new SensorSettingService();
  final _backendService = new BackendService();
  final _formKey = new GlobalKey<FormState>();

  TextEditingController _idController;
  TextEditingController _pwdController;
  TextEditingController _nameController;
  bool canPop = false;

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

  void _onBack(RegisteredSensor setting, SensorDto dto) {
    Navigator.of(context).pushReplacement<void, void>(MaterialPageRoute(
      builder: (context) => SensorOverviewPage(),
    ));
  }

  Future<void> _onRegister(BuildContext context) async {
    // Validate input
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return;
    }

    // Call backend
    final id = int.parse(_idController.value.text);
    final key = _pwdController.value.text;
    String name = _nameController.value.text;
    final sensorOpt = await _backendService.getSensorData(id, key);

    // Notify user
    SnackBar snackBar;
    bool isSuccess = sensorOpt.isNotEmpty;
    if (isSuccess) {
      if (name?.trim()?.isEmpty ?? true) {
        name = sensorOpt.value.name;
      }

      // Ask for photo
      final file = await showDialog<File>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddPhotoDialog(_settingService.placeholder),
      );

      final settingOpt = _settingService.addSensor(id, key, name, file?.path);
      if (sensorOpt.isNotEmpty) {
        if (!canPop) {
          // Show sensor
          _onBack(settingOpt.value, sensorOpt.value);
          return;
        }

        snackBar = IftemSnackbar(
          context,
          label: 'Registrierung erfolgreich',
          action: SnackBarAction(
            onPressed: () => _onBack(settingOpt.value, sensorOpt.value),
            label: 'Abschliessen',
          ),
        );
      } else {
        isSuccess = false;
      }
    }

    if (!isSuccess) {
      snackBar = IftemSnackbar(context,
          label: 'Registerung fehlgeschlagen',
          action: SnackBarAction(
            onPressed: canPop ? () => Navigator.pop(context) : () {},
            label: canPop ? 'Abbrechen' : 'Erneut versuchen',
          ));
    }
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(snackBar);
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).canvasColor,
                  Theme.of(context).accentColor
                ]),
          ),
          alignment: Alignment.center,
          child: ListView(
            children: [
              Opacity(
                opacity: canPop ? 1.0 : 0.0,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: canPop ? () => Navigator.pop(context) : null,
                    color: Theme.of(context).primaryColor,
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
                'Sensor hinzufügen',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6
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
                          icon: Icon(Icons.mobile_screen_share),
                        ),
                      ),
                      TextFormField(
                        maxLines: 1,
                        controller: _pwdController,
                        validator: Validator.notEmpty,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          hintText: 'Passwort',
                          icon: Icon(Icons.security),
                        ),
                      ),
                      TextFormField(
                        maxLines: 1,
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          icon: Icon(Icons.local_florist),
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
                child: RaisedButton(
                  color: PRIMARY_COLOR,
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
