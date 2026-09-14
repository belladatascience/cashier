import 'dart:async';
import 'package:cashier/extension/navigator.dart';
import 'package:cashier/CASHIER/database/database_helper.dart';
import 'package:cashier/CASHIER/models/transaction_model.dart';
import 'package:cashier/CASHIER/utils/app_localization.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/utils/menu_data_store.dart';
import 'package:cashier/CASHIER/utils/transaction_data_store.dart';
import 'package:cashier/CASHIER/utils/user_data_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductItem {
  final String id;
  final String name;
  final int price;
  final String category;
  final IconData icon;
  final String imageUrl;

  ProductItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.icon,
    this.imageUrl =
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
  });
}

class CartItem {
  final ProductItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get totalPrice => product.price * quantity;
}

class CartTransactionScreen extends StatefulWidget {
  final String storeName;
  final String cashierName;

  const CartTransactionScreen({
    super.key,
    this.storeName = 'BGA Co. / Bella Cafe',
    this.cashierName = 'Kasir Utama',
  });

  @override
  State<CartTransactionScreen> createState() => _CartTransactionScreenState();
}

class _CartTransactionScreenState extends State<CartTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cashInputController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _tableNumberController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _menuSubscription;

  String _selectedCategory = 'Semua';
  String _selectedPaymentMethod = 'Tunai';

  // Sample Product Catalog
  final List<ProductItem> _products = [
    ProductItem(
      id: 'p1',
      name: 'Ice Latte',
      price: 28000,
      category: 'Kopi',
      icon: Icons.local_cafe,
      imageUrl:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p2',
      name: 'Ice Americano',
      price: 24000,
      category: 'Kopi',
      icon: Icons.coffee,
      imageUrl:
          'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p3',
      name: 'Ice Signature Chocolate',
      price: 35000,
      category: 'Non-Kopi',
      icon: Icons.coffee_maker,
      imageUrl:
          'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p4',
      name: 'Ice Tuffenut Latte',
      price: 32000,
      category: 'Kopi',
      icon: Icons.local_cafe,
      imageUrl:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p5',
      name: 'Ice Thai Tea',
      price: 22000,
      category: 'Non-Kopi',
      icon: Icons.emoji_food_beverage,
      imageUrl:
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p6',
      name: 'Ice Caramel Machiato',
      price: 32000,
      category: 'Kopi',
      icon: Icons.local_cafe,
      imageUrl:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p7',
      name: 'Ice Tea',
      price: 15000,
      category: 'Non-Kopi',
      icon: Icons.emoji_food_beverage,
      imageUrl:
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p8',
      name: 'Ice Creamy Machiato',
      price: 30000,
      category: 'Kopi',
      icon: Icons.local_cafe,
      imageUrl:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p9',
      name: 'Ice Matcha',
      price: 30000,
      category: 'Non-Kopi',
      icon: Icons.emoji_food_beverage,
      imageUrl:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p10',
      name: 'Butter Croissant',
      price: 16500,
      category: 'Makanan',
      icon: Icons.bakery_dining,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p11',
      name: 'Chocolate Lava Cake',
      price: 32000,
      category: 'Makanan',
      icon: Icons.cake,
      imageUrl:
          'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p12',
      name: 'Sourdough Loaf',
      price: 18500,
      category: 'Makanan',
      icon: Icons.breakfast_dining,
      imageUrl:
          'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p13',
      name: 'Pisang Goreng',
      price: 15000,
      category: 'Makanan',
      icon: Icons.fastfood,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p14',
      name: 'Kentang Goreng',
      price: 18000,
      category: 'Makanan',
      icon: Icons.lunch_dining,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p15',
      name: 'Jamur Goreng',
      price: 16000,
      category: 'Makanan',
      icon: Icons.fastfood,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p16',
      name: 'Kebab',
      price: 22000,
      category: 'Makanan',
      icon: Icons.takeout_dining,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p17',
      name: 'Bakwan Goreng Udang',
      price: 15000,
      category: 'Makanan',
      icon: Icons.set_meal,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p18',
      name: 'Cimol Keju',
      price: 14000,
      category: 'Makanan',
      icon: Icons.fastfood,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p19',
      name: 'Donat Kentang',
      price: 12000,
      category: 'Makanan',
      icon: Icons.bakery_dining,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p20',
      name: 'Tahu Cabe Garam',
      price: 16000,
      category: 'Makanan',
      icon: Icons.rice_bowl,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
  ];

  // Active Cart State
  final List<CartItem> _cart = [
    CartItem(
      product: ProductItem(
        id: 'p1',
        name: 'Caffe Latte (Hot)',
        price: 24000,
        category: 'Kopi',
        icon: Icons.local_cafe,
        imageUrl:
            'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
      ),
      quantity: 2,
    ),
    CartItem(
      product: ProductItem(
        id: 'p4',
        name: 'Butter Croissant',
        price: 16500,
        category: 'Makanan',
        icon: Icons.bakery_dining,
        imageUrl:
            'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
      ),
      quantity: 1,
    ),
  ];

  List<String> get _categories {
    final set = <String>{'Semua', 'Kopi', 'Non-Kopi', 'Makanan'};
    for (final p in _products) {
      if (p.category.trim().isNotEmpty) {
        set.add(p.category.trim());
      }
    }
    return set.toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProductsFromFirebase();
    _listenToMenuRealtime();
    MenuDataStore.instance.menuDataNotifier.addListener(_onMenuDataUpdated);
  }

  void _onMenuDataUpdated() {
    if (mounted) {
      _loadProductsFromFirebase();
    }
  }

  void _listenToMenuRealtime() {
    try {
      _menuSubscription?.cancel();
      _menuSubscription = _firestore.collection('menu_items').snapshots().listen(
        (snapshot) {
          if (!mounted) return;
          final List<ProductItem> fbProducts = [];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final name = data['name'] as String? ?? 'Item';
            final price = (data['price'] as num?)?.toInt() ?? 0;
            final category = data['category'] as String? ?? 'Semua';
            final image = (data['imagePath'] ??
                    data['image'] ??
                    data['imageUrl'] ??
                    '')
                as String;

            IconData icon = Icons.restaurant;
            final catLower = category.toLowerCase();
            if (catLower.contains('drink') ||
                catLower.contains('minuman') ||
                catLower.contains('kopi') ||
                catLower.contains('coffee')) {
              icon = Icons.local_cafe;
            } else if (catLower.contains('snack') ||
                catLower.contains('camilan')) {
              icon = Icons.fastfood;
            } else if (catLower.contains('dessert') ||
                catLower.contains('cake')) {
              icon = Icons.cake;
            }

            fbProducts.add(
              ProductItem(
                id: doc.id,
                name: name,
                price: price,
                category: category,
                icon: icon,
                imageUrl: image.startsWith('http')
                    ? image
                    : 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
              ),
            );
          }

          if (fbProducts.isNotEmpty) {
            setState(() {
              _products.clear();
              _products.addAll(fbProducts);
            });
          }
        },
        onError: (e) {
          debugPrint('Error listening to menu_items Firestore: $e');
        },
      );
    } catch (e) {
      debugPrint('Error attaching menu stream: $e');
    }
  }

  void _loadProductsFromFirebase() {
    final catMap = MenuDataStore.instance.categoryDataMap;
    final List<ProductItem> dynamicProducts = [];

    catMap.forEach((category, items) {
      for (final item in items) {
        final name = item['name'] as String? ?? 'Item';
        final price = item['price'] is int
            ? item['price'] as int
            : int.tryParse(item['price']?.toString() ?? '0') ?? 0;
        final id = item['id']?.toString() ?? 'item_${name.hashCode}';
        final image = item['imagePath'] as String? ??
            item['image'] as String? ??
            'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80';

        IconData icon = Icons.restaurant;
        final catLower = category.toLowerCase();
        if (catLower.contains('drink') ||
            catLower.contains('minuman') ||
            catLower.contains('kopi') ||
            catLower.contains('coffee')) {
          icon = Icons.local_cafe;
        } else if (catLower.contains('snack') || catLower.contains('camilan')) {
          icon = Icons.fastfood;
        } else if (catLower.contains('dessert') || catLower.contains('cake')) {
          icon = Icons.cake;
        }

        dynamicProducts.add(
          ProductItem(
            id: id,
            name: name,
            price: price,
            category: category,
            icon: icon,
            imageUrl: image.startsWith('http')
                ? image
                : 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
          ),
        );
      }
    });

    if (dynamicProducts.isNotEmpty) {
      setState(() {
        _products.clear();
        _products.addAll(dynamicProducts);
      });
    }
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    MenuDataStore.instance.menuDataNotifier.removeListener(_onMenuDataUpdated);
    _tabController.dispose();
    _searchController.dispose();
    _cashInputController.dispose();
    _customerNameController.dispose();
    _tableNumberController.dispose();
    super.dispose();
  }

  int get _totalCartItems => _cart.fold(0, (sum, item) => sum + item.quantity);

  int get _cartSubtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);

  int get _taxAmount => (_cartSubtotal * 0.1).round();

  int get _totalPayable => _cartSubtotal + _taxAmount;

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _addToCart(ProductItem product) {
    setState(() {
      final index = _cart.indexWhere((c) => c.product.id == product.id);
      if (index != -1) {
        _cart[index].quantity += 1;
      } else {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    });

    final theme = AppTheme.instance;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.name} ditambahkan ke Keranjang!',
          style: GoogleFonts.workSans(color: Colors.white),
        ),
        backgroundColor: theme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _processPayment() {
    if (_cart.isEmpty) {
      _showSnackBar('Keranjang pesanan masih kosong');
      return;
    }

    final theme = AppTheme.instance;
    int cashGiven = _totalPayable;
    _cashInputController.text = _totalPayable.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (paymentContext) {
        return StatefulBuilder(
          builder: (context, setPaymentState) {
            final change = cashGiven - _totalPayable;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pembayaran POS',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(paymentContext),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Customer & Table Info Card
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_pin_rounded,
                                size: 20,
                                color: theme.secondaryColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer',
                                      style: GoogleFonts.workSans(
                                        fontSize: 11,
                                        color: theme.outlineColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _customerNameController.text
                                              .trim()
                                              .isEmpty
                                          ? 'Pelanggan Umum (Walk-in)'
                                          : _customerNameController.text.trim(),
                                      style: GoogleFonts.workSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_tableNumberController.text
                              .trim()
                              .isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: theme.dividerColor,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.table_restaurant_outlined,
                                  size: 18,
                                  color: theme.secondaryColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Table',
                                        style: GoogleFonts.workSans(
                                          fontSize: 11,
                                          color: theme.outlineColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _tableNumberController.text.trim(),
                                        style: GoogleFonts.workSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: theme.secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Total Tagihan Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.secondaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.secondaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'TOTAL PEMBAYARAN',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: theme.secondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(_totalPayable),
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Metoded Pembayaran
                    Text(
                      'PILIH METODE PEMBAYARAN',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: theme.outlineColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPaymentChip(
                          label: 'Tunai / Cash',
                          icon: Icons.payments_outlined,
                          isSelected: _selectedPaymentMethod == 'Tunai',
                          onTap: () {
                            setPaymentState(() {
                              _selectedPaymentMethod = 'Tunai';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentChip(
                          label: 'QRIS',
                          icon: Icons.qr_code_scanner,
                          isSelected: _selectedPaymentMethod == 'QRIS',
                          onTap: () {
                            setPaymentState(() {
                              _selectedPaymentMethod = 'QRIS';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPaymentChip(
                          label: 'Debit / Kartu',
                          icon: Icons.credit_card,
                          isSelected: _selectedPaymentMethod == 'Debit',
                          onTap: () {
                            setPaymentState(() {
                              _selectedPaymentMethod = 'Debit';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Tunai Details
                    if (_selectedPaymentMethod == 'Tunai') ...[
                      Text(
                        'NOMINAL UANG DITERIMA',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: theme.outlineColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Quick Cash Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setPaymentState(() {
                                  cashGiven = _totalPayable;
                                  _cashInputController.text = cashGiven
                                      .toString();
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.secondaryColor),
                              ),
                              child: const Text('Uang Pas'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setPaymentState(() {
                                  cashGiven = 50000;
                                  _cashInputController.text = '50000';
                                });
                              },
                              child: const Text('Rp 50.000'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setPaymentState(() {
                                  cashGiven = 100000;
                                  _cashInputController.text = '100000';
                                });
                              },
                              child: const Text('Rp 100.000'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _cashInputController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.workSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          labelText: 'Jumlah Uang Tunai',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (val) {
                          setPaymentState(() {
                            cashGiven = int.tryParse(val) ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 14),

                      // Change / Kembalian Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: change >= 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              change >= 0 ? 'Kembalian:' : 'Uang Kurang:',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: change >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              _formatCurrency(change.abs()),
                              style: GoogleFonts.workSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: change >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            (_selectedPaymentMethod == 'Tunai' &&
                                cashGiven < _totalPayable)
                            ? null
                            : () {
                                Navigator.pop(paymentContext);
                                _showReceiptSuccessDialog(cashGiven);
                              },
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Selesaikan Transaksi',
                          style: GoogleFonts.workSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.instance;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.secondaryColor
                : theme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.secondaryColor : theme.dividerColor,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : theme.primaryColor,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiptSuccessDialog(int cashGiven) async {
    final theme = AppTheme.instance;
    final receiptNo =
        '#POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final changeAmount = cashGiven - _totalPayable;

    final now = DateTime.now();
    final dateStr =
        '${now.day} Aug ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final activeCashier =
        UserDataStore.instance.userDataNotifier.value['cashierName'] ??
        UserDataStore.instance.userDataNotifier.value['name'] ??
        _auth.currentUser?.displayName ??
        widget.cashierName;
    final activeStore =
        UserDataStore.instance.userDataNotifier.value['storeName'] ??
        widget.storeName;
    final customerName = _customerNameController.text.trim().isEmpty
        ? 'Pelanggan Umum'
        : _customerNameController.text.trim();

    final txModel = TransactionModel(
      invoiceNumber: receiptNo,
      dateTime: dateStr,
      cashierName: activeCashier.toString(),
      paymentMethod: _selectedPaymentMethod,
      customerName: customerName,
      tableNumber: _tableNumberController.text.trim().isNotEmpty
          ? _tableNumberController.text.trim()
          : '-',
      subtotal: _cartSubtotal,
      tax: _taxAmount,
      total: _totalPayable,
      status: 'LUNAS',
      storeName: activeStore.toString(),
      items: _cart
          .map(
            (c) => TransactionItemModel(
              invoiceNumber: receiptNo,
              menuName: c.product.name,
              qty: c.quantity,
              price: c.product.price,
              subtotal: c.totalPrice,
            ),
          )
          .toList(),
    );

    try {
      await DataBaseHelper().insertTransaction(txModel);
      TransactionDataStore.instance.initialize();
    } catch (e) {
      debugPrint('Error inserting transaction Firestore: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32),
                    size: 52,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Transaksi Jual Beli Berhasil! ☕',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.storeName,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.secondaryColor,
                  ),
                ),
                const Divider(height: 24),

                // Receipt Content Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Toko / Outlet:',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.outlineColor,
                            ),
                          ),
                          Text(
                            UserDataStore
                                    .instance
                                    .userDataNotifier
                                    .value['storeName'] ??
                                widget.storeName ??
                                'Bella Cafe',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'No. Struk:',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.outlineColor,
                            ),
                          ),
                          Text(
                            receiptNo,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cashier:',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.outlineColor,
                            ),
                          ),
                          Text(
                            UserDataStore
                                    .instance
                                    .userDataNotifier
                                    .value['cashierName'] ??
                                UserDataStore
                                    .instance
                                    .userDataNotifier
                                    .value['name'] ??
                                widget.cashierName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Customer:',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.outlineColor,
                            ),
                          ),
                          Text(
                            _customerNameController.text.trim().isEmpty
                                ? 'Pelanggan Umum'
                                : _customerNameController.text.trim(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (_tableNumberController.text.trim().isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Table:',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.outlineColor,
                              ),
                            ),
                            Text(
                              _tableNumberController.text.trim(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Metode:',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.outlineColor,
                            ),
                          ),
                          Text(
                            _selectedPaymentMethod,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      ..._cart.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.quantity}x ${item.product.name}',
                                style: GoogleFonts.workSans(
                                  fontSize: 13,
                                  color: theme.primaryColor,
                                ),
                              ),
                              Text(
                                _formatCurrency(item.totalPrice),
                                style: GoogleFonts.workSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:'),
                          Text(
                            _formatCurrency(_totalPayable),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_selectedPaymentMethod == 'Tunai') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bayar:'),
                            Text(_formatCurrency(cashGiven)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian:'),
                            Text(
                              _formatCurrency(changeAmount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                _showSnackBar('Struk transaksi $receiptNo berhasil dicetak!');
              },
              icon: const Icon(Icons.print_outlined),
              label: const Text('Cetak Struk'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _cart.clear();
                  _customerNameController.clear();
                  _tableNumberController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Transaksi Baru'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    final theme = AppTheme.instance;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.workSans(color: Colors.white),
        ),
        backgroundColor: theme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;

    final filteredProducts = _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: loc.currentLanguageNotifier,
          builder: (context, langCode, child) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,

              // Top AppBar with Live Cart Counter Badge
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Cart / Keranjang POS',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart_outlined,
                          color: theme.primaryColor,
                        ),
                        onPressed: () => _tabController.animateTo(1),
                      ),
                      if (_totalCartItems > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$_totalCartItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: theme.secondaryColor,
                  unselectedLabelColor: theme.outlineColor,
                  indicatorColor: theme.secondaryColor,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.grid_view_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Katalog Produk'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart, size: 18),
                          const SizedBox(width: 6),
                          Text('Keranjang ($_totalCartItems)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              body: SafeArea(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: Katalog Produk Jual Beli
                    Column(
                      children: [
                        // Search & Filter Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: _searchController,
                                style: GoogleFonts.workSans(
                                  color: theme.primaryColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Cari menu atau produk...',
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: theme.outlineColor,
                                  ),
                                  filled: true,
                                  fillColor: theme.surfaceColor,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.dividerColor,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 12),

                              // Categories Single Select
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _categories.map((cat) {
                                    final isSel = _selectedCategory == cat;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                          child: ChoiceChip(
                                            label: Text(cat),
                                            selected: isSel,
                                            selectedColor: theme.secondaryColor,
                                            labelStyle: GoogleFonts.workSans(
                                              color: isSel
                                                  ? Colors.white
                                                  : theme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            onSelected: (selected) {
                                              if (selected) {
                                                setState(() {
                                                  _selectedCategory = cat;
                                                });
                                              }
                                            },
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Products Grid
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final p = filteredProducts[index];

                              return Card(
                                elevation: 0,
                                color: theme.surfaceColor,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: theme.dividerColor),
                                ),
                                child: InkWell(
                                  onTap: () => _addToCart(p),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            p.imageUrl,
                                            height: 70,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  height: 70,
                                                  width: double.infinity,
                                                  color: theme
                                                      .secondaryContainer
                                                      .withValues(alpha: 0.2),
                                                  child: Icon(
                                                    p.icon,
                                                    size: 36,
                                                    color: theme.secondaryColor,
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.workSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        Text(
                                          _formatCurrency(p.price),
                                          style: GoogleFonts.workSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: theme.secondaryColor,
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 34,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _addToCart(p),
                                            icon: const Icon(
                                              Icons.add_shopping_cart,
                                              size: 16,
                                            ),
                                            label: const Text('Tambah'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // TAB 2: Detail Keranjang Transaksi POS
                    Column(
                      children: [
                        if (_cart.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                            decoration: BoxDecoration(
                              color: theme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Field 1: Customer
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: theme.secondaryContainer
                                              .withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          color: theme.secondaryColor,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'CUSTOMER',
                                              style: GoogleFonts.workSans(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: theme.outlineColor,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            TextField(
                                              controller:
                                                  _customerNameController,
                                              style: GoogleFonts.workSans(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: theme.primaryColor,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                border: InputBorder.none,
                                                hintText:
                                                    'Customer name (e.g. Kak Bella)...',
                                                hintStyle: GoogleFonts.workSans(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.normal,
                                                  color: theme.outlineColor
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                              onChanged: (val) =>
                                                  setState(() {}),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_customerNameController
                                          .text
                                          .isNotEmpty)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: theme.outlineColor,
                                          onPressed: () {
                                            setState(() {
                                              _customerNameController.clear();
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),

                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: theme.dividerColor,
                                ),

                                // Field 2: Table (dibawah Customer)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: theme.secondaryContainer
                                              .withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.table_restaurant_outlined,
                                          color: theme.secondaryColor,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'TABLE',
                                              style: GoogleFonts.workSans(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: theme.outlineColor,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            TextField(
                                              controller:
                                                  _tableNumberController,
                                              style: GoogleFonts.workSans(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: theme.primaryColor,
                                              ),
                                              decoration: InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                                border: InputBorder.none,
                                                hintText:
                                                    'Table / Meja (e.g. Table 04)...',
                                                hintStyle: GoogleFonts.workSans(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.normal,
                                                  color: theme.outlineColor
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                              onChanged: (val) =>
                                                  setState(() {}),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_tableNumberController
                                          .text
                                          .isNotEmpty)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          color: theme.outlineColor,
                                          onPressed: () {
                                            setState(() {
                                              _tableNumberController.clear();
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Expanded(
                          child: _cart.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 64,
                                        color: theme.outlineColor,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Keranjang Masih Kosong',
                                        style: GoogleFonts.sourceSerif4(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _tabController.animateTo(0),
                                        child: const Text(
                                          'Pilih Produk Sekarang',
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _cart.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final cartItem = _cart[index];

                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme.dividerColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              cartItem.product.imageUrl,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    cartItem.product.icon,
                                                    color: theme.secondaryColor,
                                                    size: 28,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItem.product.name,
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  _formatCurrency(
                                                    cartItem.product.price,
                                                  ),
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 13,
                                                    color: theme.secondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_circle_outline,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    if (cartItem.quantity > 1) {
                                                      cartItem.quantity -= 1;
                                                    } else {
                                                      _cart.removeAt(index);
                                                    }
                                                  });
                                                },
                                              ),
                                              Text(
                                                '${cartItem.quantity}',
                                                style: GoogleFonts.workSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    cartItem.quantity += 1;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // Bottom Summary Bar
                        if (_cart.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.surfaceColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                              border: Border(
                                top: BorderSide(color: theme.dividerColor),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Subtotal:',
                                      style: TextStyle(
                                        color: theme.outlineColor,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(_cartSubtotal),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pajak (10%):',
                                      style: TextStyle(
                                        color: theme.outlineColor,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(_taxAmount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Bayar:',
                                      style: GoogleFonts.sourceSerif4(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(_totalPayable),
                                      style: GoogleFonts.workSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: theme.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _processPayment,
                                    icon: const Icon(
                                      Icons.point_of_sale,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Bayar Transaksi Jual Beli',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
