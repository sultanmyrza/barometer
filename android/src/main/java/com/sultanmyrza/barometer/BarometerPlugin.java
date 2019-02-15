package com.sultanmyrza.barometer;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorEventListener2;
import android.hardware.SensorListener;
import android.hardware.SensorManager;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.content.Context.SENSOR_SERVICE;

/** BarometerPlugin */
public class BarometerPlugin implements MethodCallHandler , SensorEventListener, EventChannel.StreamHandler{
  private SensorManager mSensorManager;
  private Sensor mBarometer;
  private Registrar mRegistrar;
  private float mLatestReading = 0;
  private EventChannel.EventSink mEventSink;

  public BarometerPlugin(Registrar mRegistrar) {
    this.mRegistrar = mRegistrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "barometer");

    BarometerPlugin plugin = new BarometerPlugin(registrar);
    channel.setMethodCallHandler(plugin);

    final EventChannel eventChannel = new EventChannel(registrar.messenger(), "pressureStream");
    eventChannel.setStreamHandler(plugin);
  }

boolean initializeBarometer() {
    mSensorManager = (SensorManager)(mRegistrar.activeContext().getSystemService(SENSOR_SERVICE));
    mBarometer = mSensorManager.getDefaultSensor(Sensor.TYPE_PRESSURE);
    mSensorManager.registerListener(this, mBarometer, SensorManager.SENSOR_DELAY_NORMAL);
    return true;
}


  float getBarometer() {

    return mLatestReading;
  }


  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    else if(call.method.equals("getBarometer")){
//      throw new IllegalArgumentException();
      double reading = getBarometer();
      result.success(reading);
    } else if (call.method.equals("initializeBarometer")) {
      result.success(initializeBarometer());
      return;
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onSensorChanged(SensorEvent event) {
    mLatestReading = event.values[0];
    if (mEventSink != null) {
      mEventSink.success(mLatestReading);
    }
  }

  @Override
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
  }

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    mEventSink = eventSink;
  }

  @Override
  public void onCancel(Object o) {
    mEventSink = null;
  }
}
