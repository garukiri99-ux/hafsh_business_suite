import 'package:flutter/material.dart';

class ManagementMenu extends StatelessWidget {
  const ManagementMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      (
        Icons.inventory_2_rounded,
        "Inventory",
        Colors.orange,
      ),
      (
        Icons.account_balance_wallet_rounded,
        "Finance",
        Colors.green,
      ),
      (
        Icons.bar_chart_rounded,
        "Reports",
        Colors.blue,
      ),
      (
        Icons.people_alt_rounded,
        "Users",
        Colors.purple,
      ),
      (
        Icons.settings_rounded,
        "Settings",
        Colors.grey,
      ),
      (
        Icons.admin_panel_settings_rounded,
        "Roles",
        Colors.red,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menus.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (context, index) {
          final menu = menus[index];

          return Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          menu.$3.withValues(alpha: .15),
                      child: Icon(
                        menu.$1,
                        color: menu.$3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        menu.$2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}