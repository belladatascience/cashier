import 'dart:typed_data';

import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditMenuScreen extends StatefulWidget {
  final String cashierName;
  final bool isTab;

  const EditMenuScreen({
    super.key,
    this.cashierName = 'Bella gita a',
    this.isTab = false,
  });

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  int _selectedTab = 0; // 0: Food, 1: Drink, 2: Snack
  final ImagePicker _picker = ImagePicker();

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
  Color get colorSurfaceVariant => AppTheme.instance.surfaceVariant;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOutline => AppTheme.instance.outlineColor;
  Color get colorOnSurface => AppTheme.instance.onSurfaceColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorTertiaryFixed => AppTheme.instance.isDarkMode
      ? const Color(0xFF32302D)
      : const Color(0xFFE2E6BF);
  Color get colorOnTertiaryFixed => AppTheme.instance.isDarkMode
      ? const Color(0xFFF0BD8B)
      : const Color(0xFF1A1D06);

  // Menu items state with dynamic image types (String URL or Uint8List bytes)
  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'Sourdough Loaf',
      'price': 'Rp 8.500',
      'desc':
          'Classic artisanal loaf, naturally leavened with a dark, crackly crust and chewy crumb.',
      'image':
          'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Butter Croissant',
      'price': 'Rp 4.250',
      'desc':
          'Traditional French pastry with shattered, buttery layers. Baked fresh daily.',
      'image':
          'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Berry Tart',
      'price': 'Rp 12.000',
      'desc':
          'Seasonal mixed berries on a bed of vanilla pastry cream in a sweet crust.',
      'image':
          'https://images.unsplash.com/photo-1519869325930-281384150729?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Avocado Toast',
      'price': 'Rp 9.500',
      'desc':
          'Mashed Hass avocado with lemon, chili flakes, and sea salt on thick-cut toast.',
      'image':
          'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Pain au Chocolat',
      'price': 'Rp 4.750',
      'desc':
          'Flaky, buttery dough rolled around two batons of semi-sweet dark chocolate.',
      'image':
          'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?auto=format&fit=crop&w=300&q=80',
    },
  ];

  final List<Map<String, dynamic>> _drinkItems = [
    {
      'name': 'Espresso Single',
      'price': 'Rp 18.000',
      'desc':
          'Rich and bold shot extracted from dark roast house espresso blend.',
      'image':
          'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Iced Caffe Latte',
      'price': 'Rp 28.000',
      'desc':
          'Smooth espresso paired with fresh cold milk and subtle caramel notes.',
      'image':
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Matcha Latte',
      'price': 'Rp 32.000',
      'desc': 'Ceremonial grade Japanese Uji matcha steamed with creamy milk.',
      'image':
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    },
  ];

  final List<Map<String, dynamic>> _snackItems = [
    {
      'name': 'Choco Chip Cookie',
      'price': 'Rp 15.000',
      'desc':
          'Soft-baked Belgian chocolate chunk cookie with a pinch of sea salt.',
      'image':
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Almond Muffin',
      'price': 'Rp 18.000',
      'desc':
          'Fluffy golden muffin filled with almond paste and toasted flakes.',
      'image':
          'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&w=300&q=80',
    },
  ];

  final List<Map<String, dynamic>> _newItems = [
    {
      'name': 'Sparkling Citrus Water',
      'price': 'Rp 25.000',
      'desc': 'Crisp sparkling water served with fresh lime and lemon slices.',
      'image':
          'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Artisan Matcha Latte',
      'price': 'Rp 35.000',
      'desc': 'Premium ceremonial grade matcha whisked with creamy milk.',
      'image':
          'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=300&q=80',
    },
  ];

  final List<Map<String, dynamic>> _dessertItems = [
    {
      'name': 'Berry Cheesecake',
      'price': 'Rp 28.000',
      'desc':
          'Creamy New York style cheesecake topped with fresh berry compote.',
      'image':
          'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?auto=format&fit=crop&w=300&q=80',
    },
    {
      'name': 'Tiramisu Cup',
      'price': 'Rp 30.000',
      'desc':
          'Classic Italian dessert with espresso-soaked ladyfingers and mascarpone.',
      'image':
          'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?auto=format&fit=crop&w=300&q=80',
    },
  ];

  final List<String> _categoryNames = ['Food', 'Drink', 'Snack', 'Dessert'];
  late final Map<String, List<Map<String, dynamic>>> _categoryDataMap = {
    'Food': _foodItems,
    'Drink': _drinkItems,
    'Snack': _snackItems,
    'Dessert': _dessertItems,
  };

  List<Map<String, dynamic>> get _currentItems {
    if (_selectedTab < _categoryNames.length) {
      final key = _categoryNames[_selectedTab];
      return _categoryDataMap[key] ?? [];
    }
    return _foodItems;
  }

  Future<dynamic> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return await pickedFile.readAsBytes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  void _showImagePickerOptions({
    required BuildContext context,
    required Function(dynamic newImage) onImageSelected,
  }) {
    final urlC = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: colorSurfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                  'Pilih Gambar Menu',
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
                  onTap: () async {
                    Navigator.pop(ctx);
                    final img = await _pickImage(ImageSource.gallery);
                    if (img != null) {
                      onImageSelected(img);
                    }
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
                  onTap: () async {
                    Navigator.pop(ctx);
                    final img = await _pickImage(ImageSource.camera);
                    if (img != null) {
                      onImageSelected(img);
                    }
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
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: colorSurfaceContainerLowest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Input URL Gambar',
                          style: GoogleFonts.sourceSerif4(
                            color: colorPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: TextField(
                          controller: urlC,
                          decoration: const InputDecoration(
                            hintText: 'https://images.unsplash.com/...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.workSans(color: colorOutline),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (urlC.text.trim().isNotEmpty) {
                                onImageSelected(urlC.text.trim());
                              }
                              Navigator.pop(dCtx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrimary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Simpan',
                              style: GoogleFonts.workSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItemImage(
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
            _buildImageFallback(width: width, height: height),
      );
    } else {
      return _buildImageFallback(width: width, height: height);
    }
  }

  Widget _buildImageFallback({double width = 80, double height = 80}) {
    return Container(
      width: width,
      height: height,
      color: colorSurfaceVariant,
      child: Icon(Icons.restaurant, size: width * 0.45, color: colorPrimary),
    );
  }

  void _showEditDialog(int index) {
    final item = _currentItems[index];
    final nameC = TextEditingController(text: item['name']?.toString() ?? '');
    final priceC = TextEditingController(text: item['price']?.toString() ?? '');
    final descC = TextEditingController(text: item['desc']?.toString() ?? '');
    dynamic tempImage = item['image'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: colorSurfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Edit Menu Item',
              style: GoogleFonts.sourceSerif4(
                color: colorPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Preview & Edit Button
                  GestureDetector(
                    onTap: () {
                      _showImagePickerOptions(
                        context: context,
                        onImageSelected: (newImg) {
                          setDialogState(() {
                            tempImage = newImg;
                          });
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorSecondary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _buildMenuItemImage(
                              tempImage,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ketuk foto untuk mengganti gambar menu',
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameC,
                    style: GoogleFonts.workSans(color: colorOnSurface),
                    decoration: InputDecoration(
                      labelText: 'Nama Menu',
                      labelStyle: GoogleFonts.workSans(color: colorOutline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceC,
                    style: GoogleFonts.workSans(color: colorOnSurface),
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      labelStyle: GoogleFonts.workSans(color: colorOutline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descC,
                    maxLines: 3,
                    style: GoogleFonts.workSans(color: colorOnSurface),
                    decoration: InputDecoration(
                      labelText: 'Deskripsi',
                      labelStyle: GoogleFonts.workSans(color: colorOutline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
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
                  setState(() {
                    _currentItems[index]['name'] = nameC.text;
                    _currentItems[index]['price'] = priceC.text;
                    _currentItems[index]['desc'] = descC.text;
                    _currentItems[index]['image'] = tempImage;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Menu ${nameC.text} berhasil diperbarui!'),
                      backgroundColor: colorSecondary,
                    ),
                  );
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
          );
        },
      ),
    );
  }

  void _showNewMenuDialog() {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final descC = TextEditingController();
    dynamic tempImage =
        'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: colorSurfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Tambah Menu Baru',
              style: GoogleFonts.sourceSerif4(
                color: colorPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image Selection
                  GestureDetector(
                    onTap: () {
                      _showImagePickerOptions(
                        context: context,
                        onImageSelected: (newImg) {
                          setDialogState(() {
                            tempImage = newImg;
                          });
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorSecondary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _buildMenuItemImage(
                              tempImage,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ketuk foto untuk memilih gambar menu',
                    style: GoogleFonts.workSans(
                      fontSize: 11,
                      color: colorOnSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameC,
                    style: GoogleFonts.workSans(color: colorOnSurface),
                    decoration: InputDecoration(
                      labelText: 'Nama Menu',
                      labelStyle: GoogleFonts.workSans(color: colorOutline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceC,
                    style: GoogleFonts.workSans(color: colorOnSurface),
                    decoration: InputDecoration(
                      labelText: 'Harga (Contoh: Rp 10.000)',
                      labelStyle: GoogleFonts.workSans(color: colorOutline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descC,
                    maxLines: 3,
                    style: GoogleFonts.workSans(color: colorOnSurface),
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Singkat',
                      labelStyle: GoogleFonts.workSans(color: colorOutline),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
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
                  if (nameC.text.isNotEmpty && priceC.text.isNotEmpty) {
                    setState(() {
                      _currentItems.add({
                        'name': nameC.text,
                        'price': priceC.text,
                        'desc': descC.text,
                        'image': tempImage,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Menu ${nameC.text} berhasil ditambahkan!',
                        ),
                        backgroundColor: colorSecondary,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorPrimary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Tambah',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
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
          backgroundColor: colorSurface,

          // Top App Bar
          appBar: widget.isTab
              ? null
              : AppBar(
                  backgroundColor: colorSurface,
                  elevation: 0,
                  leading: Navigator.canPop(context)
                      ? IconButton(
                          icon: Icon(Icons.arrow_back, color: colorPrimary),
                          onPressed: () => Navigator.pop(context),
                        )
                      : null,
                  title: Text(
                    'BGA Co.',
                    style: GoogleFonts.sourceSerif4(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorPrimary,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.shopping_bag_outlined,
                        color: colorOnSurfaceVariant,
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showNewMenuDialog,
            backgroundColor: colorPrimary,
            elevation: 4,
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'New Menu',
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ),

          body: Column(
            children: [
              // Cashier Banner
              Container(
                width: double.infinity,
                color: colorPrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text(
                  'CASHIER: ${widget.cashierName.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.workSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),

              // Main Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          // Tabs (Food, Drink, Snack, + New Tab)
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0x1A442A22),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (
                                    int i = 0;
                                    i < _categoryNames.length;
                                    i++
                                  )
                                    _buildTabItem(
                                      title: _categoryNames[i],
                                      index: i,
                                    ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: _showNewTabDialog,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorPrimary.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: colorPrimary.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: 16,
                                            color: colorPrimary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'New Tab',
                                            style: GoogleFonts.workSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: colorPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Menu Items List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _currentItems.length,
                            itemBuilder: (context, index) {
                              final item = _currentItems[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
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
                                  children: [
                                    // Item Image (Clickable to change image)
                                    GestureDetector(
                                      onTap: () => _showEditDialog(index),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: colorPrimary.withValues(
                                              alpha: 0.1,
                                            ),
                                          ),
                                          color: colorSurfaceVariant,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: _buildMenuItemImage(
                                            item['image'],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Item Text (Title, Price, Description)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['name']!.toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      GoogleFonts.sourceSerif4(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: colorOnSurface,
                                                      ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: colorSecondary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  item['price']!.toString(),
                                                  style: GoogleFonts.workSans(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorSecondary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['desc']!.toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.workSans(
                                              fontSize: 13,
                                              color: colorOnSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Edit Button Action
                                    InkWell(
                                      onTap: () => _showEditDialog(index),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: colorPrimaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          size: 18,
                                          color: colorOnPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: widget.isTab
              ? null
              : Container(
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
                    currentIndex: 0,
                    onTap: (index) {
                      if (index == 1 || index == 2) {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
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
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.explore_outlined),
                        activeIcon: Icon(Icons.explore),
                        label: 'Discover',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.storefront_outlined),
                        activeIcon: Icon(Icons.storefront),
                        label: 'Shop',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart_outlined),
                        activeIcon: Icon(Icons.shopping_cart),
                        label: 'Cart',
                      ),
                      BottomNavigationBarItem(
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

  void _showNewTabDialog() {
    final nameC = TextEditingController();
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tambah Tab Kategori Baru',
          style: GoogleFonts.sourceSerif4(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameC,
          autofocus: true,
          style: GoogleFonts.workSans(color: colorOnSurface),
          decoration: InputDecoration(
            labelText: 'Nama Kategori',
            hintText: 'Contoh: Dessert, Pastry, Breakfast',
            labelStyle: GoogleFonts.workSans(color: colorOutline),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: colorOutline),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final catName = nameC.text.trim();
              if (catName.isNotEmpty) {
                setState(() {
                  if (!_categoryNames.contains(catName)) {
                    _categoryNames.add(catName);
                    _categoryDataMap[catName] = [];
                  }
                  _selectedTab = _categoryNames.indexOf(catName);
                });
                Navigator.pop(dContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kategori "$catName" berhasil ditambahkan!'),
                    backgroundColor: colorSecondary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Tambah',
              style: GoogleFonts.workSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTabDialog(int index) {
    final oldName = _categoryNames[index];
    final editC = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Nama Tab Kategori',
          style: GoogleFonts.sourceSerif4(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: editC,
          autofocus: true,
          style: GoogleFonts.workSans(color: colorOnSurface),
          decoration: const InputDecoration(
            labelText: 'Nama Kategori',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          if (_categoryNames.length > 1)
            TextButton(
              onPressed: () {
                Navigator.pop(dContext);
                setState(() {
                  _categoryNames.removeAt(index);
                  _categoryDataMap.remove(oldName);
                  if (_selectedTab >= _categoryNames.length) {
                    _selectedTab = _categoryNames.length - 1;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kategori "$oldName" berhasil dihapus'),
                    backgroundColor: const Color(0xFFBA1A1A),
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.workSans(color: const Color(0xFFBA1A1A)),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: Text(
              'Batal',
              style: GoogleFonts.workSans(color: colorOutline),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = editC.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                setState(() {
                  _categoryNames[index] = newName;
                  final items = _categoryDataMap.remove(oldName) ?? [];
                  _categoryDataMap[newName] = items;
                });
                Navigator.pop(dContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Nama kategori diubah menjadi "$newName"'),
                    backgroundColor: colorSecondary,
                  ),
                );
              } else {
                Navigator.pop(dContext);
              }
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

  Widget _buildTabItem({required String title, required int index}) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      onLongPress: () => _showEditTabDialog(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(bottom: BorderSide(color: colorPrimary, width: 2))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? colorPrimary : colorOnSurfaceVariant,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showEditTabDialog(index),
                child: Icon(Icons.edit_outlined, size: 14, color: colorPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
