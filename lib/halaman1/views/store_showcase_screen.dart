import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class StoreShowcaseScreen extends StatefulWidget {
  const StoreShowcaseScreen({super.key});

  @override
  State<StoreShowcaseScreen> createState() => _StoreShowcaseScreenState();
}

class _StoreShowcaseScreenState extends State<StoreShowcaseScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController storeNameC = TextEditingController();
  final TextEditingController storeLocationC = TextEditingController();
  String? selectedShift;

  // Dynamic Color Tokens linked to AppTheme
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorPrimaryContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFF3B3835)
      : const Color(0xFF5D4037);
  Color get colorOnPrimary => Colors.white;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorSecondaryContainer => AppTheme.instance.secondaryContainer;
  Color get colorOnSecondaryContainer => AppTheme.instance.onSecondaryContainer;
  Color get colorSecondaryFixedDim => AppTheme.instance.secondaryColor;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurface => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOutline => AppTheme.instance.outlineColor;
  Color get colorOnSurface => AppTheme.instance.onSurfaceColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;

  @override
  void dispose() {
    storeNameC.dispose();
    storeLocationC.dispose();
    super.dispose();
  }

  Future<void> _showAppLogoSplashAndNavigate({
    required String name,
    required String location,
    required String shift,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: colorSurfaceContainerLowest,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withValues(alpha: 0.35),
                      blurRadius: 32,
                      spreadRadius: 6,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Cartoon Logo Image (Kasir Vintage Frame)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorSecondary.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(color: colorSecondary, width: 4),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/cartoon_logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/images/logobellacashier.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    CircleAvatar(
                                      backgroundColor: colorPrimary,
                                      child: const Icon(
                                        Icons.storefront,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'BGA Co. / Bee Cafe',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$name • $location\nShift $shift',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.workSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3-Second Loading Animation & Progress Bar
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 3),
                      builder: (context, value, child) {
                        final remainingSeconds = (3 * (1.0 - value)).ceil();
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: colorSurfaceContainerLow,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Memuat Aplikasi... (${remainingSeconds > 0 ? remainingSeconds : 1}s)',
                                  style: GoogleFonts.workSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: colorPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss logo splash
      context.push(
        HomeScreen(storeName: name, storeLocation: location, shift: shift),
      );
    }
  }

  void _handleSubmit() {
    final name = storeNameC.text.trim();
    final location = storeLocationC.text.trim();
    final shift = selectedShift;

    if (name.isEmpty || location.isEmpty || shift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap lengkapi semua data toko!',
            style: GoogleFonts.workSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _showAppLogoSplashAndNavigate(
      name: name,
      location: location,
      shift: shift,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return Scaffold(
          backgroundColor: colorBackground,

          // TopAppBar
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: BoxDecoration(
                color: colorSurface,
                border: Border(
                  bottom: BorderSide(
                    color: colorPrimary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu, color: colorOnSurfaceVariant),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.shopping_bag_outlined,
                          color: colorOnSurfaceVariant,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Body Canvas with Clean White Background & Pizza Ingredients Animation
          body: Container(
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorOutlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form Header Lottie Animated Banner (Pizza Ingredients)
                        Center(
                          child: SizedBox(
                            height: 130,
                            child: Lottie.asset(
                              'assets/animation/pizza_ingredients.json',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Lottie.asset(
                                  'assets/animation/cafe.json',
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                          // Nama Toko Field
                          Text(
                            'Nama Toko',
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorPrimary,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: storeNameC,
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              color: colorOnSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Cafe',
                              hintStyle: GoogleFonts.workSans(
                                color: colorOutlineVariant,
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: colorSurfaceContainerLow,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorOutlineVariant,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorPrimary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lokasi Toko Field
                          Text(
                            'Lokasi Toko',
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorPrimary,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: storeLocationC,
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              color: colorOnSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Jakarta',
                              hintStyle: GoogleFonts.workSans(
                                color: colorOutlineVariant,
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: colorSurfaceContainerLow,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorOutlineVariant,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorPrimary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Shift Dropdown Field
                          Text(
                            'Shift',
                            style: GoogleFonts.workSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorPrimary,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedShift,
                            hint: Text(
                              'Pilih shift',
                              style: GoogleFonts.workSans(
                                color: colorOutlineVariant,
                                fontSize: 16,
                              ),
                            ),
                            style: GoogleFonts.workSans(
                              fontSize: 16,
                              color: colorOnSurface,
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: colorPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colorSurfaceContainerLow,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorOutlineVariant,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorPrimary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            items: ['Pagi', 'Siang', 'Malam'].map((shift) {
                              return DropdownMenuItem<String>(
                                value: shift,
                                child: Text(
                                  shift,
                                  style: GoogleFonts.workSans(
                                    color: colorOnSurface,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedShift = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit Button "Kirim"
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorPrimary,
                                foregroundColor: colorOnPrimary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Kirim',
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.7,
                                  color: colorOnPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
