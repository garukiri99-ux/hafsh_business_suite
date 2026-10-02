import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/purchase_order.dart';
import '../providers/purchase_order_controller.dart';
import 'purchase_order_detail_page.dart';
import 'purchase_order_form_page.dart';

class PurchaseOrderPage extends ConsumerWidget {
  const PurchaseOrderPage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final purchaseOrders =
        ref.watch(purchaseOrderControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Order'),
      ),
      body: purchaseOrders.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
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
                          purchaseOrderControllerProvider
                              .notifier,
                        )
                        .refresh();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () {
                return ref
                    .read(
                      purchaseOrderControllerProvider
                          .notifier,
                    )
                    .refresh();
              },
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 160),
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Belum ada Purchase Order',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tambahkan Purchase Order pertama.',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        _openCreateForm(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Purchase Order Baru',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return ref
                  .read(
                    purchaseOrderControllerProvider
                        .notifier,
                  )
                  .refresh();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (
                context,
                index,
              ) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];

                return _PurchaseOrderCard(
                  purchaseOrder: order,
                  onTap: () {
                    _openDetail(
                      context,
                      order,
                    );
                  },
                  onEdit: () {
                    _openEditForm(
                      context,
                      order,
                    );
                  },
                  onDelete: () {
                    _confirmDelete(
                      context,
                      ref,
                      order,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openCreateForm(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Purchase Order'),
      ),
    );
  }

  void _openCreateForm(
    BuildContext context,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PurchaseOrderFormPage(),
      ),
    );
  }

  void _openEditForm(
    BuildContext context,
    PurchaseOrder order,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PurchaseOrderFormPage(
          purchaseOrder: order,
        ),
      ),
    );
  }

  void _openDetail(
    BuildContext context,
    PurchaseOrder order,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PurchaseOrderDetailPage(
          purchaseOrder: order,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PurchaseOrder order,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Hapus Purchase Order?',
          ),
          content: Text(
            'Purchase Order ${order.number} '
            'beserta item-itemnya akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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
            purchaseOrderControllerProvider.notifier,
          )
          .deletePurchaseOrder(order.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purchase Order ${order.number} berhasil dihapus.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus Purchase Order: $error',
          ),
        ),
      );
    }
  }
}

class _PurchaseOrderCard extends StatelessWidget {
  const _PurchaseOrderCard({
    required this.purchaseOrder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final PurchaseOrder purchaseOrder;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchaseOrder.number,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          purchaseOrder.supplierName,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'detail':
                          onTap();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem(
                          value: 'detail',
                          child: ListTile(
                            leading: Icon(
                              Icons.visibility_outlined,
                            ),
                            title: Text('Detail'),
                            contentPadding:
                                EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(
                              Icons.edit_outlined,
                            ),
                            title: Text('Edit'),
                            contentPadding:
                                EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                            ),
                            title: Text('Hapus'),
                            contentPadding:
                                EdgeInsets.zero,
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(
                      purchaseOrder.orderDate,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(
                    status: purchaseOrder.status,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rp ${purchaseOrder.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
                  label: const Text('Lihat Detail'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        _statusLabel(status),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  String _statusLabel(String value) {
    switch (value) {
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
        return value;
    }
  }
}