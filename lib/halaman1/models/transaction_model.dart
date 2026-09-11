import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionItemModel {
  final int? id;
  final String? docId;
  final int? transactionId;
  final String invoiceNumber;
  final String menuName;
  final int qty;
  final int price;
  final int subtotal;

  TransactionItemModel({
    this.id,
    this.docId,
    this.transactionId,
    required this.invoiceNumber,
    required this.menuName,
    required this.qty,
    required this.price,
    int? subtotal,
  }) : subtotal = subtotal ?? (qty * price);

  /// Factory from Firebase Firestore DocumentSnapshot
  factory TransactionItemModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return TransactionItemModel(
        docId: snapshot.id,
        invoiceNumber: '',
        menuName: '',
        qty: 0,
        price: 0,
      );
    }
    return TransactionItemModel.fromMap(data, docId: snapshot.id);
  }

  /// Factory from Map with Firestore-safe parsing
  factory TransactionItemModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawId = map['id'];
    final rawTxId = map['transaction_id'] ?? map['transactionId'];
    final rawQty = map['qty'] ?? map['quantity'];
    final rawPrice = map['price'];
    final rawSubtotal = map['subtotal'];

    final qtyVal = rawQty is num
        ? rawQty.toInt()
        : (int.tryParse(rawQty?.toString() ?? '1') ?? 1);
    final priceVal = rawPrice is num
        ? rawPrice.toInt()
        : (int.tryParse(rawPrice?.toString() ?? '0') ?? 0);
    final subtotalVal = rawSubtotal is num
        ? rawSubtotal.toInt()
        : (int.tryParse(rawSubtotal?.toString() ?? '${qtyVal * priceVal}') ??
            (qtyVal * priceVal));

    return TransactionItemModel(
      id: rawId is num
          ? rawId.toInt()
          : (rawId != null ? int.tryParse(rawId.toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      transactionId: rawTxId is num
          ? rawTxId.toInt()
          : (rawTxId != null ? int.tryParse(rawTxId.toString()) : null),
      invoiceNumber: (map['invoice_number'] as String?) ??
          (map['invoiceNumber'] as String?) ??
          '',
      menuName: (map['menu_name'] as String?) ??
          (map['menuName'] as String?) ??
          (map['title'] as String?) ??
          (map['name'] as String?) ??
          'Menu Item',
      qty: qtyVal,
      price: priceVal,
      subtotal: subtotalVal,
    );
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      'transaction_id': transactionId,
      'invoice_number': invoiceNumber,
      'menu_name': menuName,
      'name': menuName,
      'title': menuName,
      'qty': qty,
      'quantity': qty,
      'price': price,
      'subtotal': subtotal,
    };
  }

  /// Convert to Firestore Map payload
  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'transaction_id': transactionId,
      'invoice_number': invoiceNumber,
      'menu_name': menuName,
      'name': menuName,
      'title': menuName,
      'qty': qty,
      'quantity': qty,
      'price': price,
      'subtotal': subtotal,
    };
  }

  Map<String, dynamic> toLegacyMap() {
    return {'name': menuName, 'title': menuName, 'qty': qty, 'quantity': qty, 'price': price, 'subtotal': subtotal};
  }

  TransactionItemModel copyWith({
    int? id,
    String? docId,
    int? transactionId,
    String? invoiceNumber,
    String? menuName,
    int? qty,
    int? price,
    int? subtotal,
  }) {
    return TransactionItemModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      transactionId: transactionId ?? this.transactionId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      menuName: menuName ?? this.menuName,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionItemModel.fromJson(String source) =>
      TransactionItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TransactionItemModel(id: $id, menuName: $menuName, qty: $qty, price: $price, subtotal: $subtotal)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionItemModel &&
        other.id == id &&
        other.docId == docId &&
        other.transactionId == transactionId &&
        other.invoiceNumber == invoiceNumber &&
        other.menuName == menuName &&
        other.qty == qty &&
        other.price == price &&
        other.subtotal == subtotal;
  }

  @override
  int get hashCode => Object.hash(
        id,
        docId,
        transactionId,
        invoiceNumber,
        menuName,
        qty,
        price,
        subtotal,
      );
}

class TransactionModel {
  final int? id;
  final String? docId;
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
    this.docId,
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

  /// Factory from Firebase Firestore DocumentSnapshot
  factory TransactionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data();
    if (data == null) {
      return TransactionModel(
        docId: snapshot.id,
        invoiceNumber: '',
        dateTime: '',
        cashierName: '',
        paymentMethod: '',
        customerName: '',
        subtotal: 0,
        tax: 0,
        total: 0,
      );
    }
    return TransactionModel.fromMap(data, null, snapshot.id);
  }

  /// Factory from generic DocumentSnapshot (dynamic)
  factory TransactionModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return TransactionModel(
        docId: doc.id,
        invoiceNumber: '',
        dateTime: '',
        cashierName: '',
        paymentMethod: '',
        customerName: '',
        subtotal: 0,
        tax: 0,
        total: 0,
      );
    }
    return TransactionModel.fromMap(data, null, doc.id);
  }

  /// Helper to convert month number to 3-letter abbreviation
  static String _monthShortName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (m >= 1 && m <= 12) return months[m - 1];
    return 'Jan';
  }

  /// Factory from Map with Firestore-safe parsing
  factory TransactionModel.fromMap(
    Map<String, dynamic> map, [
    List<TransactionItemModel>? items,
    String? docId,
  ]) {
    final rawId = map['id'];
    final rawSubtotal = map['subtotal'];
    final rawTax = map['tax'];
    final rawTotal = map['total'] ?? map['totalAmount'] ?? map['total_amount'];

    List<TransactionItemModel> parsedItems = items ?? [];
    if (parsedItems.isEmpty && map['items'] is List) {
      parsedItems = (map['items'] as List)
          .map((i) => TransactionItemModel.fromMap(
              Map<String, dynamic>.from(i as Map)))
          .toList();
    }

    // Parse Invoice Number
    String invNumber = (map['invoice_number'] as String?) ??
        (map['invoiceNumber'] as String?) ??
        (map['orderId'] as String?) ??
        (map['order_id'] as String?) ??
        '';
    if (invNumber.isEmpty && docId != null) {
      invNumber = docId.startsWith('tx_') ? '#INV-${docId.substring(3)}' : docId;
    }
    if (invNumber.isEmpty) {
      final now = DateTime.now();
      invNumber = '#INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(rawId ?? now.millisecondsSinceEpoch)}';
    }

    // Parse Date Time
    String dtStr = (map['date_time'] as String?) ??
        (map['dateTime'] as String?) ??
        (map['date'] as String?) ??
        '';
    if (dtStr.isEmpty) {
      final createdRaw = map['createdAt'] ?? map['timestamp'];
      if (createdRaw is Timestamp) {
        final d = createdRaw.toDate();
        dtStr = '${d.day} ${_monthShortName(d.month)} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      } else if (createdRaw is String && createdRaw.isNotEmpty) {
        final parsed = DateTime.tryParse(createdRaw);
        if (parsed != null) {
          dtStr = '${parsed.day} ${_monthShortName(parsed.month)} ${parsed.year}, ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
        } else {
          dtStr = createdRaw;
        }
      } else {
        final now = DateTime.now();
        dtStr = '${now.day} ${_monthShortName(now.month)} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      }
    }

    // Parse Payment Method
    String payMethod = (map['payment_method'] as String?) ??
        (map['paymentMethod'] as String?) ??
        (map['paymentChannel'] as String?) ??
        (map['method'] as String?) ??
        'Tunai (Cash)';
    if (payMethod.toLowerCase() == 'cash' || payMethod.toLowerCase() == 'tunai') {
      payMethod = 'Tunai di Kasir (Cash)';
    } else if (payMethod.toLowerCase() == 'wallet' || payMethod.toLowerCase() == 'qris' || payMethod.toLowerCase().contains('qris')) {
      payMethod = 'Digital Wallet (QRIS)';
    } else if (payMethod.toLowerCase() == 'gopay') {
      payMethod = 'Digital Wallet (GoPay)';
    }

    final custName = (map['customer_name'] as String?) ??
        (map['customerName'] as String?) ??
        (map['customer'] as String?) ??
        'Pelanggan Umum';

    final tableNum = (map['table_number'] as String?) ??
        (map['tableNumber'] as String?) ??
        (map['table'] as String?) ??
        '-';

    return TransactionModel(
      id: rawId is num
          ? rawId.toInt()
          : (rawId != null ? int.tryParse(rawId.toString()) : null),
      docId: docId ?? map['doc_id'] as String? ?? map['docId'] as String?,
      invoiceNumber: invNumber,
      dateTime: dtStr,
      cashierName: (map['cashier_name'] as String?) ??
          (map['cashierName'] as String?) ??
          (map['cashier'] as String?) ??
          'Kasir',
      paymentMethod: payMethod,
      customerName: custName,
      tableNumber: tableNum,
      subtotal: rawSubtotal is num
          ? rawSubtotal.toInt()
          : (int.tryParse(rawSubtotal?.toString() ?? '0') ?? 0),
      tax: rawTax is num
          ? rawTax.toInt()
          : (int.tryParse(rawTax?.toString() ?? '0') ?? 0),
      total: rawTotal is num
          ? rawTotal.toInt()
          : (int.tryParse(rawTotal?.toString() ?? '0') ?? 0),
      status: (map['status'] as String?) ?? 'LUNAS',
      storeName: (map['store_name'] as String?) ??
          (map['storeName'] as String?) ??
          'Bella Cafe',
      items: parsedItems,
    );
  }

  /// Convert to standard Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (docId != null) 'doc_id': docId,
      'invoice_number': invoiceNumber,
      'invoiceNumber': invoiceNumber,
      'orderId': invoiceNumber,
      'date_time': dateTime,
      'dateTime': dateTime,
      'cashier_name': cashierName,
      'cashierName': cashierName,
      'payment_method': paymentMethod,
      'paymentMethod': paymentMethod,
      'customer_name': customerName,
      'customerName': customerName,
      'table_number': tableNumber,
      'tableNumber': tableNumber,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'store_name': storeName,
      'storeName': storeName,
    };
  }

  /// Convert to Firestore payload Map (includes embedded items list)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id ?? DateTime.now().millisecondsSinceEpoch,
      'invoice_number': invoiceNumber,
      'invoiceNumber': invoiceNumber,
      'orderId': invoiceNumber,
      'date_time': dateTime,
      'dateTime': dateTime,
      'cashier_name': cashierName,
      'cashierName': cashierName,
      'payment_method': paymentMethod,
      'paymentMethod': paymentMethod,
      'customer_name': customerName,
      'customerName': customerName,
      'table_number': tableNumber,
      'tableNumber': tableNumber,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'store_name': storeName,
      'storeName': storeName,
      'items': items.map((e) => e.toFirestore()).toList(),
    };
  }

  Map<String, dynamic> toLegacyMap() {
    return {
      'id': invoiceNumber.isNotEmpty ? invoiceNumber : (id != null ? '#INV-$id' : '#INV-001'),
      'date': dateTime,
      'cashier': cashierName,
      'method': paymentMethod,
      'customer': customerName,
      'tableNumber': tableNumber,
      'items': items.map((e) => e.toLegacyMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      'storeName': storeName,
    };
  }

  TransactionModel copyWith({
    int? id,
    String? docId,
    String? invoiceNumber,
    String? dateTime,
    String? cashierName,
    String? paymentMethod,
    String? customerName,
    String? tableNumber,
    int? subtotal,
    int? tax,
    int? total,
    String? status,
    String? storeName,
    List<TransactionItemModel>? items,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      dateTime: dateTime ?? this.dateTime,
      cashierName: cashierName ?? this.cashierName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      storeName: storeName ?? this.storeName,
      items: items ?? this.items,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TransactionModel(id: $id, docId: $docId, invoiceNumber: $invoiceNumber, total: $total, status: $status, itemsCount: ${items.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.docId == docId &&
        other.invoiceNumber == invoiceNumber &&
        other.dateTime == dateTime &&
        other.cashierName == cashierName &&
        other.paymentMethod == paymentMethod &&
        other.customerName == customerName &&
        other.tableNumber == tableNumber &&
        other.subtotal == subtotal &&
        other.tax == tax &&
        other.total == total &&
        other.status == status &&
        other.storeName == storeName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      docId,
      invoiceNumber,
      dateTime,
      cashierName,
      paymentMethod,
      customerName,
      tableNumber,
      subtotal,
      tax,
      total,
      status,
      storeName,
    );
  }
}
