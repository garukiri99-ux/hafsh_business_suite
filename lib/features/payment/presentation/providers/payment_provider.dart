import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payment_method.dart';

final paymentMethodProvider =
    NotifierProvider<PaymentMethodNotifier, PaymentMethod>(
  PaymentMethodNotifier.new,
);

class PaymentMethodNotifier extends Notifier<PaymentMethod> {
  @override
  PaymentMethod build() {
    return PaymentMethod.cash;
  }

  void setMethod(PaymentMethod method) {
    state = method;
  }
}

final paidAmountProvider =
    NotifierProvider<PaidAmountNotifier, int>(
  PaidAmountNotifier.new,
);

class PaidAmountNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setAmount(int amount) {
    state = amount;
  }

  void clear() {
    state = 0;
  }
}