import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/inventory/stock_adjustment_reason.dart';
import '../../../../core/inventory/stock_adjustment_type.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/providers/product_provider.dart';
import '../../../stock_adjustment/domain/entities/stock_adjustment.dart';
import '../../../stock_adjustment/providers/stock_adjustment_provider.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/purchase_order_item.dart';
import '../providers/purchase_order_detail_controller.dart';

class PurchaseOrderReceivePage extends ConsumerStatefulWidget {
  const PurchaseOrderReceivePage({
    super.key,
    required this.purchaseOrder,
  });

  final PurchaseOrder purchaseOrder;

  @override
  ConsumerState<PurchaseOrderReceivePage> createState() =>
      _PurchaseOrderReceivePageState();
}

class _PurchaseOrderReceivePageState
    extends ConsumerState<PurchaseOrderReceivePage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {};

  void _log(String message) {
    debugPrint('[RECEIVE] $message');
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      _log(
        'load Purchase Order ${widget.purchaseOrder.id}',
      );

      ref
          .read(
            purchaseOrderDetailControllerProvider.notifier,
          )
          .load(widget.purchaseOrder.id);
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  TextEditingController _controllerFor(
    PurchaseOrderItem item,
  ) {
    return _controllers.putIfAbsent(
      item.id,
      () => TextEditingController(
        text: item.remainingQuantity
            .toStringAsFixed(2)
            .replaceFirst(
              RegExp(r'\.00$'),
              '',
            ),
      ),
    );
  }

  double _parseDouble(String value) {
    return double.tryParse(
          value.replaceAll(',', '.').trim(),
        ) ??
        0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  bool _hasRemainingQuantity(
    List<PurchaseOrderItem> items,
  ) {
    return items.any(
      (item) => item.remainingQuantity > 0,
    );
  }

  String _calculateStatus(
    List<PurchaseOrderItem> items,
  ) {
    if (items.isEmpty) {
      return widget.purchaseOrder.status;
    }

    final allReceived = items.every(
      (item) => item.receivedQuantity >= item.quantity,
    );

    if (allReceived) {
      return 'received';
    }

    final someReceived = items.any(
      (item) => item.receivedQuantity > 0,
    );

    if (someReceived) {
      return 'partial';
    }

    return widget.purchaseOrder.status;
  }

  Future<Product> _findProduct(
    String productId,
  ) async {
    _log(
      'Mencari product $productId langsung melalui repository...',
    );

    final product = await ref
        .read(productRepositoryProvider)
        .getProductById(
          productId,
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw StateError(
              'Timeout saat mengambil produk '
              'dari Firestore.',
            );
          },
        );

    if (product == null) {
      throw StateError(
        'Produk dengan ID $productId tidak ditemukan di Inventory.',
      );
    }

    _log(
      'Produk ditemukan: ${product.name}, '
      'stok=${product.stock}',
    );

    return product;
  }

  Future<void> _processReceive(
    PurchaseOrderDetailState detail,
  ) async {
    _log('=== MULAI RECEIVE GOODS ===');

    if (!_formKey.currentState!.validate()) {
      _log('Validasi form gagal.');
      return;
    }

    _log('Validasi form berhasil.');

    final itemsToReceive = <PurchaseOrderItem>[];
    final receiveQuantities = <String, double>{};

    for (final item in detail.items) {
      final controller = _controllers[item.id];

      if (controller == null) {
        _log(
          'Controller tidak ditemukan untuk item ${item.id}.',
        );
        continue;
      }

      final receiveQuantity =
          _parseDouble(controller.text);

      _log(
        'Item ${item.productName}: '
        'qtyReceive=$receiveQuantity, '
        'remaining=${item.remainingQuantity}',
      );

      if (receiveQuantity <= 0) {
        continue;
      }

      if (receiveQuantity > item.remainingQuantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Jumlah penerimaan ${item.productName} '
              'melebihi sisa yang tersedia.',
            ),
          ),
        );

        return;
      }

      itemsToReceive.add(
        item.copyWith(
          receivedQuantity:
              item.receivedQuantity + receiveQuantity,
        ),
      );

      receiveQuantities[item.id] =
          receiveQuantity;
    }

    if (itemsToReceive.isEmpty) {
      _log('Tidak ada item yang diterima.');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masukkan jumlah barang yang diterima.',
          ),
        ),
      );

      return;
    }

    _log(
      'Jumlah item yang akan diproses: '
      '${itemsToReceive.length}',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Proses Penerimaan?',
          ),
          content: Text(
            '${itemsToReceive.length} item akan diproses '
            'sebagai barang diterima.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Proses'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      _log('User membatalkan proses penerimaan.');
      return;
    }

    _log('Konfirmasi diterima. Masuk ke proses database.');

    try {
      _log(
        'Membaca purchaseOrderDetailController...',
      );

      final controller = ref.read(
        purchaseOrderDetailControllerProvider.notifier,
      );

      _log(
        'Membaca stockAdjustmentController...',
      );

      final stockAdjustmentController =
          ref.read(
        stockAdjustmentControllerProvider.notifier,
      );

      _log(
        'Kedua controller berhasil diperoleh.',
      );

      for (final item in itemsToReceive) {
        final receiveQuantity =
            receiveQuantities[item.id] ?? 0;

        if (receiveQuantity <= 0) {
          continue;
        }

        _log(
          '--- Memproses ${item.productName} '
          'qty=$receiveQuantity ---',
        );

        final product = await _findProduct(
          item.productId,
        );

        final stockBefore = product.stock;
        final stockAfter =
            stockBefore + receiveQuantity;

        _log(
          'Stock calculation: '
          '$stockBefore + $receiveQuantity = $stockAfter',
        );

        if (stockAfter < 0) {
          throw StateError(
            'Stok produk ${product.name} tidak boleh negatif.',
          );
        }

        _log(
          'Sebelum updateItem()...',
        );

        await controller.updateItem(item);

        _log(
          'updateItem() BERHASIL.',
        );

        final adjustment = StockAdjustment(
          id: DateTime.now()
              .microsecondsSinceEpoch
              .toString(),
          productId: item.productId,
          productName: item.productName,
          type: StockAdjustmentType.stockIn,
          quantity: receiveQuantity,
          stockBefore: stockBefore,
          stockAfter: stockAfter,
          reason: StockAdjustmentReason.purchase,
          notes:
              'Penerimaan barang dari '
              'Purchase Order ${widget.purchaseOrder.number}.',
          referenceType: 'purchase_order',
          referenceId: widget.purchaseOrder.id,
          createdBy: null,
          createdAt: DateTime.now(),
        );

        _log(
          'StockAdjustment object berhasil dibuat.',
        );

        _log(
          'Sebelum addAdjustment()...',
        );

        await stockAdjustmentController
            .addAdjustment(adjustment)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw StateError(
                  'Timeout saat menyimpan Stock Adjustment '
                  'ke Firestore.',
                );
              },
            );

        _log(
          'addAdjustment() BERHASIL.',
        );
      }

      _log(
        'Semua item selesai diproses.',
      );

      final updatedItems =
          detail.items.map((item) {
        final updatedItem =
            itemsToReceive.cast<
                PurchaseOrderItem?>().firstWhere(
          (receivedItem) =>
              receivedItem!.id == item.id,
          orElse: () => null,
        );

        return updatedItem ?? item;
      }).toList();

      final updatedStatus =
          _calculateStatus(updatedItems);

      _log(
        'Status PO baru: $updatedStatus',
      );

      final updatedPurchaseOrder =
          widget.purchaseOrder.copyWith(
        status: updatedStatus,
        updatedAt: DateTime.now(),
      );

      _log(
        'Sebelum updatePurchaseOrder()...',
      );

      await controller
          .updatePurchaseOrder(
            updatedPurchaseOrder,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw StateError(
                'Timeout saat menyimpan status '
                'Purchase Order ke Firestore.',
              );
            },
          );

      _log(
        'updatePurchaseOrder() BERHASIL.',
      );

      if (!mounted) {
        _log(
          'Widget sudah tidak mounted.',
        );
        return;
      }

      _log(
        '=== RECEIVE GOODS BERHASIL ===',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedStatus == 'received'
                ? 'Penerimaan berhasil. '
                    'Semua barang sudah diterima.'
                : 'Penerimaan berhasil disimpan. '
                    'Status Purchase Order: Partial.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      _log(
        '!!! ERROR RECEIVE GOODS !!!',
      );
      _log(
        'Error: $error',
      );
      _log(
        'StackTrace: $stackTrace',
      );

      debugPrintStack(
        label: '[RECEIVE] STACK TRACE',
        stackTrace: stackTrace,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 8),
          content: Text(
            'Gagal memproses penerimaan: $error',
          ),
        ),
      );
    }
  }

  Widget _buildItemCard(
    PurchaseOrderItem item,
  ) {
    final controller = _controllerFor(item);
    final remaining = item.remainingQuantity;
    final isCompleted = remaining <= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Product ID: ${item.productId}',
                      ),
                      if (item.sku != null &&
                          item.sku!.trim().isNotEmpty)
                        Text(
                          'SKU: ${item.sku}',
                        ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Chip(
                    label: Text('Selesai'),
                  ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jumlah Order'),
                Text(
                  _formatNumber(item.quantity),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sudah Diterima'),
                Text(
                  _formatNumber(
                    item.receivedQuantity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sisa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatNumber(remaining),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText:
                      'Jumlah Diterima Sekarang',
                  border: OutlineInputBorder(),
                  helperText:
                      'Tidak boleh melebihi jumlah sisa.',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final quantity =
                      _parseDouble(value ?? '');

                  if (quantity < 0) {
                    return 'Jumlah tidak boleh negatif';
                  }

                  if (quantity > remaining) {
                    return 'Maksimal '
                        '${_formatNumber(remaining)}';
                  }

                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nilai Item'),
                Text(
                  _formatRupiah(item.subtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
    PurchaseOrderDetailState detail,
  ) {
    final totalOrder = detail.totalQuantity;
    final totalReceived =
        detail.totalReceivedQuantity;
    final totalRemaining =
        detail.totalRemainingQuantity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Penerimaan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Order'),
                Text(
                  _formatNumber(totalOrder),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Sudah Diterima',
                ),
                Text(
                  _formatNumber(totalReceived),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Sisa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatNumber(totalRemaining),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      purchaseOrderDetailControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receive Goods',
        ),
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) =>
            Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gagal memuat Purchase Order',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref
                        .read(
                          purchaseOrderDetailControllerProvider
                              .notifier,
                        )
                        .load(
                          widget.purchaseOrder.id,
                        );
                  },
                  child: const Text(
                    'Coba Lagi',
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (detail) {
          final hasRemaining =
              _hasRemainingQuantity(
            detail.items,
          );

          return Form(
            key: _formKey,
            child: RefreshIndicator(
              onRefresh: () {
                return ref
                    .read(
                      purchaseOrderDetailControllerProvider
                          .notifier,
                    )
                    .refresh();
              },
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.receipt_long,
                        ),
                      ),
                      title: Text(
                        detail.purchaseOrder.number,
                      ),
                      subtitle: Text(
                        detail.purchaseOrder.supplierName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummary(detail),
                  const SizedBox(height: 20),
                  const Text(
                    'Daftar Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (detail.items.isEmpty)
                    const Card(
                      child: Padding(
                        padding:
                            EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'Belum ada item Purchase Order.',
                          ),
                        ),
                      ),
                    )
                  else
                    ...detail.items.map(
                      _buildItemCard,
                    ),
                  const SizedBox(height: 24),
                  if (hasRemaining)
                    FilledButton.icon(
                      onPressed: () {
                        _processReceive(detail);
                      },
                      icon: const Icon(
                        Icons.inventory_2,
                      ),
                      label: const Text(
                        'Proses Penerimaan',
                      ),
                    )
                  else
                    const Card(
                      child: Padding(
                        padding:
                            EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Semua barang dalam Purchase Order '
                                'sudah diterima.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}