import 'package:flutter/material.dart';

import '../../domain/entities/supplier.dart';
import '../pages/supplier_form_page.dart';

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
  });

  final Supplier supplier;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: const Icon(Icons.local_shipping),
        ),
        title: Text(supplier.name),
        subtitle: Text(
          supplier.contactPerson ?? '-',
        ),
        trailing: Icon(
          supplier.isActive
              ? Icons.check_circle
              : Icons.cancel,
          color: supplier.isActive
              ? Colors.green
              : Colors.red,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SupplierFormPage(
                supplier: supplier,
              ),
            ),
          );
        },
      ),
    );
  }
}