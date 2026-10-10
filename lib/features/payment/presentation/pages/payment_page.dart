import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../checkout/presentation/providers/checkout_provider.dart';
import '../../../pos/presentation/providers/cart_provider.dart';

import '../../../transaction/providers/transaction_repository_provider.dart';
import '../../../transaction/providers/transaction_service_provider.dart';
import '../../../transaction/presentation/providers/transaction_controller.dart';
import '../../../transaction/presentation/providers/transaction_history_controller.dart';

import '../providers/payment_provider.dart';
import '../widgets/change_summary.dart';
import '../widgets/pay_button.dart';
import '../widgets/payment_amount_field.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_summary.dart';
import '../../../payment/domain/entities/payment_method.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      final text = controller.text.replaceAll('.', '');
      final amount = int.tryParse(text) ?? 0;

      ref.read(paidAmountProvider.notifier).setAmount(amount);
    });
  }

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

    final transactionStatus =
        ref.watch(transactionControllerProvider);

    final change = paidAmount - summary.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              PaymentSummary(
                total: summary.total,
              ),
              const SizedBox(height: 16),
              PaymentMethodSelector(
                value: paymentMethod,
                onChanged: (method) {
                  ref
                      .read(paymentMethodProvider.notifier)
                      .setMethod(method);
                },
              ),
              const SizedBox(height: 16),
              PaymentAmountField(
                controller: controller,
              ),
              const SizedBox(height: 16),
              ChangeSummary(
                change: change < 0 ? 0 : change,
              ),
              const SizedBox(height: 32),
              PayButton(
                loading:
                    transactionStatus == TransactionStatus.loading,
                onPressed: paidAmount >= summary.total
                    ? () async {
                        final cart = ref.read(cartProvider);

                        final transaction = ref
                            .read(transactionServiceProvider)
                            .buildTransaction(
                              cart: cart,
                              summary: summary,
                              paymentMethod: paymentMethod,
                              paidAmount: paidAmount,
                            );

                        final transactionController = ref.read(
                          transactionControllerProvider.notifier,
                        );

                        try {
                          await transactionController.execute(() async {
                            await ref
                                .read(transactionRepositoryProvider)
                                .save(transaction);
                          });

                          // Muat ulang riwayat setelah transaksi tersimpan.
                          ref.invalidate(
                            transactionHistoryControllerProvider,
                          );

                          ref.read(cartProvider.notifier).clear();
                          ref.read(paidAmountProvider.notifier).clear();

                          ref
                              .read(paymentMethodProvider.notifier)
                              .setMethod(PaymentMethod.cash);

                          if (!context.mounted) return;

                          await showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 48,
                              ),
                              title: const Text('Pembayaran Berhasil'),
                              content: Text(
                                'Invoice : ${transaction.invoice.number}\n\n'
                                'Transaksi berhasil disimpan.',
                              ),
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );

                          if (!context.mounted) return;

                          Navigator.pop(context);
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                'Gagal menyimpan transaksi.\n$e',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}