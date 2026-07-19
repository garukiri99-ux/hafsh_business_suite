import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/bluetooth_printer_service.dart';

final bluetoothPrinterServiceProvider =
    Provider<BluetoothPrinterService>((ref) {
  return BluetoothPrinterService();
});