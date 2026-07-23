import 'package:flutter/material.dart';

import '../../domain/entities/supplier.dart';

class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Supplier supplier;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                child: Icon(
                  Icons.local_shipping,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      supplier.contactPerson?.isNotEmpty == true
                          ? supplier.contactPerson!
                          : 'Tidak ada kontak',
                      style: theme.textTheme.bodyMedium,
                    ),

                    if (supplier.phone?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        supplier.phone!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],

                    if (supplier.email?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        supplier.email!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Chip(
                          avatar: Icon(
                            supplier.isActive
                                ? Icons.check_circle
                                : Icons.block,
                            size: 18,
                          ),
                          label: Text(
                            supplier.isActive
                                ? 'Aktif'
                                : 'Nonaktif',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;

                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}