import 'package:flutter/material.dart';

import '../pages/stock_adjustment_form_page.dart';
import '../pages/stock_adjustment_page.dart';

class StockAdjustmentRoutes {
  static const String list = '/stock-adjustments';
  static const String create = '/stock-adjustments/create';

  static Map<String, WidgetBuilder> get routes => {
        list: (_) => const StockAdjustmentPage(),
        create: (_) => const StockAdjustmentFormPage(),
      };
}