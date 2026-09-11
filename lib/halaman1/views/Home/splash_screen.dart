import 'dart:async';
import 'dart:math' as math;

import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/Shop/home_screen.dart';
import 'package:cashier/halaman1/views/Home/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Video Controller
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  // Animation Controllers
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _rotateController;
  late AnimationController _progressController;

  // Status & Navigation
  int _currentStatusIndex = 0;
  bool _hasNavigated = false;
  Timer? _navigationTimer;
  double _currentProgress = 0.0;

  final List<String> _loadingSteps = [
    'Memuat konfigurasi sistem...',
    'Menghubungkan ke Firebase Cloud...',
    'Memeriksa status sesi kasir...',
    'Menyiapkan tema & antarmuka...',
    'Selamat datang di BGA Co. Cashier!',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Entrance Fade & Scale Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    // 2. Ambient Rotating Ring
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // 3. Exact 3-Second Loading Progress Controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressController.addListener(() {
      if (!mounted || _hasNavigated) return;
      final progress = _progressController.value;
      final stepIndex = (progress * (_loadingSteps.length - 1)).floor().clamp(
        0,
        _loadingSteps.length - 1,
      );
      setState(() {
        _currentProgress = progress;
        _currentStatusIndex = stepIndex;
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkSessionAndNavigate();
      }
    });

    _entranceController.forward();
    _progressController.forward();

    // 4. Fallback 3-Second Timer
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      _checkSessionAndNavigate();
    });

    // 5. Initialize Video Player asynchronously
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/video/logo_cashier_animasi.mp4',
      );
      _videoController = controller;

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _isVideoInitialized = true;
      });

      await controller.setLooping(false);
      await controller.setVolume(1.0);
      await controller.play();
    } catch (e) {
      debugPrint('Error loading video: $e');
      if (mounted) {
        setState(() {
          _hasVideoError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _progressController.dispose();
    final controller = _videoController;
    if (controller != null) {
      controller.dispose();
    }
    _entranceController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _checkSessionAndNavigate() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    // Check Firebase Auth Session
    final currentFirebaseUser = FirebaseAuth.instance.currentUser;

    Widget targetScreen;
    if (currentFirebaseUser != null) {
      // User is already logged in to Firebase, restore session and proceed to store showcase
      final displayName = currentFirebaseUser.displayName ?? 'Kasir';
      final email = currentFirebaseUser.email ?? '';

      await UserDataStore.instance.updateUserData({
        'accountName': displayName,
        'cashierName': displayName,
        'email': email,
      });

      targetScreen = const HomeScreen();
    } else {
      // User not logged in, go to Login Screen
      targetScreen = const cashierlogin1();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeTransition = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          final slideTransition =
              Tween<Offset>(
                begin: const Offset(0.04, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: fadeTransition,
            child: SlideTransition(position: slideTransition, child: child),
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
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: theme.themePaletteNotifier,
          builder: (context, palette, _) {
            final isDark = theme.isDarkMode;
            final primary = theme.primaryColor;
            final secondary = theme.secondaryColor;
            final background = theme.backgroundColor;
            final surfaceColor = theme.surfaceColor;
            final onSurfaceVariant = theme.onSurfaceVariant;

            return Scaffold(
              backgroundColor: background,
              body: Stack(
                children: [
                  // 1. Ambient Background Glow
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.0, -0.2),
                          radius: 1.1,
                          colors: [
                            secondary.withValues(alpha: isDark ? 0.22 : 0.14),
                            primary.withValues(alpha: isDark ? 0.12 : 0.06),
                            background,
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 2. Animated Rotating Glow Ring
                  Center(
                    child: AnimatedBuilder(
                      animation: _rotateController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateController.value * 2 * math.pi,
                          child: Container(
                            width: 320,
                            height: 320,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.transparent,
                                  secondary.withValues(
                                    alpha: isDark ? 0.25 : 0.18,
                                  ),
                                  primary.withValues(
                                    alpha: isDark ? 0.35 : 0.25,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.45, 0.75, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 3. Central Brand Content
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Video Preview / Branding Container
                              _buildVideoContainer(
                                primary: primary,
                                secondary: secondary,
                                surface: surfaceColor,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 32),

                              // App Title & Tagline
                              Text(
                                'BGA Co. Cashier',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Professional Point of Sale System',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  color: onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 36),

                              // 4. Elegant Progress Bar & Status Text
                              Container(
                                width: 260,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Column(
                                  children: [
                                    // Smooth Gradient Progress Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        height: 6,
                                        width: double.infinity,
                                        color: isDark
                                            ? const Color(0xFF38231E)
                                            : const Color(0xFFF1E5E1),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 120,
                                            ),
                                            width: 260 * _currentProgress,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                colors: [secondary, primary],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: secondary.withValues(
                                                    alpha: 0.4,
                                                  ),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Dynamic Status Text
                                        Expanded(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            child: Text(
                                              _loadingSteps[_currentStatusIndex],
                                              key: ValueKey<int>(
                                                _currentStatusIndex,
                                              ),
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.workSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Percentage Text
                                        Text(
                                          '${(_currentProgress * 100).toInt()}%',
                                          style: GoogleFonts.workSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. Footer: Version & Copyright Info
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Version 1.2.4',
                            style: GoogleFonts.workSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant.withValues(alpha: 0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '© 2026 BGA Co. All Rights Reserved',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Video Container Widget with Glow & Rounded Frame
  Widget _buildVideoContainer({
    required Color primary,
    required Color secondary,
    required Color surface,
    required bool isDark,
  }) {
    const double containerSize = 220.0;
    final controller = _videoController;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: surface,
        border: Border.all(
          color: secondary.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: secondary.withValues(alpha: isDark ? 0.35 : 0.2),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video Player
            if (_isVideoInitialized &&
                controller != null &&
                controller.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width > 0
                        ? controller.value.size.width
                        : containerSize,
                    height: controller.value.size.height > 0
                        ? controller.value.size.height
                        : containerSize,
                    child: VideoPlayer(controller),
                  ),
                ),
              )
            else if (_hasVideoError)
              // Fallback if video error
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Lottie.asset(
                  'assets/animation/cashier_header.json',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/cashier_logo.png',
                      fit: BoxFit.cover,
                    );
                  },
                ),
              )
            else
              // Loading indicator while video initializes
              Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(secondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
