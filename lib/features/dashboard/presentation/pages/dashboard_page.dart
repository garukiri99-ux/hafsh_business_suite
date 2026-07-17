import 'package:flutter/material.dart';

import '../widgets/business_unit_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_stats.dart';
import '../widgets/section_title.dart';
import '../widgets/management_menu.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xffF5F7FA),
  body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DashboardHeader(
              userName: "Administrator",
            ),

            const QuickStats(),

            const SectionTitle(
              title: "Business Unit",
            ),

            BusinessUnitCard(
              icon: Icons.coffee,
              color: Colors.brown,
              title: "Hafsh Coffee",
              subtitle: "Kasir • Produk • Penjualan",
              onTap: () {},
            ),

            BusinessUnitCard(
              icon: Icons.shopping_cart,
              color: Colors.green,
              title: "Hafsh Mart",
              subtitle: "Gudang • Kasir • Stok",
              onTap: () {},
            ),

            BusinessUnitCard(
              icon: Icons.checkroom,
              color: Colors.purple,
              title: "Mutia Gallery",
              subtitle: "Produk • Penjualan • Pelanggan",
              onTap: () {},
            ),

            const SizedBox(height: 16),

            const SectionTitle(
              title: "Management",
            ),
            const ManagementMenu(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}