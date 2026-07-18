import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryProvider =
    NotifierProvider<CategoryNotifier, String>(
  CategoryNotifier.new,
);

class CategoryNotifier extends Notifier<String> {
  @override
  String build() => "Semua";

  void setCategory(String value) {
    state = value;
  }

  void reset() {
    state = "Semua";
  }
}