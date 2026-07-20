import 'dart:developer';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothPrinterService {
  /// Request runtime permission (Android 12+)
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    log("========== REQUEST PERMISSION ==========");

    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final bluetoothScan = await Permission.bluetoothScan.request();
    final location = await Permission.locationWhenInUse.request();

    log("Bluetooth Connect : ${bluetoothConnect.isGranted}");
    log("Bluetooth Scan    : ${bluetoothScan.isGranted}");
    log("Location          : ${location.isGranted}");

    return bluetoothConnect.isGranted &&
        bluetoothScan.isGranted &&
        location.isGranted;
  }

  /// Check permission after request
  Future<bool> isPermissionGranted() async {
    final granted =
        await PrintBluetoothThermal.isPermissionBluetoothGranted;

    log("Plugin Permission : $granted");

    return granted;
  }

  Future<bool> isBluetoothEnabled() async {
    final enabled =
        await PrintBluetoothThermal.bluetoothEnabled;

    log("Bluetooth Enabled : $enabled");

    return enabled;
  }

  /// Load paired printers
  Future<List<BluetoothInfo>> getPairedPrinters() async {
    final granted = await requestPermissions();

    if (!granted) {
      throw Exception(
        "Bluetooth permission denied. Please allow Nearby Devices permission.",
      );
    }

    final pluginGranted = await isPermissionGranted();

    if (!pluginGranted) {
      throw Exception(
        "Bluetooth permission not granted by plugin.",
      );
    }

    final printers =
        await PrintBluetoothThermal.pairedBluetooths;

    log("========== PAIRED PRINTER ==========");

    for (final printer in printers) {
      log("Name : ${printer.name}");
      log("MAC  : ${printer.macAdress}");
      log("------------------------------");
    }

    return printers;
  }

  Future<bool> connect(String macAddress) async {
    log("====================================");
    log("CONNECT TO : $macAddress");

    final result = await PrintBluetoothThermal.connect(
      macPrinterAddress: macAddress,
    );

    log("CONNECT RESULT : $result");

    final connected =
        await PrintBluetoothThermal.connectionStatus;

    log("CONNECTION STATUS : $connected");
    log("====================================");

    return result;
  }

  Future<bool> disconnect() async {
    log("Disconnect Printer");

    final result =
        await PrintBluetoothThermal.disconnect;

    log("Disconnect Result : $result");

    return result;
  }

  Future<bool> isConnected() async {
    final connected =
        await PrintBluetoothThermal.connectionStatus;

    log("Current Connection : $connected");

    return connected;
  }

  Future<bool> printTest() async {
    log("Start Print Test");

    final result =
        await PrintBluetoothThermal.writeString(
      printText: PrintTextSize(
        size: 2,
        text: '''
==============================
      HAFSH COFFEE
==============================

HAFSH COFFEE TEST

==============================

''',
      ),
    );

    log("Print Result : $result");

    return result;
  }
}