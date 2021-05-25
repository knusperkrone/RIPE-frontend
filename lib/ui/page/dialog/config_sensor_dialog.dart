import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iftem/ui/component/validator.dart';
import 'package:tuple/tuple.dart';

class ConfigSensorDialog extends StatefulWidget {
  final String ssid;
  final String pwd;

  const ConfigSensorDialog({
    Key? key,
    required this.ssid,
    required this.pwd,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ConfigSensorDialogState();
}

class _ConfigSensorDialogState extends State<ConfigSensorDialog> {
  final _formKey = new GlobalKey<FormState>();
  late TextEditingController _ssidController;
  late TextEditingController _pwdController;
  bool isObscured = true;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    _ssidController = new TextEditingController()..text = widget.ssid;
    _pwdController = new TextEditingController()..text = widget.pwd;
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  /*
   * UI-Callbacks
   */

  void _onSubmit() {
    _formKey.currentState!.save();
    if (_formKey.currentState!.validate()) {
      final ssid = _ssidController.value.text;
      final pwd = _pwdController.value.text;
      Navigator.pop(context, Tuple2(ssid, pwd));
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      contentPadding: const EdgeInsets.only(top: 10.0),
      content: Container(
        height: 225,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Sensor mit WLAN verbinden'),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  maxLines: 1,
                  controller: _ssidController,
                  validator: Validator.notEmpty,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    hintText: 'WLAN Name',
                    icon: Icon(Icons.wifi),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextFormField(
                  maxLines: 1,
                  obscureText: isObscured,
                  controller: _pwdController,
                  validator: Validator.notEmpty,
                  keyboardType: TextInputType.visiblePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: 'WLAN Passwort',
                    icon: const Icon(Icons.security),
                    suffixIcon: IconButton(
                      icon: Icon(
                          isObscured ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => isObscured = !isObscured),
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).errorColor,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                          ),
                        ),
                        child: const Text('Abbrechen',
                            textAlign: TextAlign.center),
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
                            color: Theme.of(context).accentColor,
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(12.0),
                            ),
                          ),
                          child: const Text('Verbinden',
                              textAlign: TextAlign.center),
                        ),
                        onTap: _onSubmit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
