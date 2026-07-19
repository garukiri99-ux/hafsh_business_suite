class CheckoutSummary {
  final int totalItem;
  final int subtotal;
  final int discount;
  final int tax;
  final int total;

  const CheckoutSummary({
    required this.totalItem,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });
}