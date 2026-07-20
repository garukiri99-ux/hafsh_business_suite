import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../pages/category_form_page.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            category.isActive
                ? Icons.category
                : Icons.block,
          ),
        ),
        title: Text(category.name),
        subtitle: Text(
          category.description?.isNotEmpty == true
              ? category.description!
              : '-',
        ),
        trailing: Icon(
          category.isActive
              ? Icons.check_circle
              : Icons.cancel,
          color: category.isActive
              ? Colors.green
              : Colors.red,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryFormPage(
                category: category,
              ),
            ),
          );
        },
      ),
    );
  }
}