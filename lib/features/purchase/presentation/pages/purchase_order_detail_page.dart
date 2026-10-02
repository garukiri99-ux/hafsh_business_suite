import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/purchase_order_item.dart';
import '../providers/purchase_order_detail_controller.dart';
import 'purchase_order_item_form_page.dart';
import 'purchase_order_receive_page.dart';

class PurchaseOrderDetailPage
    extends ConsumerStatefulWidget {
  const PurchaseOrderDetailPage({
    super.key,
    required this.purchaseOrder,
  });

  final PurchaseOrder purchaseOrder;

  @override
  ConsumerState<PurchaseOrderDetailPage> createState() =>
      _PurchaseOrderDetailPageState();
}

class _PurchaseOrderDetailPageState
    extends ConsumerState<PurchaseOrderDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      ref
          .read(
            purchaseOrderDetailControllerProvider
                .notifier,
          )
          .load(widget.purchaseOrder.id);
    });
  }

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');
    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0)}';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'ordered':
        return 'Ordered';
      case 'partial':
        return 'Partial';
      case 'received':
        return 'Received';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Future<void> _refresh() async {
    await ref
        .read(
          purchaseOrderDetailControllerProvider
              .notifier,
        )
        .refresh();
  }

  Future<void> _syncTotals() async {
    final detailState = ref
        .read(purchaseOrderDetailControllerProvider)
        .asData
        ?.value;

    if (detailState == null) {
      return;
    }

    final subtotal = detailState.itemSubtotal;
    final order = detailState.purchaseOrder;

    final total =
        subtotal -
        order.discount +
        order.tax;

    if (subtotal == order.subtotal &&
        total == order.total) {
      return;
    }

    final updatedOrder = order.copyWith(
      subtotal: subtotal,
      total: total,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(
          purchaseOrderDetailControllerProvider
              .notifier,
        )
        .updatePurchaseOrder(updatedOrder);
  }

  Future<void> _addItem() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return PurchaseOrderItemFormPage(
            purchaseOrderId:
                widget.purchaseOrder.id,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    await _refresh();
    await _syncTotals();
  }

  Future<void> _editItem(
    PurchaseOrderItem item,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return PurchaseOrderItemFormPage(
            purchaseOrderId:
                widget.purchaseOrder.id,
            item: item,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    await _refresh();
    await _syncTotals();
  }

  Future<void> _deleteItem(
    PurchaseOrderItem item,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Item?'),
          content: Text(
            'Item "${item.productName}" akan '
            'dihapus dari Purchase Order.',
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
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(
            purchaseOrderDetailControllerProvider
                .notifier,
          )
          .deleteItem(item.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item berhasil dihapus.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus item: $error',
          ),
        ),
      );
    }
  }

  Future<void> _openReceiveGoods(
    PurchaseOrder order,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (context) {
          return PurchaseOrderReceivePage(
            purchaseOrder: order,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    await _refresh();
  }

  Widget _buildOrderInformation(
    PurchaseOrder order,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.receipt_long,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    order.number,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _statusLabel(order.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(
              'Supplier',
              order.supplierName,
            ),
            const SizedBox(height: 8),
            _infoRow(
              'Tanggal Order',
              _formatDate(order.orderDate),
            ),
            const SizedBox(height: 8),
            _infoRow(
              'Tanggal Estimasi',
              order.expectedDate == null
                  ? 'Belum ditentukan'
                  : _formatDate(
                      order.expectedDate!,
                    ),
            ),
            const Divider(height: 24),
            _infoRow(
              'Subtotal',
              _formatRupiah(order.subtotal),
            ),
            const SizedBox(height: 8),
            _infoRow(
              'Diskon',
              _formatRupiah(order.discount),
            ),
            const SizedBox(height: 8),
            _infoRow(
              'Pajak',
              _formatRupiah(order.tax),
            ),
            const Divider(height: 24),
            _infoRow(
              'Total',
              _formatRupiah(order.total),
              bold: true,
            ),
            if (order.notes != null &&
                order.notes!.trim().isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Catatan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(order.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    final style = bold
        ? const TextStyle(
            fontWeight: FontWeight.bold,
          )
        : null;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: style,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiveButton(
    PurchaseOrder order,
    List<PurchaseOrderItem> items,
  ) {
    final totalRemaining =
        items.fold<double>(
      0,
      (sum, item) =>
          sum + item.remainingQuantity,
    );

    final canReceive =
        order.status != 'received' &&
        order.status != 'cancelled' &&
        totalRemaining > 0;

    if (!canReceive) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          _openReceiveGoods(order);
        },
        icon: const Icon(
          Icons.inventory_2_outlined,
        ),
        label: const Text(
          'Terima Barang',
        ),
      ),
    );
  }

  Widget _buildItemCard(
    PurchaseOrderItem item,
  ) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.all(12),
        leading: CircleAvatar(
          child: Text(
            item.quantity.toStringAsFixed(0),
          ),
        ),
        title: Text(
          item.productName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 6,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Product ID: ${item.productId}',
              ),
              if (item.sku != null &&
                  item.sku!.trim().isNotEmpty)
                Text(
                  'SKU: ${item.sku}',
                ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity.toStringAsFixed(2)} × '
                '${_formatRupiah(item.unitCost)}',
              ),
              Text(
                'Diterima: '
                '${item.receivedQuantity.toStringAsFixed(2)}',
              ),
              Text(
                'Sisa: '
                '${item.remainingQuantity.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 4),
              Text(
                'Subtotal: '
                '${_formatRupiah(item.subtotal)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editItem(item);
            } else if (value == 'delete') {
              _deleteItem(item);
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Hapus'),
              ),
            ];
          },
        ),
      ),
    );
  }

  Widget _buildItemsSection(
    List<PurchaseOrderItem> items,
  ) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 56,
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum ada item',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tambahkan produk ke '
                'Purchase Order ini.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Tambah Item',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itemTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Item Purchase Order',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${items.length} item',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(_buildItemCard),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Item',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatRupiah(itemTotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      purchaseOrderDetailControllerProvider,
    );

    final order =
        detailAsync.asData?.value.purchaseOrder ??
        widget.purchaseOrder;

    return Scaffold(
      appBar: AppBar(
        title: Text(order.number),
        actions: [
          if (order.status != 'received' &&
              order.status != 'cancelled')
            IconButton(
              onPressed: () {
                _openReceiveGoods(order);
              },
              tooltip: 'Terima Barang',
              icon: const Icon(
                Icons.inventory_2_outlined,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildOrderInformation(order),
            const SizedBox(height: 16),
            detailAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) =>
                  Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal memuat item',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign:
                            TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _refresh,
                        child: const Text(
                          'Coba Lagi',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (detail) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    _buildReceiveButton(
                      detail.purchaseOrder,
                      detail.items,
                    ),
                    if (detail.items.isNotEmpty)
                      const SizedBox(height: 20),
                    _buildItemsSection(
                      detail.items,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Item'),
      ),
    );
  }
}