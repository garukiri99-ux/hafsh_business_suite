import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/printer_state.dart';
import '../../services/bluetooth_printer_service.dart';

class PrinterController extends Notifier<PrinterState> {
  final BluetoothPrinterService _service = BluetoothPrinterService();

  @override
  PrinterState build() {
    return PrinterState.initial();
  }

  Future<void> loadPrinters() async {
    state = state.copyWith(loading: true);

    try {
      final granted = await _service.requestPermissions();

      if (!granted) {
        state = state.copyWith(
          bluetoothEnabled: false,
          connected: false,
          printers: [],
          loading: false,
        );
        return;
      }

      final pluginGranted = await _service.isPermissionGranted();

      if (!pluginGranted) {
        state = state.copyWith(
          bluetoothEnabled: false,
          connected: false,
          printers: [],
          loading: false,
        );
        return;
      }

      final bluetooth = await _service.isBluetoothEnabled();

      if (!bluetooth) {
        state = state.copyWith(
          bluetoothEnabled: false,
          connected: false,
          printers: [],
          loading: false,
        );
        return;
      }

      final connected = await _service.isConnected();
      final printers = await _service.getPairedPrinters();

      state = state.copyWith(
        bluetoothEnabled: bluetooth,
        connected: connected,
        printers: printers,
        loading: false,
      );
    } catch (e) {
      debugPrint("Printer Error: $e");

      state = state.copyWith(
        bluetoothEnabled: false,
        connected: false,
        printers: [],
        loading: false,
      );
    }
  }

  Future<void> connect(String mac) async {
    state = state.copyWith(loading: true);

    try {
      final ok = await _service.connect(mac);

      state = state.copyWith(
        connected: ok,
        loading: false,
      );
    } catch (e) {
      debugPrint("Connect Error: $e");

      state = state.copyWith(
        connected: false,
        loading: false,
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await _service.disconnect();

      state = state.copyWith(
        connected: false,
      );
    } catch (e) {
      debugPrint("Disconnect Error: $e");
    }
  }

  Future<void> printTest() async {
    try {
      await _service.printTest();
    } catch (e) {
      debugPrint("Print Error: $e");
    }
  }
}

final printerControllerProvider =
    NotifierProvider<PrinterController, PrinterState>(
  PrinterController.new,
);