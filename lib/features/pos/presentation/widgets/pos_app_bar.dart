import 'package:flutter/material.dart';

import 'cart_badge.dart';

class PosAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PosAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: Colors.black87,
      titleSpacing: 16,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "☕ Hafsh Coffee",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Point of Sale",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Center(
            child: CartBadge(),
          ),
        ),
      ],
    );
  }
}