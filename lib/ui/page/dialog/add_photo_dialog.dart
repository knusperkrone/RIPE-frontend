import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iftem/ui/component/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

class AddPhotoDialog extends StatefulWidget {
  final String imagePath;
  final Color imageGradient;

  const AddPhotoDialog(this.imagePath, this.imageGradient);

  @override
  State createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  final _imagePicker = new ImagePicker();
  late File _imagePath;
  late Color _imageShadow;

  @override
  void initState() {
    super.initState();
    _imagePath = new File(widget.imagePath);
    _imageShadow = widget.imageGradient;
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onPhoto(BuildContext context, ImageSource source) async {
    final picked = await _imagePicker.getImage(source: source);
    if (picked != null) {
      // Select file and preview gradient
      _imagePath = new File(picked.path);
      final palette =
          await PaletteGenerator.fromImageProvider(new FileImage(_imagePath));
      _imageShadow = (palette.lightVibrantColor ??
              palette.vibrantColor ??
              palette.dominantColor)!
          .color;

      setState(() {});
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
        height: 270,
        child: Column(
          children: [
            const Text('Pflanzenprofilbild hinzufügen'),
            const Divider(),
            Container(
              width: 100,
              height: 100,
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _imageShadow,
                    blurRadius: 7.0,
                    offset: const Offset(0.0, 0.75),
                  ),
                ],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(_imagePath),
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
              onTap: () => Navigator.pop(context, _imagePath),
            ),
          ],
        ),
      ),
    );
  }
}
