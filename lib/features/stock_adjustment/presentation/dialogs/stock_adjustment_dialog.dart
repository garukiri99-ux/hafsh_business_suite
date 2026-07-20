import 'package:flutter/material.dart';

enum StockAdjustmentType {
  add,
  subtract,
  set,
}

class StockAdjustmentResult {
  const StockAdjustmentResult({
    required this.type,
    required this.quantity,
    required this.note,
  });

  final StockAdjustmentType type;
  final double quantity;
  final String note;
}

class StockAdjustmentDialog extends StatefulWidget {
  const StockAdjustmentDialog({
    super.key,
    required this.productName,
    required this.currentStock,
  });

  final String productName;
  final double currentStock;

  @override
  State<StockAdjustmentDialog> createState() =>
      _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState
    extends State<StockAdjustmentDialog> {
  final _formKey = GlobalKey<FormState>();

  final _qtyController = TextEditingController();
  final _noteController = TextEditingController();

  StockAdjustmentType _type =
      StockAdjustmentType.add;

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final quantity =
        double.tryParse(_qtyController.text) ?? 0;

    Navigator.pop(
      context,
      StockAdjustmentResult(
        type: _type,
        quantity: quantity,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adjust Stock'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Stok saat ini : ${widget.currentStock}',
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<
                    StockAdjustmentType>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Penyesuaian',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                          StockAdjustmentType.add,
                      child: Text(
                        'Tambah Stok',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          StockAdjustmentType.subtract,
                      child: Text(
                        'Kurangi Stok',
                      ),
                    ),
                    DropdownMenuItem(
                      value:
                          StockAdjustmentType.set,
                      child: Text(
                        'Set Stok',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _type = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _qtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Jumlah wajib diisi';
                    }

                    final qty =
                        double.tryParse(value);

                    if (qty == null) {
                      return 'Jumlah tidak valid';
                    }

                    if (qty <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText: 'Catatan',
                    border: OutlineInputBorder(),
                    hintText:
                        'Contoh: Stock Opname, Barang Masuk, Barang Rusak',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save),
          label: const Text('Simpan'),
        ),
      ],
    );
  }
}