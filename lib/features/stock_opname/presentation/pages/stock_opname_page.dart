import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/stock_opname_provider.dart';
import 'stock_opname_form_page.dart';

class StockOpnamePage extends ConsumerWidget {
  const StockOpnamePage({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final items = ref.watch(
      stockOpnameControllerProvider,
    );

    Future<void> openOpnameForm() async {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const StockOpnameFormPage(),
        ),
      );

      if (result == true) {
        ref.invalidate(
          stockOpnameControllerProvider,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Opname'),
      ),
      body: items.when(
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
                  'Gagal memuat Stock Opname',
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
        data: (opnames) {
          if (opnames.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada data Stock Opname.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hasil penghitungan stok fisik '
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
                stockOpnameControllerProvider,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: opnames.length,
              separatorBuilder: (
                context,
                index,
              ) =>
                  const SizedBox(height: 12),
              itemBuilder: (
                context,
                index,
              ) {
                final item = opnames[index];

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
                                Icons.inventory_rounded,
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
                                    _formatDateTime(
                                      item.createdAt,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors
                                          .grey
                                          .shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildDifferenceChip(
                              item.difference,
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
                            const Text('Stok Sistem'),
                            Text(
                              _formatNumber(
                                item.stockSystem,
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
                            const Text('Stok Fisik'),
                            Text(
                              _formatNumber(
                                item.stockPhysical,
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
                            const Text('Selisih'),
                            Text(
                              _formatDifference(
                                item.difference,
                              ),
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (item.notes
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            item.notes,
                            style: TextStyle(
                              color:
                                  Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: openOpnameForm,
        icon: const Icon(
          Icons.fact_check,
        ),
        label: const Text(
          'Opname',
        ),
      ),
    );
  }

  Widget _buildDifferenceChip(
    double difference,
  ) {
    if (difference > 0) {
      return const Chip(
        label: Text('Lebih'),
      );
    }

    if (difference < 0) {
      return const Chip(
        label: Text('Kurang'),
      );
    }

    return const Chip(
      label: Text('Sesuai'),
    );
  }

  String _formatDifference(
    double value,
  ) {
    if (value == 0) {
      return '0';
    }

    final prefix = value > 0 ? '+' : '';

    return '$prefix${_formatNumber(value)}';
  }

  String _formatNumber(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
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