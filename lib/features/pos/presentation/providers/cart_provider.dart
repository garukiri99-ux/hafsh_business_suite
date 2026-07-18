import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';

final cartProvider =
    NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product) {
    final index =
        state.indexWhere((e) => e.product.id == product.id);

    if (index == -1) {
      state = [
        ...state,
        CartItem(
          product: product,
          quantity: 1,
        ),
      ];
      return;
    }

    final items = [...state];

    items[index] = items[index].copyWith(
      quantity: items[index].quantity + 1,
    );

    state = items;
  }

  void increase(Product product) => add(product);

  void decrease(Product product) {
    final index =
        state.indexWhere((e) => e.product.id == product.id);

    if (index == -1) return;

    final items = [...state];

    if (items[index].quantity == 1) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity - 1,
      );
    }

    state = items;
  }

  void clear() {
    state = [];
  }
}