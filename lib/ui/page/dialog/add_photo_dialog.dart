import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iftem/ui/component/colors.dart';
import 'package:image_picker/image_picker.dart';

class AddPhotoDialog extends StatefulWidget {
  final String path;

  const AddPhotoDialog(this.path) : assert(path != null);

  @override
  State createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  final _imagePicker = new ImagePicker();
  File file;

  @override
  void initState() {
    super.initState();
    file = new File(widget.path);
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onPhoto(BuildContext context, ImageSource source) async {
    final picked = await _imagePicker.getImage(source: source);
    if (picked != null) {
      setState(() {
        file = new File(picked.path);
      });
    }
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
        height: 250,
        child: Column(
          children: [
            const Text('Pflanzenprofilbild hinzufügen'),
            const Divider(),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: BACKGROUND_COLOR,
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: FileImage(file),
                ),
              ),
            ),
            MaterialButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo),
                  Container(width: 5),
                  const Text('Kamera'),
                ],
              ),
              onPressed: () => _onPhoto(context, ImageSource.camera),
            ),
            MaterialButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_library),
                  Container(width: 5),
                  const Text('Galerie'),
                ],
              ),
              onPressed: () => _onPhoto(context, ImageSource.gallery),
            ),
            Expanded(
              child: Container(),
            ),
            InkWell(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: ACCENT_COLOR,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: const Text('Bestätigen', textAlign: TextAlign.center),
              ),
              onTap: () => Navigator.pop(context, file),
            ),
          ],
        ),
      ),
    );
  }
}
