import 'dart:typed_data';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/cashier_profile_screen.dart';
import 'package:cashier/halaman1/views/checkout_screen.dart';
import 'package:cashier/halaman1/views/edit_menu_screen.dart';
import 'package:cashier/halaman1/views/login.dart';
import 'package:cashier/halaman1/views/settings_screen.dart';
import 'package:cashier/halaman1/views/staff_shift_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  final String storeName;
  final String storeLocation;
  final String shift;

  const HomeScreen({
    super.key,
    this.storeName = 'Bella Caffee',
    this.storeLocation = 'Jakarta',
    this.shift = 'Pagi',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentBottomTab = 1;

  // Shop Category & Data State
  int _selectedShopCategoryTab = 1; // 0: Food, 1: Drink, 2: Snack

  // Transaction History State
  String _transactionFilter = 'Semua';
  String _transactionSearchQuery = '';
  DateTime? _selectedTransactionDate;

  final List<Map<String, dynamic>> _transactionHistory = [
    {
      'id': '#INV-20260818-001',
      'date': '18 Aug 2026, 14:15',
      'method': 'Digital Wallet (QRIS)',
      'customer': 'Handky Chang',
      'items': [
        {'name': 'Rustic Sourdough Loaf', 'qty': 1, 'price': 45000},
        {'name': 'Butter Croissant', 'qty': 2, 'price': 28000},
        {'name': 'Berry Tart', 'qty': 1, 'price': 55000},
      ],
      'subtotal': 156000,
      'tax': 15600,
      'total': 171600,
      'status': 'LUNAS',
    },
    {
      'id': '#INV-20260818-002',
      'date': '18 Aug 2026, 13:40',
      'method': 'Cash in Store',
      'customer': 'Pelanggan Umum',
      'items': [
        {'name': 'Artisan Matcha Latte', 'qty': 1, 'price': 35000},
        {'name': 'Classic Cafe Latte', 'qty': 1, 'price': 32000},
        {'name': 'Signature Hot Chocolate', 'qty': 1, 'price': 38000},
      ],
      'subtotal': 105000,
      'tax': 10500,
      'total': 115500,
      'status': 'LUNAS',
    },
    {
      'id': '#INV-20260818-003',
      'date': '18 Aug 2026, 11:20',
      'method': 'Digital Wallet (GoPay)',
      'customer': 'Budi Santoso',
      'items': [
        {'name': 'Berry Cheesecake', 'qty': 2, 'price': 28000},
        {'name': 'Sparkling Citrus Water', 'qty': 1, 'price': 25000},
      ],
      'subtotal': 81000,
      'tax': 8100,
      'total': 89100,
      'status': 'LUNAS',
    },
    {
      'id': '#INV-20260817-004',
      'date': '17 Aug 2026, 16:05',
      'method': 'Cash in Store',
      'customer': 'Siti Rahma',
      'items': [
        {'name': 'Butter Croissant', 'qty': 3, 'price': 28000},
      ],
      'subtotal': 84000,
      'tax': 8400,
      'total': 92400,
      'status': 'LUNAS',
    },
  ];

  final List<Map<String, dynamic>> _drinkMenuItems = [
    {
      'name': 'Artisan Matcha Latte',
      'price': 35000,
      'priceText': 'Rp 35.000',
      'desc': 'Premium ceremonial grade matcha whisked with creamy milk.',
      'image':
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
      'category': 'Drink',
    },
    {
      'name': 'Classic Cafe Latte',
      'price': 32000,
      'priceText': 'Rp 32.000',
      'desc':
          'Rich espresso balanced with velvety steamed milk and heart latte art.',
      'image':
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=300&q=80',
      'category': 'Drink',
    },
    {
      'name': 'Iced Lemon Tea',
      'price': 28000,
      'priceText': 'Rp 28.000',
      'desc':
          'Refreshing black tea infused with fresh lemon and a hint of mint.',
      'image':
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?auto=format&fit=crop&w=300&q=80',
      'category': 'Drink',
    },
    {
      'name': 'Signature Hot Chocolate',
      'price': 38000,
      'priceText': 'Rp 38.000',
      'desc':
          'Decadent dark chocolate melted into warm milk with a dash of cocoa.',
      'image':
          'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?auto=format&fit=crop&w=300&q=80',
      'category': 'Drink',
    },
    {
      'name': 'Sparkling Citrus Water',
      'price': 25000,
      'priceText': 'Rp 25.000',
      'desc': 'Crisp sparkling water served with fresh lime and lemon slices.',
      'image':
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=300&q=80',
      'category': 'Drink',
    },
  ];

  final List<Map<String, dynamic>> _foodMenuItems = [
    {
      'name': 'Sourdough Loaf',
      'price': 38000,
      'priceText': 'Rp 38.000',
      'desc':
          'Classic artisanal loaf, naturally leavened with a dark crackly crust.',
      'image':
          'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?auto=format&fit=crop&w=300&q=80',
      'category': 'Food',
    },
    {
      'name': 'Butter Croissant',
      'price': 25000,
      'priceText': 'Rp 25.000',
      'desc': 'Traditional French pastry with shattered, buttery layers.',
      'image':
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
      'category': 'Food',
    },
    {
      'name': 'Avocado Toast',
      'price': 45000,
      'priceText': 'Rp 45.000',
      'desc': 'Mashed Hass avocado with lemon, chili flakes, and sea salt.',
      'image':
          'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?auto=format&fit=crop&w=300&q=80',
      'category': 'Food',
    },
    {
      'name': 'Berry Tart',
      'price': 35000,
      'priceText': 'Rp 35.000',
      'desc':
          'Seasonal mixed berries on vanilla pastry cream in a sweet crust.',
      'image':
          'https://images.unsplash.com/photo-1519869325930-281384150729?auto=format&fit=crop&w=300&q=80',
      'category': 'Food',
    },
  ];

  final List<Map<String, dynamic>> _snackMenuItems = [
    {
      'name': 'Choco Chip Cookie',
      'price': 18000,
      'priceText': 'Rp 18.000',
      'desc': 'Soft-baked Belgian chocolate chunk cookie with sea salt.',
      'image':
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=300&q=80',
      'category': 'Snack',
    },
    {
      'name': 'Almond Muffin',
      'price': 22000,
      'priceText': 'Rp 22.000',
      'desc':
          'Fluffy golden muffin filled with almond paste and toasted flakes.',
      'image':
          'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&w=300&q=80',
      'category': 'Snack',
    },
  ];

  final List<Map<String, dynamic>> _newMenuItems = [
    {
      'name': 'Sparkling Citrus Water',
      'price': 25000,
      'priceText': 'Rp 25.000',
      'desc': 'Crisp sparkling water served with fresh lime and lemon slices.',
      'image':
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=300&q=80',
      'category': 'New',
    },
    {
      'name': 'Artisan Matcha Latte',
      'price': 35000,
      'priceText': 'Rp 35.000',
      'desc': 'Premium ceremonial grade matcha whisked with creamy milk.',
      'image':
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    },
  ];

  final List<Map<String, dynamic>> _dessertMenuItems = [
    {
      'name': 'Berry Cheesecake',
      'price': 28000,
      'priceText': 'Rp 28.000',
      'desc':
          'Creamy New York style cheesecake topped with fresh berry compote.',
      'image':
          'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=300&q=80',
      'category': 'Dessert',
    },
    {
      'name': 'Tiramisu Cup',
      'price': 30000,
      'priceText': 'Rp 30.000',
      'desc':
          'Classic Italian dessert with espresso-soaked ladyfingers and mascarpone.',
      'image':
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=300&q=80',
      'category': 'Dessert',
    },
  ];

  final List<String> _shopCategoryNames = ['Food', 'Drink', 'Snack', 'Dessert'];
  late final Map<String, List<Map<String, dynamic>>> _shopCategoryDataMap = {
    'Food': _foodMenuItems,
    'Drink': _drinkMenuItems,
    'Snack': _snackMenuItems,
    'Dessert': _dessertMenuItems,
  };

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final index = _cartItems.indexWhere(
        (element) => element['name'] == item['name'],
      );
      if (index != -1) {
        _cartItems[index]['quantity'] =
            (_cartItems[index]['quantity'] as int) + 1;
      } else {
        _cartItems.add({
          'name': item['name'],
          'price': item['price'],
          'quantity': 1,
          'category': item['category'] ?? 'Menu',
          'icon': Icons.restaurant,
        });
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorSecondary,
      ),
    );
  }

  // Dynamic Color Tokens linked to AppTheme
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorPrimaryContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFF3B3835)
      : const Color(0xFF5D4037);
  Color get colorOnPrimaryContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFFF5EFEA)
      : const Color(0xFFD4ADA1);
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorSecondaryContainer => AppTheme.instance.secondaryContainer;
  Color get colorOnSecondaryContainer => AppTheme.instance.onSecondaryContainer;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurface => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOutline => AppTheme.instance.outlineColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorTertiaryFixed => AppTheme.instance.isDarkMode
      ? const Color(0xFF32302D)
      : const Color(0xFFE2E6BF);
  Color get colorOnTertiaryFixed => AppTheme.instance.isDarkMode
      ? const Color(0xFFF0BD8B)
      : const Color(0xFF1A1D06);
  Color get colorError => const Color(0xFFBA1A1A);
  Color get colorErrorContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFF501010)
      : const Color(0xFFFFDAD6);

  // Editable Store Banner Image State
  Uint8List? _bannerImageBytes;
  String? _customBannerUrl;
  final ImagePicker _picker = ImagePicker();

  // Interactive Order Cart State
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Rustic Sourdough Loaf',
      'price': 45000,
      'quantity': 1,
      'desc': 'Freshly baked, crusty exterior with a soft, airy crumb.',
      'image':
          'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Butter Croissant',
      'price': 28000,
      'quantity': 2,
      'desc': 'Classic French pastry, flaky and rich with French butter.',
      'image':
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Berry Tart',
      'price': 55000,
      'quantity': 1,
      'desc':
          'Seasonal mixed berries on a vanilla custard base in a crisp shell.',
      'image':
          'https://images.unsplash.com/photo-1519869325930-281384150729?auto=format&fit=crop&w=300&q=80',
    },
  ];

  int get _cartTotalItems =>
      _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));

  int get _cartSubtotal => _cartItems.fold(
    0,
    (sum, item) => sum + ((item['price'] as int) * (item['quantity'] as int)),
  );

  int get _cartTax => (_cartSubtotal * 0.1).round();

  int get _cartTotalAmount => _cartSubtotal + _cartTax;

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showCartBottomSheet() {
    setState(() {
      _currentBottomTab = 2;
    });
  }

  void _processCartPayment() {
    final paidAmount = _cartTotalAmount;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colorSurfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E7D32),
                  size: 48,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pembayaran Berhasil! ☕',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Transaksi POS kasir sebesar ${_formatCurrency(paidAmount)} telah berhasil diproses.',
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: colorOnSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'No. Struk:',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        color: colorOnSurfaceVariant,
                      ),
                    ),
                    Text(
                      '#POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Struk pembayaran berhasil dicetak!'),
                    backgroundColor: colorSecondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                setState(() {
                  _cartItems.clear();
                });
              },
              icon: const Icon(Icons.print_outlined),
              label: const Text('Cetak Struk'),
              style: TextButton.styleFrom(foregroundColor: colorSecondary),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _cartItems.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  static const String _defaultBannerUrl =
      'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=600&q=80';

  Future<void> _pickBannerImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _bannerImageBytes = bytes;
          _customBannerUrl = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gambar toko berhasil diperbarui!'),
              backgroundColor: colorSecondary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: colorError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showChangeBannerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorOutlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Ubah Gambar Toko / Banner',
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorSecondaryContainer,
                    child: Icon(
                      Icons.photo_library,
                      color: colorOnSecondaryContainer,
                    ),
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickBannerImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorTertiaryFixed,
                    child: Icon(Icons.camera_alt, color: colorOnTertiaryFixed),
                  ),
                  title: Text(
                    'Ambil Foto Kamera',
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickBannerImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorSurfaceContainerLow,
                    child: Icon(Icons.link, color: colorPrimary),
                  ),
                  title: Text(
                    'Input URL Gambar',
                    style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showUrlInputDialog();
                  },
                ),
                if (_bannerImageBytes != null || _customBannerUrl != null)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorErrorContainer,
                      child: Icon(Icons.delete_outline, color: colorError),
                    ),
                    title: Text(
                      'Hapus / Reset Gambar',
                      style: GoogleFonts.workSans(
                        fontWeight: FontWeight.w600,
                        color: colorError,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _bannerImageBytes = null;
                        _customBannerUrl = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUrlInputDialog() {
    final controller = TextEditingController(text: _customBannerUrl ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Input URL Gambar Toko',
          style: GoogleFonts.sourceSerif4(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://images.unsplash.com/...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: colorOnSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _customBannerUrl = controller.text.trim();
                  _bannerImageBytes = null;
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerWidget({double height = 140, double borderRadius = 16}) {
    Widget imageContent;
    if (_bannerImageBytes != null) {
      imageContent = Image.memory(
        _bannerImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_customBannerUrl != null) {
      imageContent = Image.network(
        _customBannerUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildBannerFallback(),
      );
    } else {
      imageContent = Image.network(
        _defaultBannerUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildBannerFallback(),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: imageContent,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: _showChangeBannerOptions,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Ubah Gambar',
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerFallback() {
    return Container(
      color: colorSecondaryContainer,
      child: Center(
        child: Icon(
          Icons.storefront,
          size: 48,
          color: colorOnSecondaryContainer,
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.sourceSerif4(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari sistem kasir?',
          style: GoogleFonts.workSans(color: colorOnSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: colorOutline),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pushAndRemoveAll(const cashierlogin1());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: theme.backgroundColor,

          // Navigation Drawer
          drawer: Drawer(
            width: 320,
            backgroundColor: colorSurfaceContainerLowest,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Store Info Header Card
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 40,
                    bottom: 16,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorOutlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.storeName.isNotEmpty
                              ? widget.storeName
                              : 'Bella Caffee',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.storeLocation.isNotEmpty
                              ? widget.storeLocation
                              : 'Jakarta',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorSecondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Shift: ${widget.shift.isNotEmpty ? widget.shift : 'Pagi'}',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorOnSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Banner Image in Drawer
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 4.0,
                  ),
                  child: _buildBannerWidget(height: 110, borderRadius: 12),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Divider(color: Color(0x33D4C3BE), height: 1),
                ),

                // Drawer Nav Links
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      _buildDrawerNavItem(
                        icon: Icons.calendar_today_outlined,
                        title: 'Shift Staff',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          context.push(
                            StaffShiftScreen(
                              activeShift:
                                  '${widget.shift} Shift: 07:00 - 15:00',
                            ),
                          );
                        },
                      ),
                      _buildDrawerNavItem(
                        icon: Icons.person_outline,
                        title: 'Profil Kasir',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          context.push(
                            CashierProfileScreen(
                              storeName: widget.storeName,
                              storeLocation: widget.storeLocation,
                              shift: widget.shift,
                            ),
                          );
                        },
                      ),
                      _buildDrawerNavItem(
                        icon: Icons.settings_outlined,
                        title: 'Setting',
                        isSelected: false,
                        onTap: () {
                          Navigator.pop(context);
                          context.push(const SettingsScreen());
                        },
                      ),
                    ],
                  ),
                ),

                // Logout Button at Bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: _handleLogout,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colorErrorContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 22, color: colorError),
                          const SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: GoogleFonts.workSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorError,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // App Bar
          appBar: AppBar(
            backgroundColor: colorSurface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.menu, color: colorPrimary, size: 28),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              widget.storeName.isNotEmpty ? widget.storeName : 'BGA Co.',
              style: GoogleFonts.sourceSerif4(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      color: colorPrimary,
                    ),
                    onPressed: _showCartBottomSheet,
                  ),
                  if (_cartTotalItems > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorSecondary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$_cartTotalItems',
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
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: colorPrimary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          floatingActionButton: _currentBottomTab == 1
              ? FloatingActionButton.extended(
                  onPressed: _showCartBottomSheet,
                  backgroundColor: colorPrimary,
                  elevation: 4,
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    'View Cart (${_cartTotalItems})',
                    style: GoogleFonts.workSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: _currentBottomTab == 0
                ? const EditMenuScreen(isTab: true)
                : _currentBottomTab == 1
                ? _buildShopView()
                : _currentBottomTab == 2
                ? _buildCartView()
                : _buildTransactionHistoryView(),
          ),

          // Bottom Navigation Bar (Shop, Discover, Cart)
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: colorSurfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentBottomTab,
              onTap: (index) {
                setState(() {
                  _currentBottomTab = index;
                });
              },
              backgroundColor: colorSurfaceContainerLowest,
              selectedItemColor: colorPrimary,
              unselectedItemColor: colorOnSurfaceVariant,
              selectedLabelStyle: GoogleFonts.workSans(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: GoogleFonts.workSans(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Discover',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_outlined),
                  activeIcon: Icon(Icons.storefront),
                  label: 'Shop',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      if (_cartTotalItems > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: colorSecondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$_cartTotalItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (_cartTotalItems > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: colorSecondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 14,
                              minHeight: 14,
                            ),
                            child: Text(
                              '$_cartTotalItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'Transaction',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopView() {
    List<Map<String, dynamic>> currentList;
    if (_selectedShopCategoryTab < _shopCategoryNames.length) {
      final key = _shopCategoryNames[_selectedShopCategoryTab];
      currentList = _shopCategoryDataMap[key] ?? [];
    } else {
      currentList = _foodMenuItems;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        children: [
          // Cashier Banner
          Container(
            width: double.infinity,
            color: colorPrimary,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              'CASHIER: BELLA GITA A',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tabs (Food, Drink, Snack, Dessert)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colorPrimary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < _shopCategoryNames.length; i++)
                            _buildShopCategoryTab(_shopCategoryNames[i], i),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Menu Items List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final item = currentList[index];
                        return _buildShopMenuItemCard(item);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCategoryTab(String label, int index) {
    final isSelected = _selectedShopCategoryTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedShopCategoryTab = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border(bottom: BorderSide(color: colorPrimary, width: 2))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? colorPrimary : colorOnSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopMenuItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(68, 42, 34, 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image Thumbnail
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorPrimary.withValues(alpha: 0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                item['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colorSurfaceContainerLow,
                  child: Icon(Icons.restaurant, color: colorPrimary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title, Price Badge, Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] as String,
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['priceText'] as String,
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['desc'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    color: colorOnSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Add Button
          InkWell(
            onTap: () {
              _addToCart(item);
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorPrimaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? colorSecondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? colorOnSecondaryContainer
                    : colorOnSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? colorOnSecondaryContainer
                      : colorOnSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color bgColor,
    required Color textColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: bgColor == colorSurfaceContainerLowest
            ? Border.all(color: colorOutlineVariant.withValues(alpha: 0.4))
            : null,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.workSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: textColor.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.sourceSerif4(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorPrimary.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: colorSecondary),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.sourceSerif4(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.workSans(
                fontSize: 11,
                color: colorOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(String orderId, String items, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorSurfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt, size: 20, color: colorSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderId,
                        style: GoogleFonts.workSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: GoogleFonts.workSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header (Your Order)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorPrimary),
                    onPressed: () => setState(() => _currentBottomTab = 1),
                  ),
                  Expanded(
                    child: Text(
                      'Your Order',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),

              // Main Content Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 750;
                  final leftSection = Column(
                    children: [
                      if (_cartItems.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_basket_outlined,
                                size: 64,
                                color: colorOutline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Keranjang Belanja Kosong',
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Silakan tambahkan produk favorit Anda dari Shop.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.workSans(
                                  color: colorOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colorSurfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(68, 42, 34, 0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Thumbnail Image
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: colorSurfaceContainerLow,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child:
                                          item['image'] != null &&
                                              (item['image'] as String)
                                                  .isNotEmpty
                                          ? Image.network(
                                              item['image'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    Icons.restaurant,
                                                    color: colorOutline,
                                                  ),
                                            )
                                          : Icon(
                                              Icons.restaurant,
                                              color: colorOutline,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Item Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'] ?? 'Menu Item',
                                          style: GoogleFonts.sourceSerif4(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: colorPrimary,
                                          ),
                                        ),
                                        if (item['desc'] != null &&
                                            (item['desc'] as String)
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item['desc'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.workSans(
                                              fontSize: 12,
                                              color: colorOnSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Text(
                                          'Rp ${_formatCurrency(item['price'] as int)}',
                                          style: GoogleFonts.workSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: colorSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Quantity Pill Controls (- Qty +)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorSurfaceContainerLow,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: colorPrimary.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if ((item['quantity'] as int) >
                                                  1) {
                                                item['quantity'] =
                                                    (item['quantity'] as int) -
                                                    1;
                                              } else {
                                                _cartItems.removeAt(index);
                                              }
                                            });
                                          },
                                          child: Icon(
                                            Icons.remove,
                                            size: 18,
                                            color: colorPrimary,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            '${item['quantity']}',
                                            style: GoogleFonts.workSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              item['quantity'] =
                                                  (item['quantity'] as int) + 1;
                                            });
                                          },
                                          child: Icon(
                                            Icons.add,
                                            size: 18,
                                            color: colorPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      // Add More Items Button
                      InkWell(
                        onTap: () => setState(() => _currentBottomTab = 1),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorSecondary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: colorSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ADD MORE ITEMS',
                                style: GoogleFonts.workSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: colorSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                  final summarySection = Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorPrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal (${_cartTotalItems} items)',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(_cartSubtotal)}',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tax (10%)',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                color: colorOnSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(_cartTax)}',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorPrimary,
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(_cartTotalAmount)}',
                              style: GoogleFonts.sourceSerif4(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _cartItems.isEmpty
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckoutScreen(
                                          cartItems: List.from(_cartItems),
                                          storeName: widget.storeName,
                                          onOrderCompleted: () {
                                            setState(() {
                                              _cartItems.clear();
                                              _currentBottomTab = 1;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'PROCEED TO CHECKOUT',
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Taxes and shipping calculated at checkout.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.workSans(
                            fontSize: 11,
                            color: colorOnSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: leftSection),
                            const SizedBox(width: 24),
                            Expanded(flex: 5, child: summarySection),
                          ],
                        )
                      : Column(
                          children: [
                            leftSection,
                            const SizedBox(height: 16),
                            summarySection,
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TRANSACTION HISTORY VIEW ====================
  Widget _buildTransactionHistoryView() {
    final filteredTransactions = _transactionHistory.where((tx) {
      final matchesFilter =
          _transactionFilter == 'Semua' ||
          tx['method'].toString().toLowerCase().contains(
            _transactionFilter.toLowerCase(),
          );
      final matchesSearch =
          _transactionSearchQuery.isEmpty ||
          tx['id'].toString().toLowerCase().contains(
            _transactionSearchQuery.toLowerCase(),
          ) ||
          tx['customer'].toString().toLowerCase().contains(
            _transactionSearchQuery.toLowerCase(),
          );
      final matchesDate =
          _selectedTransactionDate == null ||
          tx['date'].toString().contains(
            _formatDateForFilter(_selectedTransactionDate!),
          );
      return matchesFilter && matchesSearch && matchesDate;
    }).toList();

    final totalRevenue = filteredTransactions.fold<int>(
      0,
      (sum, tx) => sum + (tx['total'] as int),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Export Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Riwayat Transaksi',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _exportTransactionsToExcel(filteredTransactions),
                    icon: const Icon(Icons.table_view, size: 18),
                    label: Text(
                      'Export Excel',
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Calendar Date Filter Bar
              _buildDateFilterBar(),
              const SizedBox(height: 16),

              // Search & Filter Bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorOutlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) =>
                          setState(() => _transactionSearchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari ID Transaksi atau Nama Pelanggan...',
                        hintStyle: GoogleFonts.workSans(
                          color: colorOnSurfaceVariant,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(Icons.search, color: colorPrimary),
                        filled: true,
                        fillColor: colorSurfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Semua', 'QRIS', 'Tunai', 'GoPay'].map((
                          filter,
                        ) {
                          final isSelected = _transactionFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                filter,
                                style: GoogleFonts.workSans(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : colorPrimary,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: colorPrimary,
                              backgroundColor: colorSurfaceContainerLow,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _transactionFilter = filter);
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
              const SizedBox(height: 16),

              // Total Revenue Stats Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorPrimary, colorPrimaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(68, 42, 34, 0.15),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTransactionDate != null
                              ? 'Omset Tanggal ${_formatDateForFilter(_selectedTransactionDate!)}'
                              : 'Total Omset Penjualan',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatCurrency(totalRevenue)}',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payments,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Transactions List
              if (filteredTransactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: colorOutline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak Ada Transaksi',
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Belum ada riwayat transaksi yang cocok dengan pencarian Anda.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final tx = filteredTransactions[index];
                    final items = tx['items'] as List;
                    final itemSummary = items
                        .map((i) => '${i['name']} (x${i['qty']})')
                        .join(', ');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: colorSurfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorOutlineVariant.withValues(alpha: 0.3),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(68, 42, 34, 0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _showReceiptDialog(tx),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: ID, Date, Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        tx['id'],
                                        style: GoogleFonts.workSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: colorPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${tx['date']}',
                                        style: GoogleFonts.workSans(
                                          fontSize: 12,
                                          color: colorOnSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tx['status'],
                                      style: GoogleFonts.workSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF166534),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1),
                              ),

                              // Items Summary & Customer
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorSecondaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.receipt_long,
                                      color: colorOnSecondaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itemSummary,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.workSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: colorPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.person_outline,
                                                  size: 14,
                                                  color: colorOnSurfaceVariant,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  tx['customer'],
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 12,
                                                    color:
                                                        colorOnSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.payment,
                                                  size: 14,
                                                  color: colorSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  tx['method'],
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colorSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Rp ${_formatCurrency(tx['total'] as int)}',
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiptDialog(Map<String, dynamic> tx) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt, size: 40, color: colorPrimary),
              const SizedBox(height: 8),
              Text(
                widget.storeName.isNotEmpty ? widget.storeName : 'Bella Caffee',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorPrimary,
                ),
              ),
              Text(
                'Nota Pembayaran Resmi',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  color: colorOnSurfaceVariant,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID Transaksi:',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    tx['id'],
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Waktu:',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    tx['date'],
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pelanggan:',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    tx['customer'],
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Metode:',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    tx['method'],
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorSecondary,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),

              // Items breakdown
              Column(
                children: (tx['items'] as List).map<Widget>((item) {
                  final itemTotal =
                      (item['qty'] as int) * (item['price'] as int);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item['name']} x${item['qty']}',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: colorPrimary,
                          ),
                        ),
                        Text(
                          'Rp ${_formatCurrency(itemTotal)}',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rp ${_formatCurrency(tx['subtotal'] as int)}',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pajak (10%)',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Rp ${_formatCurrency(tx['tax'] as int)}',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                  Text(
                    'Rp ${_formatCurrency(tx['total'] as int)}',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(dContext),
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Cetak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorPrimary,
                        side: BorderSide(color: colorPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Calendar & Date Formatting for Transactions
  String _formatDateForFilter(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickTransactionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTransactionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih Tanggal Transaksi',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorPrimary,
              onPrimary: Colors.white,
              surface: colorSurfaceContainerLowest,
              onSurface: colorPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTransactionDate = picked;
      });
    }
  }

  Widget _buildDateFilterBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorOutlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: colorPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filter Tanggal & Kalender:',
                style: GoogleFonts.workSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickTransactionDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: colorSurfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedTransactionDate != null
                      ? colorSecondary
                      : colorOutlineVariant.withValues(alpha: 0.4),
                  width: _selectedTransactionDate != null ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 18, color: colorSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedTransactionDate != null
                                ? _formatDateForFilter(
                                    _selectedTransactionDate!,
                                  )
                                : 'Ketuk pilih tanggal (Semua Tanggal)',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.workSans(
                              fontSize: 13,
                              fontWeight: _selectedTransactionDate != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: colorPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedTransactionDate != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTransactionDate = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: colorOutlineVariant,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Icon(Icons.arrow_drop_down, color: colorOnSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _exportTransactionsToExcel(List<Map<String, dynamic>> list) {
    final TextEditingController emailController = TextEditingController(
      text: 'owner.bellacaffee@gmail.com',
    );
    bool sendToEmail = true;
    bool saveToGoogleDocs = true;
    bool saveToLocal = true;
    DateTime? modalSelectedDate = _selectedTransactionDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bContext) {
        return StatefulBuilder(
          builder: (stContext, setModalState) {
            final currentFilteredList = _transactionHistory.where((tx) {
              final matchesFilter =
                  _transactionFilter == 'Semua' ||
                  tx['method'].toString().toLowerCase().contains(
                    _transactionFilter.toLowerCase(),
                  );
              final matchesSearch =
                  _transactionSearchQuery.isEmpty ||
                  tx['id'].toString().toLowerCase().contains(
                    _transactionSearchQuery.toLowerCase(),
                  ) ||
                  tx['customer'].toString().toLowerCase().contains(
                    _transactionSearchQuery.toLowerCase(),
                  );
              final matchesDate =
                  modalSelectedDate == null ||
                  tx['date'].toString().contains(
                    _formatDateForFilter(modalSelectedDate!),
                  );
              return matchesFilter && matchesSearch && matchesDate;
            }).toList();

            final currentCount = currentFilteredList.length;
            final currentTotal = currentFilteredList.fold<int>(
              0,
              (sum, tx) => sum + (tx['total'] as int),
            );
            final currentDateStr = modalSelectedDate != null
                ? _formatDateForFilter(modalSelectedDate!)
                : 'Semua_Tanggal';

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(stContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.table_view,
                                color: Color(0xFF166534),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Export & Kirim Excel',
                                  style: GoogleFonts.sourceSerif4(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorPrimary,
                                  ),
                                ),
                                Text(
                                  'Laporan Transaksi Bella Caffee',
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(bContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Calendar Date Selector Header Card inside Modal
                    Text(
                      'Periode / Tanggal Laporan:',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: modalSelectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          helpText: 'Pilih Tanggal Laporan Excel',
                          cancelText: 'Batal',
                          confirmText: 'Pilih',
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: colorPrimary,
                                  onPrimary: Colors.white,
                                  surface: colorSurfaceContainerLowest,
                                  onSurface: colorPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (picked != null) {
                          setModalState(() {
                            modalSelectedDate = picked;
                            _selectedTransactionDate = picked;
                          });
                          setState(() {});
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorSecondary.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorSecondaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.calendar_month,
                                      size: 20,
                                      color: colorOnSecondaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          modalSelectedDate != null
                                              ? _formatDateForFilter(
                                                  modalSelectedDate!,
                                                )
                                              : 'Semua Tanggal (Seluruh Laporan)',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.workSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: colorPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$currentCount Transaksi • Rp ${_formatCurrency(currentTotal)}',
                                          style: GoogleFonts.workSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: colorSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                if (modalSelectedDate != null)
                                  GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        modalSelectedDate = null;
                                        _selectedTransactionDate = null;
                                      });
                                      setState(() {});
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: colorOutlineVariant,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                Icon(
                                  Icons.edit_calendar,
                                  color: colorSecondary,
                                  size: 22,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Email Tujuan
                    Text(
                      'Email Tujuan Laporan:',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: colorPrimary,
                        ),
                        hintText: 'Masukkan alamat email...',
                        filled: true,
                        fillColor: colorSurfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorOutlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Opsi Tujuan Pengiriman
                    Text(
                      'Opsi Integrasi & Pengiriman:',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      value: sendToEmail,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF166534),
                      title: Text(
                        'Kirim Laporan ke Email',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Lampirkan file Excel .xlsx ke email yang diinput',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => sendToEmail = val ?? false);
                      },
                    ),
                    CheckboxListTile(
                      value: saveToGoogleDocs,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF166534),
                      title: Text(
                        'Simpan ke Google Docs / Drive',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Auto-sync spreadsheet ke Google Drive toko',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => saveToGoogleDocs = val ?? false);
                      },
                    ),
                    CheckboxListTile(
                      value: saveToLocal,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: const Color(0xFF166534),
                      title: Text(
                        'Unduh File Excel ke Perangkat',
                        style: GoogleFonts.workSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Simpan file .xlsx di folder Download HP/Perangkat',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => saveToLocal = val ?? false);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(bContext);
                          _showExportSuccessDialog(
                            count: currentCount,
                            total: currentTotal,
                            dateStr: currentDateStr,
                            targetEmail: emailController.text.trim(),
                            sentEmail: sendToEmail,
                            sentGDocs: saveToGoogleDocs,
                            savedLocal: saveToLocal,
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          'KIRIM & EXPORT LAPORAN',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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

  void _showExportSuccessDialog({
    required int count,
    required int total,
    required String dateStr,
    required String targetEmail,
    required bool sentEmail,
    required bool sentGDocs,
    required bool savedLocal,
  }) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF166534),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Export & Pengiriman Berhasil!',
              style: GoogleFonts.sourceSerif4(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'File "Laporan_Transaksi_${dateStr.replaceAll(' ', '_')}.xlsx" ($count data, Total Rp ${_formatCurrency(total)}) telah diproses:',
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 13,
                color: colorOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),

            // Status items
            if (sentEmail)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_read,
                      color: Color(0xFF166534),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dikirim ke: $targetEmail',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (sentGDocs)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_done,
                      color: Color(0xFF0284C7),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Disimpan ke Google Docs & Drive',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (savedLocal)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.file_download_done,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tersimpan di Penyimpanan Lokal (Download)',
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('SELESAI'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
