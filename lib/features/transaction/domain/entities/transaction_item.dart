class TransactionItem {
  final String productId;
  final String productName;
  final int price;
  final int quantity;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  int get subtotal => price * quantity;
}