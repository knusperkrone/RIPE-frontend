import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:ripe/ui/component/colors.dart';

class AddPhotoDialog extends StatefulWidget {
  final String imagePath;
  final Color imageGradient;

  const AddPhotoDialog(this.imagePath, this.imageGradient);

  @override
  State createState() => _AddPhotoDialogState();
}

class _AddPhotoDialogState extends State<AddPhotoDialog> {
  final _imagePicker = new ImagePicker();
  final _imageCropper = new ImageCropper();
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
    final picked = await _imagePicker.pickImage(source: source);
    if (picked != null) {
      final croppedFile = await _imageCropper.cropImage(
        sourcePath: picked.path,
        aspectRatioPresets: [CropAspectRatioPreset.square],
      );
      if (croppedFile != null) {
        // Select file and preview gradient
        _imagePath = new File(croppedFile.path);
        final palette = await PaletteGenerator.fromImageProvider(
          FileImage(_imagePath),
        );

        setState(() {
          _imageShadow = (palette.lightVibrantColor ??
                  palette.vibrantColor ??
                  palette.dominantColor)!
              .color;
        });
      }
    }
  }

  void _onSubmit() {
    if (_imagePath.path == widget.imagePath) {
      Navigator.pop(context, null);
    } else {
      Navigator.pop(context, _imagePath);
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
        height: 364,
        child: Column(
          children: [
            Text(
              'Pflanzenbild hinzufügen',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              width: 150,
              height: 150,
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _imageShadow,
                    blurRadius: 15.0,
                    offset: const Offset(0.0, 0.75),
                  ),
                ],
                image: DecorationImage(
                  fit: BoxFit.scaleDown,
                  image: FileImage(_imagePath),
                ),
              ),
            ),
            Container(height: 10),
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
                height: 45,
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
              onTap: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
