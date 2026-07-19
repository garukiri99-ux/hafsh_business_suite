import 'package:flutter/material.dart';

class PrinterPage extends StatelessWidget {
  const PrinterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printer'),
      ),
      body: const Center(
        child: Text('Printer Module'),
      ),
    );
  }
}