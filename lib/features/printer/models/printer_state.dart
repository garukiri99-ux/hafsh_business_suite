import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterState {
  final bool bluetoothEnabled;
  final bool connected;
  final bool loading;
  final List<BluetoothInfo> printers;

  const PrinterState({
    required this.bluetoothEnabled,
    required this.connected,
    required this.loading,
    required this.printers,
  });

  factory PrinterState.initial() {
    return const PrinterState(
      bluetoothEnabled: false,
      connected: false,
      loading: false,
      printers: [],
    );
  }

  PrinterState copyWith({
    bool? bluetoothEnabled,
    bool? connected,
    bool? loading,
    List<BluetoothInfo>? printers,
  }) {
    return PrinterState(
      bluetoothEnabled:
          bluetoothEnabled ?? this.bluetoothEnabled,
      connected: connected ?? this.connected,
      loading: loading ?? this.loading,
      printers: printers ?? this.printers,
    );
  }
}