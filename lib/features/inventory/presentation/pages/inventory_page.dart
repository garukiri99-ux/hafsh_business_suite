import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/inventory_menu_card.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'MASTER DATA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          InventoryMenuCard(
            icon: Icons.inventory_2_rounded,
            title: 'Products',
            subtitle: 'Kelola data produk',
            color: Colors.orange,
            onTap: () {
              context.push('/products');
            },
          ),

          InventoryMenuCard(
            icon: Icons.category_rounded,
            title: 'Categories',
            subtitle: 'Kelola kategori produk',
            color: Colors.blue,
            onTap: () {
              context.push('/categories');
            },
          ),

          InventoryMenuCard(
            icon: Icons.local_shipping_rounded,
            title: 'Suppliers',
            subtitle: 'Kelola data supplier',
            color: Colors.green,
            onTap: () {
              context.push('/suppliers');
            },
          ),

          const SizedBox(height: 24),

          const Text(
            'STOCK',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

          InventoryMenuCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Stock Adjustment',
            subtitle: 'Penyesuaian stok barang',
            color: Colors.deepOrange,
            onTap: () {
              context.push('/stock-adjustments');
            },
          ),

          InventoryMenuCard(
            icon: Icons.fact_check_rounded,
            title: 'Stock Opname',
            subtitle: 'Segera hadir',
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock Opname - Coming Soon'),
                ),
              );
            },
          ),

          InventoryMenuCard(
            icon: Icons.history_rounded,
            title: 'Stock Movement',
            subtitle: 'Segera hadir',
            color: Colors.teal,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock Movement - Coming Soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}