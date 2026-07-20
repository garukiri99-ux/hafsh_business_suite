enum StockAdjustmentType {
  stockIn,
  stockOut,
}

extension StockAdjustmentTypeX on StockAdjustmentType {
  String get value {
    switch (this) {
      case StockAdjustmentType.stockIn:
        return 'in';

      case StockAdjustmentType.stockOut:
        return 'out';
    }
  }

  static StockAdjustmentType fromString(
    String value,
  ) {
    switch (value) {
      case 'out':
        return StockAdjustmentType.stockOut;

      case 'in':
      default:
        return StockAdjustmentType.stockIn;
    }
  }
}