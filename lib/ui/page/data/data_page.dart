import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ripe/db/shared.dart';
import 'package:ripe/service/sensor_history_service.dart';
import 'package:ripe/service/sensor_setting_service.dart';
import 'package:ripe/ui/component/animated_loading_spinner.dart';
import 'package:ripe/ui/component/branded.dart';

import 'sensor_data_chart.dart';

class DataPage extends StatefulWidget {
  final RegisteredSensor sensor;
  final int initialSelected;

  const DataPage(this.sensor, this.initialSelected);

  @override
  State createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final graphKey = new GlobalKey<SensorDataChartState>();
  final loadingKey = new GlobalKey<AnimatedLoadingSpinnerState>();
  final data = <SensorDataDao>[];

  late SensorHistoryService _historyService;
  late DateTime _from;
  late DateTime _until;
  late int _selectedIndex;
  bool isFetching = false;

  final _configs = <SensorDataGraphConfig>[
    SensorDataGraphConfig(
      color: Colors.redAccent,
      axisPadding: 1,
      adapter: SensorDataGraphAdapter(
        getter: (data) => data.temperature ?? 0.0,
        builder: (data, value) => data.copyWith(temperature: Value(value)),
      ),
    ),
    SensorDataGraphConfig(
      color: Colors.lightBlue,
      axisPadding: 5,
      adapter: SensorDataGraphAdapter(
        getter: (data) => data.moisture ?? 0.0,
        builder: (data, value) => data.copyWith(moisture: Value(value)),
      ),
    ),
    SensorDataGraphConfig(
      color: Colors.lightGreen,
      axisPadding: 25,
      adapter: SensorDataGraphAdapter(
        getter: (data) => data.conductivity?.toDouble() ?? 0.0,
        builder: (data, value) =>
            data.copyWith(conductivity: Value(value.toInt())),
      ),
    ),
    SensorDataGraphConfig(
      color: Colors.amber,
      axisPadding: 25,
      adapter: SensorDataGraphAdapter(
        getter: (data) => data.light?.toDouble() ?? 0.0,
        builder: (data, value) => data.copyWith(light: Value(value.toInt())),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _historyService = new SensorHistoryService(widget.sensor);
    _selectedIndex = widget.initialSelected;
    _until = _historyService.normalizeDate(DateTime.now());
    _from = _until.subtract(const Duration(days: 7));
    fetchAndRebuild();
  }

  Future<void> fetchAndRebuild() async {
    data.clear();

    final historyData =
        await _historyService.getHistoryData(_from, _until, (isLoading) {
      loadingKey.currentState?.setShowing(isLoading);
    });
    data.addAll(historyData);

    graphKey.currentState?.setRawData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RipeAppBar(
        centerTitle: true,
        title: Container(
          width: 320,
          child: Row(
            children: [
              OutlinedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white30),
                ),
                child: Text(
                  'Vom: ' + DateFormat('dd.MM').format(_from),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                onPressed: () {
                  Future(() async {
                    final first = await _historyService.getFirstData();

                    final newFrom = await showDatePicker(
                      context: context,
                      initialDate: _from,
                      firstDate: first,
                      lastDate: _until,
                    );
                    if (newFrom == null) {
                      return;
                    }

                    _from = newFrom;
                    fetchAndRebuild();
                  });
                },
              ),
              Text(
                '-',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              OutlinedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.white30),
                ),
                child: Text(
                  'Bis: ' + DateFormat('dd.MM').format(_until),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                onPressed: () {
                  Future(() async {
                    final newUntil = await showDatePicker(
                      context: context,
                      initialDate: _until,
                      firstDate: _from,
                      lastDate: DateTime.now(),
                    );
                    if (newUntil == null) {
                      return;
                    }

                    _until = newUntil;
                    fetchAndRebuild();
                  });
                },
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6.0),
            child: AnimatedLoadingSpinner(key: loadingKey)),
      ),
      body: SensorDataChart(
        key: graphKey,
        data: data,
        sensor: widget.sensor,
        config: _configs[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Theme.of(context).textTheme.titleSmall!.color,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.whatshot,
              color: Theme.of(context).iconTheme.color,
            ),
            activeIcon: const Icon(
              Icons.whatshot_outlined,
              color: Colors.redAccent,
            ),
            label: 'Temperature',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pool_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            activeIcon: const Icon(
              Icons.pool_outlined,
              color: Colors.lightBlue,
            ),
            label: 'Feuchtigkeit',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.power_settings_new,
              color: Theme.of(context).iconTheme.color,
            ),
            activeIcon: const Icon(
              Icons.power_settings_new_outlined,
              color: Colors.lightGreen,
            ),
            label: 'Leitbarkeit',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.brightness_4,
              color: Theme.of(context).iconTheme.color,
            ),
            activeIcon: const Icon(
              Icons.brightness_4,
              color: Colors.amber,
            ),
            label: 'Helligkeit',
          ),
        ],
      ),
    );
  }
}
