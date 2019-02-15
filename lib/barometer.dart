import 'dart:async';

import 'package:flutter/services.dart';

class Barometer {
  static const MethodChannel _channel = const MethodChannel('barometer');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<double> get barometerReading async {
    final double result = await _channel.invokeMethod('getBarometer');
    return result;
  }

  static Future<bool> initialize() async {
    final bool platformResponse =
        await _channel.invokeMethod("initializeBarometer");
    print("Platform response is $platformResponse");
  }

  static const EventChannel _eventChannel = EventChannel("pressureStream");

  static Stream<double> _pressureStream;

  static Stream<double> get pressureStream {
    if (_pressureStream == null) {
      _pressureStream =
          _eventChannel.receiveBroadcastStream().map<double>((value) => value);
    }
    return _pressureStream;
  }
}
