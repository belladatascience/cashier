import 'dart:math';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  late AnimationController _particleController;
  final List<_Particle> _particles = [];
  final Random _random = Random();

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
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Generate random particles
    for (int i = 0; i < 40; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 4 + 2, // 2px to 6px
          speed: _random.nextDouble() * 0.002 + 0.0005,
          opacity: _random.nextDouble() * 0.5 + 0.3,
        ),
      );
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    storeNameC.dispose();
    storeLocationC.dispose();
    super.dispose();
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data Toko $name ($location - Shift $shift) berhasil dikirim!',
          style: GoogleFonts.workSans(color: colorPrimary),
        ),
        backgroundColor: colorSecondaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate directly to HomeScreen after submitting
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.push(
          HomeScreen(storeName: name, storeLocation: location, shift: shift),
        );
      }
    });
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

          // Main Body Canvas with Warm Particles Background
          body: Stack(
            children: [
              // Warm Gradient Background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3E2723), Color(0xFF5D4037)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Particle Animation Layer
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ParticlePainter(
                        _particles,
                        colorSecondaryFixedDim,
                      ),
                    );
                  },
                ),
              ),

              // Centered Form Canvas
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 24.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorSurfaceContainerLowest.withValues(
                          alpha: 0.92,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(68, 42, 34, 0.25),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              hintText: 'Caffee',
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
            ],
          ),
        );
      },
    );
  }
}

// Particle Data Model
class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Custom Painter for Animated Warm Floating Particles
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.y -= particle.speed;
      if (particle.y < 0) {
        particle.y = 1.0;
        particle.x = Random().nextDouble();
      }

      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      final dx = particle.x * size.width;
      final dy = particle.y * size.height;

      canvas.drawCircle(Offset(dx, dy), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
