import 'package:flutter/material.dart';
import 'package:ripe/ui/component/validator.dart';

class EditNameDialog extends StatefulWidget {
  @override
  State createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  final _formKey = new GlobalKey<FormState>();
  late TextEditingController _textController;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /*
   * UI-Callbacks
   */

  void _onSubmit() {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(context, _textController.value.text);
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      contentPadding: const EdgeInsets.only(top: 10.0),
      content: Container(
        height: 155,
        child: Column(
          children: [
            const Text('Sensor umbenennen'),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  maxLines: 1,
                  controller: _textController,
                  validator: Validator.notEmpty,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    icon: Icon(Icons.local_florist),
                  ),
                ),
              ),
            ),
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
                        color: Theme.of(context).errorColor,
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
                        color: Theme.of(context).accentColor,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(12.0),
                        ),
                      ),
                      child:
                          const Text('Bestätigen', textAlign: TextAlign.center),
                    ),
                    onTap: _onSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
