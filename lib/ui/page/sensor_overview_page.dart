import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ripe/service/backend_service.dart';
import 'package:ripe/service/sensor_setting_service.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:ripe/ui/component/platform.dart';
import 'package:ripe/ui/page/about_page.dart';
import 'package:ripe/ui/page/detail/sensor_detail_page.dart';
import 'package:ripe/ui/page/dialog/delete_sensor_dialog.dart';
import 'package:ripe/ui/page/dialog/edit_name_dialog.dart';
import 'package:ripe/ui/page/sensor_config_page.dart';
import 'package:ripe/ui/page/sensor_register_page.dart';

import 'dialog/add_photo_dialog.dart';

typedef _IntCallback = void Function(int id);

class SensorOverviewPage extends StatefulWidget {
  @override
  State createState() => _SensorOverviewPageState();
}

class _SensorOverviewPageState extends State<SensorOverviewPage> {
  //final _fabKey = new GlobalKey<Object>();
  late List<RegisteredSensor> _sensors;

  /*
   * Constructor/Destructor
   */

  @override
  void initState() {
    super.initState();
    _sensors = SensorSettingService.getInstance().getSensors();
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
      final settings = SensorSettingService.getInstance();
      settings.removeSensor(id);

      final sensors = settings.getSensors();
      setState(() => _sensors = sensors);
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (context) {
      return Scaffold(
        appBar: RipeAppBar(
          title: const Text('RIPE'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: ListView.builder(
            itemCount: 1 + _sensors.length,
            itemBuilder: (_, index) {
              if (index == 0) {
                return Container(height: 15);
              }
              return _SensorCard(
                sensor: _sensors[index - 1],
                onDelete: _onDelete,
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) async => {
            await Navigator.push<void>(context,
                MaterialPageRoute<void>(builder: (_) {
              if (index == 0) {
                return SensorRegisterPage();
              } else if (index == 1) {
                return SensorConfigPage();
              }
              return AboutPage();
            }))
          },
          items: const [
            BottomNavigationBarItem(
              label: 'Sensor hinzufügen',
              icon: Icon(Icons.add_to_queue, color: Colors.white),
            ),
            BottomNavigationBarItem(
              label: 'Sensor konfigurieren',
              icon: Icon(Icons.settings,
                  color: Colors.white),
            ),
            BottomNavigationBarItem(
              label: 'Über diese App',
              icon: Icon(Icons.info_outline, color: Colors.white),
            ),
          ],
        ),
      );
    }));
  }
}

class _SensorCard extends StatefulWidget {
  final RegisteredSensor sensor;
  final _IntCallback onDelete;

  const _SensorCard({
    required this.sensor,
    required this.onDelete,
  });

  @override
  State createState() => _SensorCardState();
}

class _SensorCardState extends State<_SensorCard> {
  late RegisteredSensor _sensor;

  @override
  void initState() {
    super.initState();
    _sensor = widget.sensor;
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onTab() async {
    final id = widget.sensor.id;
    final key = widget.sensor.key;
    final data = await BackendService().getSensorStatus(id, key);
    if (data != null) {
      Navigator.push<void>(context, MaterialPageRoute(builder: (_) {
        return new SensorDetailPage(_sensor, data);
      }));
    } else {
      final snackbar = RipeSnackbar(
        context,
        label: 'Sensor konnte nicht geladen werden',
        action: SnackBarAction(
          label: 'Erneut versuchen',
          onPressed: _onTab,
        ),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> _onImage() async {
    final settings = SensorSettingService.getInstance();
    final file = await showDialog<File>(
      context: context,
      builder: (_) => AddPhotoDialog(
        widget.sensor.thumbPath,
        widget.sensor.imageColor,
      ),
    );

    if (file != null) {
      // clear file image cache
      PaintingBinding.instance.imageCache
          .evict(FileImage(File(_sensor.thumbPath)));

      final sensor = await settings.changeImage(widget.sensor.id, file.path);
      setState(() => _sensor = sensor);
    }
  }

  Future<void> _onEdit() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => EditNameDialog(),
    );

    if (name != null) {
      final settings = SensorSettingService.getInstance();
      setState(() => _sensor = settings.changeName(widget.sensor.id, name));
    }
  }

/*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.7,
      child: InkWell(
        onTap: _onTab,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _sensor.imageColor,
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
            leading: Container(
              width: 60.0,
              height: 60.0,
              key: UniqueKey(),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: PlatformAssetImage(_sensor.thumbPath),
                ),
              ),
            ),
            title: Text(_sensor.name),
            trailing: PopupMenuButton(onSelected: (int i) {
              switch (i) {
                case 0:
                  _onImage();
                  break;
                case 1:
                  _onEdit();
                  break;
                case 2:
                  widget.onDelete(_sensor.id);
                  break;
              }
            }, itemBuilder: (BuildContext context) {
              final entries = <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  child: Text('Name bearbeiten'),
                  value: 1,
                ),
                const PopupMenuItem<int>(
                  child: Text('Löschen'),
                  value: 2,
                ),
              ];
              if (!kIsWeb) {
                entries.insert(
                    0,
                    const PopupMenuItem<int>(
                      child: Text('Foto bearbeiten'),
                      value: 0,
                    ));
              }
              return entries;
            }),
          ),
        ),
      ),
    );
  }
}
