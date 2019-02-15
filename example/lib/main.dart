import 'dart:async';

import 'package:barometer/barometer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  double _reading = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      double barometer = await Barometer.barometerReading;
      print("Barometes is $barometer}");
      await Barometer.initialize();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                'Platform version: $_reading\n',
                style: Theme.of(context).textTheme.headline,
              ),
            ),
            RaisedButton(
              child: Text(
                "Get lates reading",
              ),
              onPressed: () async {
                final double reading = await Barometer.barometerReading;
                setState(() {
                  _reading = reading;
                });
              },
            ),
            StreamBuilder(
              stream: Barometer.pressureStream,
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                if (snapshot.hasData) {
                  return Text("PRESSURE STREAM ${snapshot.data}");
                } else {
                  return Text("NO data");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
