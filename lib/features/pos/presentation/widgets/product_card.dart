import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCoffee =
        product.category.toLowerCase() == "coffee";

    return Card(
      elevation: 2,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isCoffee
                    ? Colors.brown.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isCoffee
                    ? Icons.coffee
                    : Icons.local_cafe,
                color:
                    isCoffee ? Colors.brown : Colors.green,
                size: 34,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Rp ${product.price}",
                    style: const TextStyle(
                      color: Color(0xff0F766E),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text("Tambah"),
            ),
          ],
        ),
      ),
    );
  }
}