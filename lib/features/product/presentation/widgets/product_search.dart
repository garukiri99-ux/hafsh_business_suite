import 'package:flutter/material.dart';

class ProductSearch extends StatelessWidget {
  const ProductSearch({
    super.key,
    required this.controller,
    required this.keyword,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String keyword;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Cari nama, SKU, atau barcode...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: keyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                ),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}