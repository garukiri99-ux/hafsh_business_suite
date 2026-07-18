import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../checkout/presentation/providers/checkout_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/change_summary.dart';
import '../widgets/pay_button.dart';
import '../widgets/payment_amount_field.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_summary.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(checkoutProvider);

    final paymentMethod = ref.watch(paymentMethodProvider);

    final paidAmount = ref.watch(paidAmountProvider);

    final change = paidAmount - summary.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            PaymentSummary(
              total: summary.total,
            ),

            PaymentMethodSelector(
              value: paymentMethod,
              onChanged: (method) {
                ref
                    .read(paymentMethodProvider.notifier)
                    .setMethod(method);
              },
            ),

            PaymentAmountField(
              controller: controller,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: () {
                  final amount =
                      int.tryParse(controller.text) ?? 0;

                  ref
                      .read(paidAmountProvider.notifier)
                      .setAmount(amount);
                },
                child: const Text("Hitung"),
              ),
            ),

            const SizedBox(height: 16),

            ChangeSummary(
              change: change < 0 ? 0 : change,
            ),

            const Spacer(),

            PayButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Sprint berikutnya: Simpan Transaksi",
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}