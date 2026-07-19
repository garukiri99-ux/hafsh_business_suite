import 'package:flutter/material.dart';

class PayButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const PayButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: loading ? null : onPressed,
          icon: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.payments),
          label: Text(
            loading ? "MEMPROSES..." : "BAYAR SEKARANG",
          ),
        ),
      ),
    );
  }
}