import 'package:flutter/material.dart';

class StockAdjustmentFormPage extends StatelessWidget {
  const StockAdjustmentFormPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Halaman Form Stock Adjustment\n\n'
            'Fitur ini akan dikembangkan pada langkah berikutnya.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}