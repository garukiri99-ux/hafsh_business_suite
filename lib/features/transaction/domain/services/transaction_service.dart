import '../entities/invoice.dart';

class TransactionService {
  Invoice generateInvoice() {
    return Invoice.generate();
  }
}