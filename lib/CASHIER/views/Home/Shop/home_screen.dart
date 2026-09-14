import 'dart:async';
import 'dart:typed_data';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/CASHIER/database/database_helper.dart';
import 'package:cashier/CASHIER/models/transaction_model.dart';
import 'package:cashier/CASHIER/services/firebase_auth_service.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/utils/menu_data_store.dart';
import 'package:cashier/CASHIER/utils/transaction_data_store.dart';
import 'package:cashier/CASHIER/utils/user_data_store.dart';
import 'package:cashier/CASHIER/views/Home/Discover/edit_menu_screen.dart';
import 'package:cashier/CASHIER/views/Home/Shift/staff_shift_screen.dart';
import 'package:cashier/CASHIER/views/Home/Transaction/checkout_screen.dart';
import 'package:cashier/CASHIER/views/Home/login.dart';
import 'package:cashier/CASHIER/views/Profile/cashier_profile_screen.dart';
import 'package:cashier/CASHIER/views/setting/settings_screen.dart';
import 'package:cashier/CASHIER/widgets/animated_cartoon_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  final String storeName;
  final String storeLocation;
  final String shift;

  static final ValueNotifier<int> activeTabNotifier = ValueNotifier<int>(1);

  static void switchToTab(int index) {
    activeTabNotifier.value = index;
  }

  const HomeScreen({
    super.key,
    this.storeName = 'Bella Cafe',
    this.storeLocation = 'Jakarta',
    this.shift = 'Pagi',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentBottomTab = 1;

  // Security Lock for Discover Tab (Menu Management)
  bool _isDiscoverUnlocked = false;

  // Shop Category & Data State
  int _selectedShopCategoryTab = 1; // 0: Food, 1: Drink, 2: Snack

  // Transaction History State
  String _transactionFilter = 'Semua';
  String _transactionSearchQuery = '';
  DateTime? _selectedTransactionDate;

  List<Map<String, dynamic>> _transactionHistory = [];
  StreamSubscription<List<TransactionModel>>? _txSubscription;

  @override
  void initState() {
    super.initState();
    HomeScreen.activeTabNotifier.addListener(_onActiveTabChanged);

    // Inisialisasi Sinkronisasi Penuh Firebase Firestore
    UserDataStore.instance.initFromFirebase();
    MenuDataStore.instance.initFromFirebase();
    TransactionDataStore.instance.initialize();

    _transactionHistory = TransactionDataStore.instance.legacyTransactions;
    TransactionDataStore.instance.transactionsNotifier.addListener(
      _onTransactionsDataChanged,
    );
    _subscribeTransactions();
    MenuDataStore.instance.menuDataNotifier.addListener(_onMenuDataChanged);
    MenuDataStore.instance.categoriesNotifier.addListener(_onMenuDataChanged);
  }

  @override
  void dispose() {
    HomeScreen.activeTabNotifier.removeListener(_onActiveTabChanged);
    _txSubscription?.cancel();
    TransactionDataStore.instance.transactionsNotifier.removeListener(
      _onTransactionsDataChanged,
    );
    MenuDataStore.instance.menuDataNotifier.removeListener(_onMenuDataChanged);
    MenuDataStore.instance.categoriesNotifier.removeListener(
      _onMenuDataChanged,
    );
    super.dispose();
  }

  void _onActiveTabChanged() {
    if (mounted && _currentBottomTab != HomeScreen.activeTabNotifier.value) {
      setState(() {
        _currentBottomTab = HomeScreen.activeTabNotifier.value;
      });
      if (_currentBottomTab == 3) {
        _loadTransactionsFromDatabase();
      }
    }
  }

  void _onTransactionsDataChanged() {
    if (mounted) {
      setState(() {
        _transactionHistory = TransactionDataStore.instance.legacyTransactions;
      });
    }
  }

  void _onMenuDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _subscribeTransactions() {
    _txSubscription = DataBaseHelper().streamTransactions().listen(
      (txList) {
        if (mounted && txList.isNotEmpty) {
          setState(() {
            _transactionHistory = txList.map((tx) => tx.toLegacyMap()).toList();
          });
        }
      },
      onError: (e) {
        debugPrint('Error streaming transactions from Firestore: $e');
        _loadTransactionsFromDatabase();
      },
    );
  }

  Future<void> _loadTransactionsFromDatabase() async {
    try {
      final txList = await DataBaseHelper().getAllTransactions();
      if (mounted && txList.isNotEmpty) {
        setState(() {
          _transactionHistory = txList.map((tx) => tx.toLegacyMap()).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  List<String> get _shopCategoryNames => MenuDataStore.instance.categories;
  Map<String, List<Map<String, dynamic>>> get _shopCategoryDataMap =>
      MenuDataStore.instance.categoryDataMap;

  void _addToCart(Map<String, dynamic> item) {
    int pVal = 0;
    if (item['price'] is int) {
      pVal = item['price'] as int;
    } else if (item['price'] is String) {
      final digits = (item['price'] as String).replaceAll(RegExp(r'[^\d]'), '');
      pVal = int.tryParse(digits) ?? 25000;
    }

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
          'price': pVal,
          'quantity': 1,
          'category': item['category'] ?? 'Menu',
          'image': item['image'],
          'desc': item['desc'] ?? '',
          'icon': Icons.restaurant,
        });
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item['name']} ditambahkan ke keranjang (${_cartTotalItems})',
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorPrimary,
        action: SnackBarAction(
          label: 'Lihat Cart 🛒',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _currentBottomTab = 2;
            });
          },
        ),
      ),
    );
  }

  // ==================== DISCOVER SECURITY AUTH DIALOG ====================
  void _showDiscoverAuthDialog() {
    final activeFbUser = FirebaseAuth.instance.currentUser;
    final activeUserData = UserDataStore.instance.userDataNotifier.value;
    final defaultId =
        activeFbUser?.email ??
        activeUserData['email'] ??
        activeUserData['cashierId'] ??
        '';

    final idController = TextEditingController(text: defaultId.toString());
    final passController = TextEditingController();
    bool isObscure = true;
    bool isVerifying = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colorSurfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lock Icon Header with Glow Container
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: colorPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.lock_person_rounded,
                            size: 36,
                            color: colorPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Otorisasi Manajemen Menu',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sourceSerif4(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masukkan ID Akun / Email dan Password untuk membuka akses edit & tambah menu Discover.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.workSans(
                          fontSize: 12.5,
                          color: colorOnSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xFFEF4444,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFDC2626),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: const Color(0xFF991B1B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ID Akun Input Field
                      TextField(
                        controller: idController,
                        enabled: !isVerifying,
                        decoration: InputDecoration(
                          labelText: 'ID Akun / Email Kasir',
                          hintText: 'Contoh: 188889 atau kasir@bgaco.com',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: colorSecondary,
                          ),
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorSecondary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password Input Field
                      TextField(
                        controller: passController,
                        obscureText: isObscure,
                        enabled: !isVerifying,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password Anda',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: colorSecondary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: colorOnSurfaceVariant,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                isObscure = !isObscure;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: colorSurfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorSecondary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Default Hint Card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorSecondaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: colorSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Gunakan Password Akun Firebase Anda',
                                style: GoogleFonts.workSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isVerifying
                            ? null
                            : () => Navigator.pop(dialogCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: colorOutlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.w600,
                            color: colorOnSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                final inputId = idController.text.trim();
                                final inputPass = passController.text;

                                if (inputId.isEmpty || inputPass.isEmpty) {
                                  setDialogState(() {
                                    errorMessage =
                                        'ID Akun dan Password wajib diisi!';
                                  });
                                  return;
                                }

                                setDialogState(() {
                                  isVerifying = true;
                                  errorMessage = null;
                                });

                                bool isAuthSuccess = false;

                                // 1. Verifikasi langsung ke Firebase Authentication
                                try {
                                  final fbResult = await FirebaseAuthService
                                      .instance
                                      .loginUser(
                                        identifier: inputId,
                                        password: inputPass,
                                      );
                                  if (fbResult['success'] == true) {
                                    isAuthSuccess = true;
                                  }
                                } catch (e) {
                                  debugPrint(
                                    'Discover Firebase Auth check error: $e',
                                  );
                                }

                                // 2. Verifikasi dengan Sesi Firebase Aktif saat ini
                                if (!isAuthSuccess && activeFbUser != null) {
                                  final emailMatch =
                                      activeFbUser.email?.toLowerCase() ==
                                      inputId.toLowerCase();
                                  final cashierIdMatch =
                                      activeUserData['cashierId']?.toString() ==
                                      inputId;
                                  final emailStoredMatch =
                                      activeUserData['email']
                                          ?.toString()
                                          .toLowerCase() ==
                                      inputId.toLowerCase();

                                  if (emailMatch ||
                                      cashierIdMatch ||
                                      emailStoredMatch) {
                                    try {
                                      if (activeFbUser.email != null) {
                                        final cred =
                                            EmailAuthProvider.credential(
                                              email: activeFbUser.email!,
                                              password: inputPass,
                                            );
                                        await activeFbUser
                                            .reauthenticateWithCredential(cred);
                                        isAuthSuccess = true;
                                      }
                                    } catch (_) {}
                                  }
                                }

                                // 3. Verifikasi dengan SQLite Database
                                if (!isAuthSuccess) {
                                  try {
                                    final dbUser = await DataBaseHelper()
                                        .loginUser(inputId, inputPass);
                                    if (dbUser != null) {
                                      isAuthSuccess = true;
                                    }
                                  } catch (_) {}
                                }

                                // 4. Verifikasi dengan Local UserDataStore
                                if (!isAuthSuccess) {
                                  final storedPass = activeUserData['password'];
                                  final storedEmail = activeUserData['email'];
                                  final storedCashierId =
                                      activeUserData['cashierId'];
                                  if (storedPass != null &&
                                      storedPass == inputPass) {
                                    if (storedEmail == inputId ||
                                        storedCashierId == inputId ||
                                        inputId == '188889') {
                                      isAuthSuccess = true;
                                    }
                                  }
                                }

                                // 5. Fallback Demo Default Credentials
                                if (!isAuthSuccess) {
                                  final isFallbackValid =
                                      (inputId.toLowerCase() == 'kasir01' &&
                                          inputPass == '123') ||
                                      (inputId.toLowerCase() == 'admin' &&
                                          (inputPass == '123' ||
                                              inputPass == 'admin123')) ||
                                      (inputId.toLowerCase() == 'bella' &&
                                          (inputPass == '123' ||
                                              inputPass == '123456'));
                                  if (isFallbackValid) {
                                    isAuthSuccess = true;
                                  }
                                }

                                if (isAuthSuccess) {
                                  Navigator.pop(dialogCtx);
                                  setState(() {
                                    _isDiscoverUnlocked = true;
                                    _currentBottomTab = 0;
                                  });
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Akses Menu Discover berhasil dibuka! 🔓',
                                        style: GoogleFonts.workSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFF166534),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  setDialogState(() {
                                    isVerifying = false;
                                    errorMessage =
                                        'ID Akun atau Password salah! Akses ditolak.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: colorPrimary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.lock_open, size: 16),
                                  SizedBox(width: 6),
                                  Text('Buka Kunci'),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
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
  final TextEditingController _cartCustomerNameController =
      TextEditingController();
  final TextEditingController _cartTableController = TextEditingController();
  final List<Map<String, dynamic>> _cartItems = [
    {
      'name': 'Rustic Sourdough Loaf',
      'price': 45000,
      'quantity': 1,
      'desc': 'Freshly baked, crusty exterior with a soft, airy crumb.',
      'image': 'assets/images/food_sourdough.jpg',
    },
    {
      'name': 'Butter Croissant',
      'price': 28000,
      'quantity': 2,
      'desc': 'Classic French pastry, flaky and rich with French butter.',
      'image': 'assets/images/food_croissant.jpg',
    },
    {
      'name': 'Berry Tart',
      'price': 55000,
      'quantity': 1,
      'desc':
          'Seasonal mixed berries on a vanilla custard base in a crisp shell.',
      'image': 'assets/images/food_tart.jpg',
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
    return AnimatedCartoonLogo(
      height: height,
      borderRadius: borderRadius,
      imageBytes: _bannerImageBytes,
      customUrl: _customBannerUrl,
      defaultAssetPath: 'assets/animation/cafe.json',
      onChangeRequested: _showChangeBannerOptions,
      showEditButton: true,
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
        return ValueListenableBuilder<String>(
          valueListenable: theme.themePaletteNotifier,
          builder: (context, palette, child) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: theme.backgroundColor,

              // Navigation Drawer
              drawer: Drawer(
                width: 320,
                backgroundColor: colorSurfaceContainerLowest,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Store Info Header Card
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: ValueListenableBuilder<Map<String, dynamic>>(
                          valueListenable:
                              UserDataStore.instance.userDataNotifier,
                          builder: (context, userData, _) {
                            final storeDisplayName =
                                (userData['storeName']?.toString().isNotEmpty ==
                                    true)
                                ? userData['storeName'].toString()
                                : (widget.storeName.isNotEmpty
                                      ? widget.storeName
                                      : 'Bella Cafe');
                            final storeDisplayLocation =
                                (userData['location']?.toString().isNotEmpty ==
                                    true)
                                ? userData['location'].toString()
                                : (widget.storeLocation.isNotEmpty
                                      ? widget.storeLocation
                                      : 'Jakarta');
                            final currentShift =
                                (userData['shift']?.toString().isNotEmpty ==
                                    true)
                                ? userData['shift'].toString()
                                : (widget.shift.isNotEmpty
                                      ? widget.shift
                                      : 'Pagi');
                            final currentCashierName =
                                (userData['cashierName']
                                        ?.toString()
                                        .isNotEmpty ==
                                    true)
                                ? userData['cashierName'].toString()
                                : (userData['accountName']?.toString() ??
                                      'Bella Gita asmara');

                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorSurfaceContainerLow,
                                    colorSecondaryContainer.withValues(
                                      alpha: 0.35,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: colorSecondary.withValues(alpha: 0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorSecondary.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                          color: colorSecondary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorSecondary.withValues(
                                                alpha: 0.35,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.local_cafe_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    storeDisplayName,
                                                    style:
                                                        GoogleFonts.sourceSerif4(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: colorPrimary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const Text(
                                                  '✨',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on_rounded,
                                                  size: 13,
                                                  color: colorSecondary,
                                                ),
                                                const SizedBox(width: 3),
                                                Expanded(
                                                  child: Text(
                                                    storeDisplayLocation,
                                                    style: GoogleFonts.workSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: colorSecondary,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorSurfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colorOutlineVariant.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              '☀️',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Shift: $currentShift',
                                              style: GoogleFonts.workSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: colorPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF10B981),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              currentCashierName,
                                              style: GoogleFonts.workSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: colorOnSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Mascot Animated Cartoon Logo Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 2.0,
                        ),
                        child: _buildBannerWidget(
                          height: 105,
                          borderRadius: 14,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Navigation Menu List (Only Shift, Profile, Pengaturan)
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          children: [
                            _buildDrawerNavItem(
                              icon: Icons.calendar_today_outlined,
                              title: 'Shift',
                              subtitle: 'Jadwal kerja & pergantian shift',
                              isSelected: false,
                              emoji: '⏰',
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
                            const SizedBox(height: 6),
                            _buildDrawerNavItem(
                              icon: Icons.person_outline,
                              title: 'Profile',
                              subtitle: 'Data cabang & akun kasir aktif',
                              isSelected: false,
                              emoji: '👤',
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
                            const SizedBox(height: 6),
                            _buildDrawerNavItem(
                              icon: Icons.settings_outlined,
                              title: 'Pengaturan',
                              subtitle: 'Tema warna, tampilan, & sistem',
                              isSelected: false,
                              emoji: '⚙️',
                              onTap: () {
                                Navigator.pop(context);
                                context.push(const SettingsScreen());
                              },
                            ),
                          ],
                        ),
                      ),

                      // Logout & Footer Section
                      Container(
                        decoration: BoxDecoration(
                          color: colorSurfaceContainerLowest,
                          border: Border(
                            top: BorderSide(
                              color: colorOutlineVariant.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _CuteLogoutButton(
                              onTap: _handleLogout,
                              errorColor: colorError,
                              errorContainerColor: colorErrorContainer,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'BGA Co. Cashier • v1.2.4',
                              style: GoogleFonts.workSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colorOnSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                title: null,
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
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: colorPrimary,
                    ),
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
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
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
                    ? EditMenuScreen(
                        isTab: true,
                        categoryNames: _shopCategoryNames,
                        categoryDataMap: _shopCategoryDataMap,
                        onLockRequested: () {
                          setState(() {
                            _isDiscoverUnlocked = false;
                            _currentBottomTab = 1;
                          });
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Akses Manajemen Menu (Discover) telah dikunci kembali 🔒',
                                style: GoogleFonts.workSans(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: colorPrimary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        onMenuUpdated: () {
                          setState(() {});
                        },
                      )
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
                    if (index == 0 && !_isDiscoverUnlocked) {
                      _showDiscoverAuthDialog();
                    } else {
                      setState(() {
                        _currentBottomTab = index;
                      });
                    }
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
                    BottomNavigationBarItem(
                      icon: Icon(
                        _isDiscoverUnlocked
                            ? Icons.explore_outlined
                            : Icons.lock_outline,
                      ),
                      activeIcon: Icon(
                        _isDiscoverUnlocked ? Icons.explore : Icons.lock,
                      ),
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
      },
    );
  }

  Widget _buildShopView() {
    List<Map<String, dynamic>> currentList;
    if (_selectedShopCategoryTab < _shopCategoryNames.length) {
      final key = _shopCategoryNames[_selectedShopCategoryTab];
      currentList = _shopCategoryDataMap[key] ?? [];
    } else {
      currentList = [];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        children: [
          // Cashier Banner
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: UserDataStore.instance.userDataNotifier,
            builder: (context, userData, _) {
              final activeCashier =
                  userData['cashierName'] ??
                  userData['name'] ??
                  userData['accountName'] ??
                  'Bella Saputra';
              return Container(
                width: double.infinity,
                color: colorPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text(
                  'CASHIER: ${activeCashier.toString().toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tabs (Food, Drink, Snack, Dessert, & new dynamic tabs)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colorPrimary.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (int i = 0; i < _shopCategoryNames.length; i++)
                              _buildShopCategoryTab(_shopCategoryNames[i], i),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Menu Items List
                    if (currentList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'Belum ada menu di kategori ini.\nSilakan tambahkan menu melalui tab Discover.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.workSans(
                              color: colorOnSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
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
    return InkWell(
      onTap: () {
        setState(() {
          _selectedShopCategoryTab = index;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              child: _buildProductThumbnail(
                item['image'],
                width: 80,
                height: 80,
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
                        item['priceText']?.toString() ??
                            (item['price'] is int
                                ? 'Rp ${(item['price'] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
                                : item['price']?.toString() ?? 'Rp 0'),
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

  Widget _buildProductThumbnail(
    dynamic imageSource, {
    double width = 80,
    double height = 80,
  }) {
    if (imageSource is Uint8List) {
      return Image.memory(
        imageSource,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else if (imageSource is String && imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildAssetWithFallback(imageSource, width: width, height: height),
      );
    } else if (imageSource is String && imageSource.isNotEmpty) {
      return Image.asset(
        imageSource,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildAssetWithFallback(imageSource, width: width, height: height),
      );
    }
    return _buildProductFallback(width: width, height: height);
  }

  Widget _buildAssetWithFallback(
    String path, {
    double width = 80,
    double height = 80,
  }) {
    String fallbackAsset = 'assets/images/sandwich.jpg';
    if (path.contains('donat')) {
      fallbackAsset = 'assets/images/snack_donatkentang.jpg';
    } else if (path.contains('pisang')) {
      fallbackAsset = 'assets/images/snack_pisanggoreng.jpg';
    } else if (path.contains('tahu')) {
      fallbackAsset = 'assets/images/snack_tahucabegaram.jpg';
    } else if (path.contains('kebab')) {
      fallbackAsset = 'assets/images/snack_kebab.jpg';
    } else if (path.contains('bakwan')) {
      fallbackAsset = 'assets/images/snack_bakwan.jpg';
    } else if (path.contains('jamur')) {
      fallbackAsset = 'assets/images/snack_jamur.jpg';
    } else if (path.contains('cimol')) {
      fallbackAsset = 'assets/images/snack_cimol.png';
    } else if (path.contains('kentang')) {
      fallbackAsset = 'assets/images/snack_kentang.jpg';
    } else if (path.contains('drink') ||
        path.contains('latte') ||
        path.contains('tea') ||
        path.contains('citrus') ||
        path.contains('chocolate')) {
      fallbackAsset = 'assets/images/ice latte.jpg';
    } else if (path.contains('dessert') ||
        path.contains('cheesecake') ||
        path.contains('tiramisu')) {
      fallbackAsset = 'assets/images/caffee1.webp';
    }
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          _buildProductFallback(width: width, height: height),
    );
  }

  Widget _buildProductFallback({double width = 80, double height = 80}) {
    return Container(
      width: width,
      height: height,
      color: colorSurfaceContainerLow,
      child: Icon(Icons.restaurant, size: width * 0.45, color: colorPrimary),
    );
  }

  Widget _buildDrawerNavItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    String emoji = '✨',
  }) {
    return _CuteDrawerNavItem(
      icon: icon,
      title: title,
      subtitle: subtitle,
      isSelected: isSelected,
      onTap: onTap,
      emoji: emoji,
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

              // Input Card Customer & Table
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Column(
                  children: [
                    // Field 1: Customer
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorSecondaryContainer.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: colorSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CUSTOMER',
                                  style: GoogleFonts.workSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                TextField(
                                  controller: _cartCustomerNameController,
                                  style: GoogleFonts.workSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText:
                                        'Customer name (e.g. Kak Bella)...',
                                    hintStyle: GoogleFonts.workSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: colorOnSurfaceVariant.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                          if (_cartCustomerNameController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: colorOnSurfaceVariant,
                              onPressed: () {
                                setState(() {
                                  _cartCustomerNameController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colorOutline.withValues(alpha: 0.15),
                    ),

                    // Field 2: Table (dibawah Customer)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorSecondaryContainer.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.table_restaurant_outlined,
                              color: colorSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TABLE',
                                  style: GoogleFonts.workSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: colorOnSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                TextField(
                                  controller: _cartTableController,
                                  style: GoogleFonts.workSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colorPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    hintText:
                                        'Table / Meja (e.g. Table 04 / Takeaway)...',
                                    hintStyle: GoogleFonts.workSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                      color: colorOnSurfaceVariant.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                          if (_cartTableController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: colorOnSurfaceVariant,
                              onPressed: () {
                                setState(() {
                                  _cartTableController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
                                      child: _buildProductThumbnail(
                                        item['image'],
                                        width: 80,
                                        height: 80,
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
                                        builder: (context) {
                                          final buyerName =
                                              _cartCustomerNameController.text
                                                  .trim()
                                                  .isEmpty
                                              ? 'Pelanggan Umum'
                                              : _cartCustomerNameController.text
                                                    .trim();
                                          final tableNo =
                                              _cartTableController.text
                                                  .trim()
                                                  .isEmpty
                                              ? '-'
                                              : _cartTableController.text
                                                    .trim();
                                          final activeStore =
                                              UserDataStore
                                                      .instance
                                                      .userDataNotifier
                                                      .value['storeName']
                                                  as String? ??
                                              widget.storeName;
                                          return CheckoutScreen(
                                            cartItems: List.from(_cartItems),
                                            storeName: activeStore,
                                            customerName: buyerName,
                                            tableNumber: tableNo,
                                            onOrderCompleted: () {
                                              setState(() {
                                                _cartItems.clear();
                                                _cartCustomerNameController
                                                    .clear();
                                                _cartTableController.clear();
                                                _currentBottomTab = 3;
                                              });
                                              _loadTransactionsFromDatabase();
                                            },
                                          );
                                        },
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
      final methodStr = tx['method']?.toString().toLowerCase() ?? '';
      bool matchesFilter = _transactionFilter == 'Semua';
      if (!matchesFilter) {
        if (_transactionFilter == 'QRIS') {
          matchesFilter =
              methodStr.contains('qris') || methodStr.contains('wallet');
        } else if (_transactionFilter == 'Tunai') {
          matchesFilter =
              methodStr.contains('tunai') || methodStr.contains('cash');
        } else if (_transactionFilter == 'GoPay') {
          matchesFilter = methodStr.contains('gopay');
        } else {
          matchesFilter = methodStr.contains(_transactionFilter.toLowerCase());
        }
      }

      final query = _transactionSearchQuery.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          (tx['id']?.toString().toLowerCase().contains(query) ?? false) ||
          (tx['customer']?.toString().toLowerCase().contains(query) ?? false) ||
          (tx['cashier']?.toString().toLowerCase().contains(query) ?? false);

      final matchesDate =
          _selectedTransactionDate == null ||
          _isSameDate(tx['date']?.toString() ?? '', _selectedTransactionDate!);
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
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          tx['id'],
                                          style: GoogleFonts.workSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: colorPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '• ${tx['date']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.workSans(
                                              fontSize: 11,
                                              color: colorOnSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                                                  Icons.badge_outlined,
                                                  size: 14,
                                                  color: colorSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Cashier: ${tx['cashier'] ?? UserDataStore.instance.userDataNotifier.value['cashierName'] ?? UserDataStore.instance.userDataNotifier.value['name'] ?? 'Bella Saputra'}',
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: colorSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
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
                UserDataStore.instance.userDataNotifier.value['storeName'] ??
                    (widget.storeName.isNotEmpty
                        ? widget.storeName
                        : 'Kingdom Cafe'),
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
                    'Toko / Outlet:',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    tx['storeName'] ??
                        UserDataStore
                            .instance
                            .userDataNotifier
                            .value['storeName'] ??
                        widget.storeName,
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
                    'ID:',
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
                    'Cashier:',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  Text(
                    tx['cashier'] ??
                        UserDataStore
                            .instance
                            .userDataNotifier
                            .value['cashierName'] ??
                        UserDataStore.instance.userDataNotifier.value['name'] ??
                        'Bella Saputra',
                    style: GoogleFonts.workSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorSecondary,
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(dContext);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Struk ${tx['id']} berhasil dicetak ke printer POS!',
                              style: GoogleFonts.workSans(color: Colors.white),
                            ),
                            backgroundColor: colorSecondary,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print_outlined, size: 16),
                      label: const Text('Cetak Struk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dContext),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorOutline,
                        side: BorderSide(color: colorOutlineVariant),
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

  bool _isSameDate(String txDateStr, DateTime targetDate) {
    if (txDateStr.isEmpty) return false;
    final formattedFilter = _formatDateForFilter(targetDate);
    if (txDateStr.toLowerCase().contains(formattedFilter.toLowerCase())) {
      return true;
    }
    const monthsEng = [
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
    const monthsId = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final dayStr = targetDate.day.toString();
    final dayPad = targetDate.day.toString().padLeft(2, '0');
    final monthEng = monthsEng[targetDate.month - 1];
    final monthId = monthsId[targetDate.month - 1];
    final yearStr = targetDate.year.toString();
    final monthPad = targetDate.month.toString().padLeft(2, '0');

    // 1. Check English abbreviations e.g. "11 Sep 2026"
    if (txDateStr.contains('$dayStr $monthEng $yearStr') ||
        txDateStr.contains('$dayPad $monthEng $yearStr')) {
      return true;
    }
    // 2. Check Indonesian abbreviations e.g. "11 Mei 2026"
    if (txDateStr.contains('$dayStr $monthId $yearStr') ||
        txDateStr.contains('$dayPad $monthId $yearStr')) {
      return true;
    }
    // 3. Check ISO format e.g. "2026-09-11"
    if (txDateStr.contains('$yearStr-$monthPad-$dayPad')) {
      return true;
    }
    // 4. Check slash / dash format e.g. "11/09/2026" or "11-09-2026"
    if (txDateStr.contains('$dayPad/$monthPad/$yearStr') ||
        txDateStr.contains('$dayPad-$monthPad-$yearStr')) {
      return true;
    }

    return false;
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
    final now = DateTime.now();
    final isTodaySelected =
        _selectedTransactionDate != null &&
        _selectedTransactionDate!.year == now.year &&
        _selectedTransactionDate!.month == now.month &&
        _selectedTransactionDate!.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterdaySelected =
        _selectedTransactionDate != null &&
        _selectedTransactionDate!.year == yesterday.year &&
        _selectedTransactionDate!.month == yesterday.month &&
        _selectedTransactionDate!.day == yesterday.day;

    final isAllSelected = _selectedTransactionDate == null;

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

          // Quick Date Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickDateChip(
                  label: 'Semua Tanggal',
                  isSelected: isAllSelected,
                  onTap: () {
                    setState(() {
                      _selectedTransactionDate = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickDateChip(
                  label: 'Hari Ini',
                  isSelected: isTodaySelected,
                  onTap: () {
                    setState(() {
                      _selectedTransactionDate = DateTime(
                        now.year,
                        now.month,
                        now.day,
                      );
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildQuickDateChip(
                  label: 'Kemarin',
                  isSelected: isYesterdaySelected,
                  onTap: () {
                    setState(() {
                      _selectedTransactionDate = DateTime(
                        yesterday.year,
                        yesterday.month,
                        yesterday.day,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Calendar Custom Date Picker Tile
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
                                : 'Ketuk pilih tanggal spesifik dari kalender...',
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

  Widget _buildQuickDateChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorPrimary : colorSurfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorPrimary
                : colorOutlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : colorPrimary,
          ),
        ),
      ),
    );
  }

  void _exportTransactionsToExcel(List<Map<String, dynamic>> list) {
    final TextEditingController emailController = TextEditingController(
      text: 'owner.bellacafe@gmail.com',
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
                  _isSameDate(tx['date'].toString(), modalSelectedDate!);
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
                                  'Laporan Transaksi Bella Cafe',
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

// ==================== CUTE ANIMATED DRAWER WIDGETS ====================
class _CuteDrawerNavItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final String emoji;

  const _CuteDrawerNavItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.emoji = '✨',
  });

  @override
  State<_CuteDrawerNavItem> createState() => _CuteDrawerNavItemState();
}

class _CuteDrawerNavItemState extends State<_CuteDrawerNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _controller.reverse();
        },
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? theme.secondaryContainer
                    : _isHovered
                    ? theme.secondaryContainer.withValues(alpha: 0.35)
                    : theme.surfaceContainerLow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected
                      ? theme.secondaryColor.withValues(alpha: 0.6)
                      : _isHovered
                      ? theme.secondaryColor.withValues(alpha: 0.3)
                      : theme.outlineVariant.withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: _isHovered || widget.isSelected
                    ? [
                        BoxShadow(
                          color: theme.secondaryColor.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? theme.secondaryColor
                          : theme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isSelected
                            ? Colors.transparent
                            : theme.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isSelected
                          ? Colors.white
                          : theme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.workSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: widget.isSelected
                                ? theme.onSecondaryContainer
                                : theme.primaryColor,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: GoogleFonts.workSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: theme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: widget.isSelected
                        ? theme.secondaryColor
                        : theme.outlineColor.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CuteLogoutButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color errorColor;
  final Color errorContainerColor;

  const _CuteLogoutButton({
    required this.onTap,
    required this.errorColor,
    required this.errorContainerColor,
  });

  @override
  State<_CuteLogoutButton> createState() => _CuteLogoutButtonState();
}

class _CuteLogoutButtonState extends State<_CuteLogoutButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.errorColor.withValues(alpha: 0.15)
                  : widget.errorContainerColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.errorColor.withValues(
                  alpha: _isHovered ? 0.5 : 0.2,
                ),
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.errorColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _isHovered ? -0.08 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.logout, size: 22, color: widget.errorColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Logout',
                    style: GoogleFonts.workSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.errorColor,
                    ),
                  ),
                ),
                Text(
                  _isHovered ? '👋✨' : '🐾',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
