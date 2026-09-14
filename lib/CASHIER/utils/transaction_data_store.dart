import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cashier/CASHIER/database/database_helper.dart';
import 'package:cashier/CASHIER/models/transaction_model.dart';
import 'package:flutter/foundation.dart';

class TransactionDataStore {
  static final TransactionDataStore instance = TransactionDataStore._internal();
  TransactionDataStore._internal();

  bool _isInitialized = false;
  StreamSubscription? _txSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<List<TransactionModel>> transactionsNotifier =
      ValueNotifier<List<TransactionModel>>([]);

  List<TransactionModel> get transactions => List<TransactionModel>.from(transactionsNotifier.value);

  List<Map<String, dynamic>> get legacyTransactions =>
      transactionsNotifier.value.map((tx) => tx.toLegacyMap()).toList();

  /// Inisialisasi data store dan stream real-time Firestore
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // Load initial default seed jika belum ada data
    if (transactionsNotifier.value.isEmpty) {
      transactionsNotifier.value = _generateInitialSeed();
    }

    _subscribeFirestore();
  }

  void _subscribeFirestore() {
    _txSubscription?.cancel();
    try {
      _txSubscription = _firestore.collection('transactions').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<TransactionModel> list = [];
          for (final doc in snapshot.docs) {
            try {
              final data = doc.data();
              final rawItems = data['items'] as List<dynamic>? ?? [];
              final items = rawItems
                  .map((i) => TransactionItemModel.fromMap(Map<String, dynamic>.from(i as Map)))
                  .toList();
              final model = TransactionModel.fromMap(data, items, doc.id);
              list.add(model);
            } catch (e) {
              debugPrint('Error parsing transaction doc ${doc.id}: $e');
            }
          }

          if (list.isNotEmpty) {
            // Sort terbaru di atas
            list.sort((a, b) {
              final aId = a.id ?? 0;
              final bId = b.id ?? 0;
              return bId.compareTo(aId);
            });
            transactionsNotifier.value = list;
          }
        }
      }, onError: (e) {
        debugPrint('Firestore transactions stream error: $e');
      });
    } catch (e) {
      debugPrint('Error initializing transactions stream: $e');
    }
  }

  /// Menambahkan transaksi baru dan memperbarui UI secara instan
  Future<void> addTransaction(TransactionModel tx) async {
    final currentList = List<TransactionModel>.from(transactionsNotifier.value);
    // Hapus jika sudah ada invoice number sama
    currentList.removeWhere((t) => t.invoiceNumber == tx.invoiceNumber && tx.invoiceNumber.isNotEmpty);
    // Tambahkan di urutan paling awal (terbaru)
    currentList.insert(0, tx);
    transactionsNotifier.value = currentList;

    // Simpan ke Firestore & DatabaseHelper di background
    try {
      await DataBaseHelper().insertTransaction(tx);
    } catch (e) {
      debugPrint('Background save error in addTransaction: $e');
    }
  }

  /// Initial Sample Seed Transactions
  static List<TransactionModel> _generateInitialSeed() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final todayStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayStr = '${yesterday.day} ${months[yesterday.month - 1]} ${yesterday.year}';

    final inv1 = 'TRX-${now.millisecondsSinceEpoch - 120000}';
    final inv2 = 'TRX-${now.millisecondsSinceEpoch - 3600000}';
    final inv3 = 'TRX-${yesterday.millisecondsSinceEpoch - 7200000}';

    return [
      TransactionModel(
        id: 1001,
        invoiceNumber: inv1,
        dateTime: '$todayStr, 08:04',
        cashierName: 'Bella Gita Asmara',
        paymentMethod: 'Tunai di Kasir (Cash)',
        customerName: 'bella (1)',
        tableNumber: '1',
        subtotal: 60000,
        tax: 6000,
        total: 66000,
        status: 'LUNAS',
        storeName: 'Bella Cafe',
        items: [
          TransactionItemModel(
            invoiceNumber: inv1,
            menuName: 'Signature BGA Latte',
            qty: 2,
            price: 30000,
            subtotal: 60000,
          ),
        ],
      ),
      TransactionModel(
        id: 1002,
        invoiceNumber: inv2,
        dateTime: '$todayStr, 07:30',
        cashierName: 'Bella Gita Asmara',
        paymentMethod: 'Digital Wallet (QRIS)',
        customerName: 'Kak Doni',
        tableNumber: '3',
        subtotal: 75000,
        tax: 7500,
        total: 82500,
        status: 'LUNAS',
        storeName: 'Bella Cafe',
        items: [
          TransactionItemModel(
            invoiceNumber: inv2,
            menuName: 'Sourdough Artisan Loaf',
            qty: 1,
            price: 38000,
            subtotal: 38000,
          ),
          TransactionItemModel(
            invoiceNumber: inv2,
            menuName: 'Butter French Croissant',
            qty: 1,
            price: 25000,
            subtotal: 25000,
          ),
        ],
      ),
      TransactionModel(
        id: 1003,
        invoiceNumber: inv3,
        dateTime: '$yesterdayStr, 14:15',
        cashierName: 'Bella Gita Asmara',
        paymentMethod: 'Tunai di Kasir (Cash)',
        customerName: 'Pelanggan Umum',
        tableNumber: 'Takeaway',
        subtotal: 45000,
        tax: 4500,
        total: 49500,
        status: 'LUNAS',
        storeName: 'Bella Cafe',
        items: [
          TransactionItemModel(
            invoiceNumber: inv3,
            menuName: 'Avocado Sunny Toast',
            qty: 1,
            price: 45000,
            subtotal: 45000,
          ),
        ],
      ),
    ];
  }
}
