import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:ripe/db/shared.dart';
import 'package:ripe/service/models/sensor.dart';
import 'package:ripe/util/log.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';

typedef ValueGetter = double Function(SensorDaoData);
typedef DataBuilder = SensorDaoData Function(SensorDaoData, double);

class SensorDataGraphAdapter {
  final ValueGetter getter;
  final DataBuilder builder;

  SensorDataGraphAdapter({required this.getter, required this.builder});
}

class SensorDataGraphConfig {
  final SensorDataGraphAdapter adapter;
  final Color color;
  final double axisPadding;

  SensorDataGraphConfig({
    required this.adapter,
    required this.color,
    required this.axisPadding,
  });
}

class SensorDataChart extends StatefulWidget {
  final RegisteredSensor sensor;
  final SensorDataGraphConfig config;
  final List<SensorDaoData>? data;

  const SensorDataChart({
    Key? key,
    required this.sensor,
    required this.config,
    required this.data,
  }) : super(key: key);

  @override
  State createState() => SensorDataChartState();
}

class SensorDataChartState extends State<SensorDataChart> {
  List<SensorDaoData>? displayData;

  final labelFactorY = 10;
  late int labelFactorX;
  late List<SensorDaoData> rawData;
  late double minY;
  late double maxY;

  int _lineConvolution = 5;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      rawData = widget.data!;
    }
    Future(() async {
      _smoothDataAndPlot();
    });
  }

  void setRawData(List<SensorDaoData> data) {
    _lineConvolution = max(1, data.length ~/ 150);
    Log.debug('Convolution kernel is set to $_lineConvolution');
    _smoothDataAndPlot();
  }

  void _smoothDataAndPlot() {
    final start = DateTime.now().microsecondsSinceEpoch;
    final adapter = widget.config.adapter;
    final span = _lineConvolution;
    final values = Array(rawData.map(adapter.getter).toList());
    final kernel = Array(List.filled(span * 2 + 1, 1 / (span * 2 + 1)));
    final smoothedValues = convolution(values, kernel);

    final kValues = <SensorDaoData>[];
    final k = span + log(span).round() + 1;
    for (int i = span * 2; i < rawData.length; i += k) {
      kValues.add(adapter.builder(rawData[i], smoothedValues[i]));
    }

    final end = DateTime.now().microsecondsSinceEpoch;
    final delta = Duration(microseconds: end - start);

    Log.info('Plotting ${kValues.length} values in ${delta.inMilliseconds}ms');
    if (mounted) {
      setState(() => displayData = kValues);
    }
  }

  List<ChartLayer> layers() {
    final adapter = widget.config.adapter;
    final minX = displayData!.first.timestamp.millisecondsSinceEpoch.toDouble();
    final maxX = displayData!.last.timestamp.millisecondsSinceEpoch.toDouble();

    final minY = max(
        0.0,
        displayData!.fold<double>(0xfffff,
                (value, element) => min(value, adapter.getter(element))) -
            widget.config.axisPadding);
    final maxY = displayData!.fold<double>(
            0, (value, element) => max(value, adapter.getter(element))) +
        widget.config.axisPadding;

    final labelFrequencyX = max(1.0, (maxX - minX) / labelFactorX);
    final labelFrequencyY = max(1.0, (maxY - minY) / labelFactorY);

    return [
      ChartGridLayer(
        settings: ChartGridSettings(
          x: ChartGridSettingsAxis(
            color: Colors.white10,
            frequency: labelFrequencyX,
            min: minX,
            max: maxX,
          ),
          y: ChartGridSettingsAxis(
            color: Colors.white10,
            frequency: labelFrequencyY,
            max: maxY,
            min: minY,
          ),
        ),
      ),
      ChartAxisLayer(
        settings: ChartAxisSettings(
          x: ChartAxisSettingsAxis(
            frequency: labelFrequencyX,
            max: maxX,
            min: minX,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
          y: ChartAxisSettingsAxis(
            frequency: labelFrequencyY,
            max: maxY,
            min: minY,
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10.0,
            ),
          ),
        ),
        labelX: (value) => DateFormat('dd.MM\nHH:mm')
            .format(DateTime.fromMillisecondsSinceEpoch(value.toInt())),
        labelY: (value) => value.toInt().toString(),
      ),
      ChartLineLayer(
        items: (displayData ?? [])
            .map(
              (e) => ChartLineDataItem(
                x: e.timestamp.millisecondsSinceEpoch.toDouble(),
                value: widget.config.adapter.getter(e),
              ),
            )
            .toList(growable: false),
        settings: ChartLineSettings(
          color: widget.config.color,
          thickness: 4.0,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if ((displayData?.length ?? 0) <= 2) {
      return const Center(
        child: Text('Keine Daten verfügar'),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final aspectRatio = constraints.maxWidth < 620 ? 5 / 4 : 21 / 9;
      labelFactorX = constraints.maxWidth ~/ 120;

      return Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Chart(
              layers: layers(),
            ),
          ),
        ),
      );
    });
  }
}
