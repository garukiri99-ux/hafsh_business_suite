import 'package:flutter/material.dart';

class ProductFilterChip extends StatelessWidget {
  const ProductFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 18,
            )
          : null,
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: onSelected,
      selectedColor: Theme.of(
        context,
      ).colorScheme.primaryContainer,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface,
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      labelStyle: TextStyle(
        fontWeight:
            selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}