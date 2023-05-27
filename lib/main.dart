import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:barometer_plugin_n/barometer_plugin.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum MeasurementType {
  HomeLevel,
  TopLevel,
  FCILevel,
  HomeHeight,
}

class _MyAppState extends State<MyApp> {
  double _homeLevelPressure = 0.0;
  double _topLevelPressure = 0.0;
  double _fciLevelPressure = 0.0;
  double _homeLevelHeight = 0.0;
  double _homeHeight = 0.0;
  double _fciLevelHeight = 0.0;
  String _comparisonResult = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      await BarometerPlugin.initialize();
    } on Exception {}
  }

  Future<void> startMeasurement(MeasurementType type) async {
    double pressure = 0.0;
    double height = 0.0;

    if (type == MeasurementType.HomeLevel) {
      pressure = await BarometerPlugin.reading;
      setState(() {
        _homeLevelPressure = 1006.314208984375; // pressure;
        _homeLevelHeight = calculateHeight(pressure);
      });
    } else if (type == MeasurementType.TopLevel) {
      pressure = await BarometerPlugin.reading;
      setState(() {
        _topLevelPressure = 1006.0979003933775; //pressure;
      });
    } else if (type == MeasurementType.FCILevel) {
      pressure = await BarometerPlugin.reading;
      setState(() {
        _fciLevelPressure = pressure;
        _fciLevelHeight = calculateHeight(pressure);
        compareHeights();
      });
    } else if (type == MeasurementType.HomeHeight) {
      pressure = await BarometerPlugin.reading;
      setState(() {
        _homeHeight =
            calculateHomeHeight(_homeLevelPressure, _topLevelPressure);
      });
    }
  }

  double calculateHeight(double pressure) {
    final double seaLevelPressure = 1013.25;
    final double gravity = 9.80665;
    final double temperature = 298.15;
    final double gasConstant = 8.314;
    double height =
        (temperature * gasConstant * math.log(seaLevelPressure / pressure)) /
            (gravity * math.log(2));
    // double height =
    //     (-(pressure - seaLevelPressure) * temperature) / (gravity * 287.053);
    return height;
  }

  double calculateHomeHeight(double bottompressure, toppressure) {
    final double seaLevelPressure = 1013.25;
    final double gravity = 9.80665;
    final double temperature = 298.15;
    final double gasConstant = 8.314;
    // double height =
    //     (-(toppressure - bottompressure) * temperature) / (gravity * 287.053);
    double height =
        (temperature * gasConstant * math.log(bottompressure / toppressure)) /
            (gravity * math.log(2));
    return height;
  }

  void compareHeights() {
    if (_homeLevelHeight > _fciLevelHeight) {
      _comparisonResult = 'Home level is higher than FCI level';
    } else if (_homeLevelHeight < _fciLevelHeight) {
      _comparisonResult = 'FCI level is higher than home level';
    } else {
      _comparisonResult = 'Both levels are at the same height';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Barometer Plugin Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                child: Text("Measure Home Level Pressure"),
                onPressed: () {
                  startMeasurement(MeasurementType.HomeLevel);
                },
              ),
              ElevatedButton(
child: Text("Measure Top Level Pressure"),
                onPressed: () {
                  startMeasurement(MeasurementType.TopLevel);
                },
              ),
              ElevatedButton(
                child: Text("Measure Home height"),
                onPressed: () {
                  startMeasurement(MeasurementType.HomeHeight);
                },
              ),
              ElevatedButton(
                child: Text("Measure FCI Level Pressure"),
                onPressed: () {
                  startMeasurement(MeasurementType.FCILevel);
                },
              ),
              SizedBox(height: 20),
              Text('Home Level Pressure: $_homeLevelPressure'),
              Text('Top Level Pressure: $_topLevelPressure'),
              Text('FCI Level Pressure: $_fciLevelPressure'),
              Text('Home Level Height: $_homeLevelHeight meters'),
              Text('FCI Level Height: $_fciLevelHeight meters'),
              Text('Home Height: $_homeHeight meters'),
              SizedBox(height: 10),
              Text('Comparison Result: $_comparisonResult'),
            ],
          ),
        ),
      ),
    );
  }
}