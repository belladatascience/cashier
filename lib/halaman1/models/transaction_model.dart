class TransactionItemModel {
  final int? id;
  final int? transactionId;
  final String invoiceNumber;
  final String menuName;
  final int qty;
  final int price;
  final int subtotal;

  TransactionItemModel({
    this.id,
    this.transactionId,
    required this.invoiceNumber,
    required this.menuName,
    required this.qty,
    required this.price,
    int? subtotal,
  }) : subtotal = subtotal ?? (qty * price);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'invoice_number': invoiceNumber,
      'menu_name': menuName,
      'qty': qty,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory TransactionItemModel.fromMap(Map<String, dynamic> map) {
    return TransactionItemModel(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      menuName: map['menu_name'] as String,
      qty: (map['qty'] as num).toInt(),
      price: (map['price'] as num).toInt(),
      subtotal: (map['subtotal'] as num).toInt(),
    );
  }

  Map<String, dynamic> toLegacyMap() {
    return {'name': menuName, 'qty': qty, 'price': price};
  }
}

class TransactionModel {
  final int? id;
  final String invoiceNumber;
  final String dateTime;
  final String cashierName;
  final String paymentMethod;
  final String customerName;
  final String tableNumber;
  final int subtotal;
  final int tax;
  final int total;
  final String status;
  final String storeName;
  final List<TransactionItemModel> items;

  TransactionModel({
    this.id,
    required this.invoiceNumber,
    required this.dateTime,
    required this.cashierName,
    required this.paymentMethod,
    required this.customerName,
    this.tableNumber = '-',
    required this.subtotal,
    required this.tax,
    required this.total,
    this.status = 'LUNAS',
    this.storeName = 'Bella Cafe',
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'date_time': dateTime,
      'cashier_name': cashierName,
      'payment_method': paymentMethod,
      'customer_name': customerName,
      'table_number': tableNumber,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'store_name': storeName,
    };
  }

  factory TransactionModel.fromMap(
    Map<String, dynamic> map, [
    List<TransactionItemModel> items = const [],
  ]) {
    return TransactionModel(
      id: map['id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      dateTime: map['date_time'] as String,
      cashierName: map['cashier_name'] as String,
      paymentMethod: map['payment_method'] as String,
      customerName: map['customer_name'] as String,
      tableNumber: map['table_number'] as String? ?? '-',
      subtotal: (map['subtotal'] as num).toInt(),
      tax: (map['tax'] as num).toInt(),
      total: (map['total'] as num).toInt(),
      status: map['status'] as String? ?? 'LUNAS',
      storeName: map['store_name'] as String? ?? 'Bella Cafe',
      items: items,
    );
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      'id': invoiceNumber,
      'date': dateTime,
      'cashier': cashierName,
      'method': paymentMethod,
      'customer': customerName,
      'items': items.map((e) => e.toLegacyMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'storeName': storeName,
    };
  }
}
