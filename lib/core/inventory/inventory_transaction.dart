abstract interface class InventoryTransaction {
  Future<void> adjustStock({
    required String productId,
    required double quantity,
    required bool isStockIn,
    required String reason,
    String? notes,
    String? createdBy,
  });
}