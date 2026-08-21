import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
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

  String _selectedCategory = 'Semua';
  String _selectedPaymentMethod = 'Tunai';

  // Sample Product Catalog
  final List<ProductItem> _products = [
    ProductItem(
      id: 'p1',
      name: 'Caffe Latte (Hot)',
      price: 24000,
      category: 'Kopi',
      icon: Icons.local_cafe,
      imageUrl:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p2',
      name: 'Iced Americano',
      price: 22000,
      category: 'Kopi',
      icon: Icons.coffee,
      imageUrl:
          'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p3',
      name: 'Cappuccino Warm',
      price: 25000,
      category: 'Kopi',
      icon: Icons.coffee_maker,
      imageUrl:
          'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p4',
      name: 'Butter Croissant',
      price: 16500,
      category: 'Makanan',
      icon: Icons.bakery_dining,
      imageUrl:
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p5',
      name: 'Matcha Latte (Ice)',
      price: 28000,
      category: 'Non-Kopi',
      icon: Icons.emoji_food_beverage,
      imageUrl:
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p6',
      name: 'Chocolate Lava Cake',
      price: 32000,
      category: 'Makanan',
      icon: Icons.cake,
      imageUrl:
          'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p7',
      name: 'Earl Grey Milk Tea',
      price: 26000,
      category: 'Non-Kopi',
      icon: Icons.wine_bar,
      imageUrl:
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=300&q=80',
    ),
    ProductItem(
      id: 'p8',
      name: 'Sourdough Loaf',
      price: 18500,
      category: 'Makanan',
      icon: Icons.breakfast_dining,
      imageUrl:
          'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?auto=format&fit=crop&w=300&q=80',
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _cashInputController.dispose();
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

  void _showReceiptSuccessDialog(int cashGiven) {
    final theme = AppTheme.instance;
    final receiptNo =
        '#POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final changeAmount = cashGiven - _totalPayable;

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
                                  children:
                                      [
                                        'Semua',
                                        'Kopi',
                                        'Non-Kopi',
                                        'Makanan',
                                      ].map((cat) {
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
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            p.imageUrl,
                                            height: 70,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  height: 70,
                                                  width: double.infinity,
                                                  color: theme.secondaryContainer
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
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              cartItem.product.imageUrl,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Icon(
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
