class Product {
  final String id;
  final String name;
  final String category;
  final int price;
  final String image;
  final bool active;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    this.active = true,
  });
}