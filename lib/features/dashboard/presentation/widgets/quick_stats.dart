import 'package:flutter/material.dart';

import 'stat_card.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,

        shrinkWrap: true,

        physics: const NeverScrollableScrollPhysics(),

        crossAxisSpacing: 16,

        mainAxisSpacing: 16,

        childAspectRatio: 0.95,

        children: const [

          StatCard(
            icon: Icons.payments_rounded,
            title: "Penjualan",
            value: "Rp0",
            color: Colors.green,
          ),

          StatCard(
            icon: Icons.receipt_long_rounded,
            title: "Transaksi",
            value: "0",
            color: Colors.blue,
          ),

          StatCard(
            icon: Icons.inventory_2_rounded,
            title: "Produk",
            value: "0",
            color: Colors.orange,
          ),

          StatCard(
            icon: Icons.warning_amber_rounded,
            title: "Stok Menipis",
            value: "0",
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}