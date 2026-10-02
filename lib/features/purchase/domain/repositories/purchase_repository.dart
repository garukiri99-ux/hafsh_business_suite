import '../entities/purchase_order.dart';
import '../entities/purchase_order_item.dart';

abstract class PurchaseRepository {
  Future<List<PurchaseOrder>> getPurchaseOrders();

  Stream<List<PurchaseOrder>> watchPurchaseOrders();

  Future<PurchaseOrder?> getPurchaseOrderById(
    String id,
  );

  Future<List<PurchaseOrderItem>> getPurchaseOrderItems(
    String purchaseOrderId,
  );

  Future<void> addPurchaseOrder(
    PurchaseOrder purchaseOrder,
  );

  Future<void> updatePurchaseOrder(
    PurchaseOrder purchaseOrder,
  );

  Future<void> deletePurchaseOrder(
    String id,
  );

  Future<void> addPurchaseOrderItem(
    PurchaseOrderItem item,
  );

  Future<void> updatePurchaseOrderItem(
    PurchaseOrderItem item,
  );

  Future<void> deletePurchaseOrderItem(
    String id,
  );
}