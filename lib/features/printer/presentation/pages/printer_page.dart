import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/printer_controller.dart';

class PrinterPage extends ConsumerWidget {
  const PrinterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(printerControllerProvider);
    final controller =
        ref.read(printerControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Printer"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.loadPrinters,
        child: const Icon(Icons.search),
      ),
      body: state.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: Icon(
                    state.bluetoothEnabled
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                  ),
                  title: Text(
                    state.bluetoothEnabled
                        ? "Bluetooth ON"
                        : "Bluetooth OFF",
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Paired Printer",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                ...state.printers.map(
                  (printer) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.print),
                      title: Text(printer.name),
                      subtitle: Text(printer.macAdress),
                      trailing: ElevatedButton(
                        onPressed: () {
                          debugPrint(
                              "======================================");
                          debugPrint(
                              "Printer Name : ${printer.name}");
                          debugPrint(
                              "Printer MAC  : ${printer.macAdress}");
                          debugPrint("Start Connect...");

                          controller.connect(
                            printer.macAdress,
                          );
                        },
                        child: const Text("CONNECT"),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (state.connected)
                  FilledButton.icon(
                    onPressed: controller.printTest,
                    icon: const Icon(Icons.print),
                    label: const Text(
                      "PRINT TEST",
                    ),
                  ),
              ],
            ),
    );
  }
}