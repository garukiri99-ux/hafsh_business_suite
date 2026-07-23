import 'package:flutter/material.dart';

class SupplierSearch extends StatelessWidget {
  const SupplierSearch({
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
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        12,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari supplier...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: keyword.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}