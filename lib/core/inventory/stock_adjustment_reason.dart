enum StockAdjustmentReason {
  manual,
  purchase,
  sale,
  damaged,
  expired,
  lost,
  stockOpname,
}

extension StockAdjustmentReasonX
    on StockAdjustmentReason {
  String get value {
    switch (this) {
      case StockAdjustmentReason.manual:
        return 'manual';

      case StockAdjustmentReason.purchase:
        return 'purchase';

      case StockAdjustmentReason.sale:
        return 'sale';

      case StockAdjustmentReason.damaged:
        return 'damaged';

      case StockAdjustmentReason.expired:
        return 'expired';

      case StockAdjustmentReason.lost:
        return 'lost';

      case StockAdjustmentReason.stockOpname:
        return 'stock_opname';
    }
  }

  static StockAdjustmentReason fromString(
    String value,
  ) {
    switch (value) {
      case 'purchase':
        return StockAdjustmentReason.purchase;

      case 'sale':
        return StockAdjustmentReason.sale;

      case 'damaged':
        return StockAdjustmentReason.damaged;

      case 'expired':
        return StockAdjustmentReason.expired;

      case 'lost':
        return StockAdjustmentReason.lost;

      case 'stock_opname':
        return StockAdjustmentReason.stockOpname;

      case 'manual':
      default:
        return StockAdjustmentReason.manual;
    }
  }
}