import 'dart:io';

import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:iftem/service/backend_service.de.dart';
import 'package:iftem/service/sensor_settings.dart';
import 'package:iftem/ui/component/branded.dart';
import 'package:iftem/ui/page/detail/sensor_detail_page.dart';
import 'package:iftem/ui/page/dialog/delete_sensor_dialog.dart';
import 'package:iftem/ui/page/dialog/edit_name_dialog.dart';
import 'package:iftem/ui/page/sensor_config_page.dart';
import 'package:iftem/ui/page/sensor_register_page.dart';
import 'package:palette_generator/palette_generator.dart';

import 'dialog/add_photo_dialog.dart';

typedef _IntCallback = void Function(int id);

class SensorOverviewPage extends StatefulWidget {
  @override
  State createState() => _SensorOverviewPageState();
}

class _SensorOverviewPageState extends State<SensorOverviewPage> {
  final _fabKey = new GlobalKey<FabCircularMenuState>();
  List<RegisteredSensor> sensors;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    sensors = SensorSettingService().getSensors().value;
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onDelete(int id) async {
    final isAnnihilated = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteSensorDialog(),
    );

    if (isAnnihilated == true) {
      final settings = SensorSettingService();
      settings.removeSensor(id);

      final sensorsOpt = settings.getSensors();
      if (sensorsOpt.isEmpty) {
        Navigator.pushReplacement<void, void>(
            context, MaterialPageRoute(builder: (_) => SensorRegisterPage()));
      } else {
        setState(() {
          sensors = sensorsOpt.value;
        });
      }
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IftemAppBar(
        title: const Text('IFtem'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
        child: ListView.builder(
          itemCount: 1 + sensors.length,
          itemBuilder: (_, index) {
            if (index == 0) {
              return Container(height: 15);
            }
            return _SensorCard(
              sensor: sensors[index - 1],
              onDelete: _onDelete,
            );
          },
        ),
      ),
      floatingActionButton: FabCircularMenu(
        key: _fabKey,
        ringDiameter: MediaQuery.of(context).size.width * 0.66,
        animationDuration: const Duration(milliseconds: 450),
        children: <Widget>[
          IconButton(
              tooltip: 'Information',
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _fabKey.currentState.close();
                // TODO(knukro): About page
              }),
          IconButton(
              tooltip: 'Sensor konfigurieren',
              icon: const Icon(Icons.device_hub),
              onPressed: () async {
                await Navigator.push<void>(context,
                        MaterialPageRoute(builder: (_) => SensorConfigPage()))
                    .then((value) => _fabKey.currentState.close());
                _fabKey.currentState.close();
              }),
          IconButton(
              tooltip: 'Sensor hinzufügen',
              icon: const Icon(Icons.person_add),
              onPressed: () async {
                await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => SensorRegisterPage()));
                _fabKey.currentState.close();
              }),
        ],
      ),
    );
  }
}

class _SensorCard extends StatefulWidget {
  final RegisteredSensor sensor;
  final _IntCallback onDelete;

  const _SensorCard({
    @required this.sensor,
    @required this.onDelete,
  });

  @override
  State createState() => _SensorCardState();
}

class _SensorCardState extends State<_SensorCard> {
  String name;
  ImageProvider image;
  Color _gradientColor;

  @override
  void initState() {
    super.initState();
    name = widget.sensor.name;

    image = FileImage(File(widget.sensor.imagePath));
    PaletteGenerator.fromImageProvider(image).then((palette) {
      _gradientColor = (palette.vibrantColor ?? palette.dominantColor).color;
      if (mounted) {
        setState(() {});
      }
    });
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onTab() async {
    final id = widget.sensor.id;
    final key = widget.sensor.key;
    final data = await BackendService().getSensorData(id, key);
    if (data.isPresent) {
      Navigator.push<void>(context, MaterialPageRoute(builder: (_) {
        return new SensorDetailPage(widget.sensor, data.value);
      }));
    } else {
      final snackbar = IftemSnackbar(
        context,
        label: 'Sensor konnte nicht geladen werden',
        action: SnackBarAction(
          label: 'Erneut versuchen',
          onPressed: _onTab,
        ),
      );
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> _onImage() async {
    final settings = SensorSettingService();
    final file = await showDialog<File>(
      context: context,
      builder: (_) => AddPhotoDialog(widget.sensor.imagePath),
    );

    if (file != null) {
      final thumbnailPath = settings.changeImage(widget.sensor.id, file.path);

      // Update image
      image = FileImage(File(thumbnailPath));
      final palette = await PaletteGenerator.fromImageProvider(image);
      setState(() {
        _gradientColor = (palette.vibrantColor ?? palette.dominantColor).color;
      });
    }
  }

  Future<void> _onEdit() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(),
    );

    if (name != null) {
      final settings = SensorSettingService();
      setState(() {
        this.name = settings.changeName(widget.sensor.id, name);
      });
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    _gradientColor ??= Theme.of(context).cardColor;
    return Card(
      elevation: 0.7,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _gradientColor,
              Theme.of(context).cardColor,
            ],
            stops: const [0.0, 0.3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 80.0,
        alignment: Alignment.center,
        child: ListTile(
          onTap: _onTab,
          leading: Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: image,
              ),
            ),
          ),
          title: Text(name),
          trailing: PopupMenuButton(
            onSelected: (int i) {
              switch (i) {
                case 0:
                  _onImage();
                  break;
                case 1:
                  _onEdit();
                  break;
                case 2:
                  widget.onDelete(widget.sensor.id);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                child: Text('Foto hinzufügen'),
                value: 0,
              ),
              const PopupMenuItem<int>(
                child: Text('Name bearbeiten'),
                value: 1,
              ),
              const PopupMenuItem<int>(
                child: Text('Löschen'),
                value: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
