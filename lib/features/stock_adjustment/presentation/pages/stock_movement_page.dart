import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stock_adjustment_provider.dart';

class StockMovementPage extends ConsumerWidget {
  const StockMovementPage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final movements = ref.watch(
      stockAdjustmentControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Movement'),
      ),
      body: movements.when(
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
                  'Gagal memuat Stock Movement',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_vert_rounded,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada pergerakan stok.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Pergerakan stok dari pembelian, '
                      'adjustment, dan transaksi lainnya '
                      'akan muncul di sini.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                stockAdjustmentControllerProvider,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (
                context,
                index,
              ) =>
                  const SizedBox(height: 12),
              itemBuilder: (
                context,
                index,
              ) {
                final item = items[index];

                final isStockIn = item.isStockIn;

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
                            CircleAvatar(
                              child: Icon(
                                isStockIn
                                    ? Icons
                                        .south_west_rounded
                                    : Icons
                                        .north_east_rounded,
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
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatReference(
                                      item.referenceType,
                                    ),
                                    style:
                                        TextStyle(
                                      color:
                                          Colors.grey
                                              .shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                isStockIn
                                    ? 'STOCK IN'
                                    : 'STOCK OUT',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text('Quantity'),
                            Text(
                              _formatNumber(
                                item.quantity,
                              ),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text('Stock Before'),
                            Text(
                              _formatNumber(
                                item.stockBefore,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text('Stock After'),
                            Text(
                              _formatNumber(
                                item.stockAfter,
                              ),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text('Reason'),
                            Text(
                              _formatReason(
                                item.reason.name,
                              ),
                            ),
                          ],
                        ),
                        if (item.notes
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            item.notes,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _formatDateTime(
                            item.createdAt,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatReference(
    String? referenceType,
  ) {
    switch (referenceType) {
      case 'purchase_order':
        return 'Purchase Order';

      case 'manual_adjustment':
        return 'Manual Adjustment';

      case 'sale':
        return 'Penjualan';

      case 'stock_opname':
        return 'Stock Opname';

      default:
        if (referenceType == null ||
            referenceType.trim().isEmpty) {
          return 'Tanpa referensi';
        }

        return referenceType.replaceAll(
          '_',
          ' ',
        );
    }
  }

  String _formatReason(String value) {
    switch (value) {
      case 'purchase':
        return 'Pembelian';

      case 'sale':
        return 'Penjualan';

      case 'damaged':
        return 'Rusak';

      case 'expired':
        return 'Kadaluarsa';

      case 'lost':
        return 'Hilang';

      case 'stockOpname':
      case 'stock_opname':
        return 'Stock Opname';

      case 'manual':
      default:
        return 'Manual';
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _formatDateTime(DateTime dateTime) {
    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(dateTime.day)}/'
        '${twoDigits(dateTime.month)}/'
        '${dateTime.year} '
        '${twoDigits(dateTime.hour)}:'
        '${twoDigits(dateTime.minute)}';
  }
}