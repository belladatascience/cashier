import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AnimatedCartoonLogo extends StatefulWidget {
  final double height;
  final double borderRadius;
  final Uint8List? imageBytes;
  final String? customUrl;
  final String defaultAssetPath;
  final VoidCallback? onChangeRequested;
  final bool showEditButton;

  const AnimatedCartoonLogo({
    super.key,
    this.height = 140,
    this.borderRadius = 16,
    this.imageBytes,
    this.customUrl,
    this.defaultAssetPath = 'assets/animation/cafe.json',
    this.onChangeRequested,
    this.showEditButton = true,
  });

  @override
  State<AnimatedCartoonLogo> createState() => _AnimatedCartoonLogoState();
}

class _AnimatedCartoonLogoState extends State<AnimatedCartoonLogo>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // Floating Up/Down Animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse & Breathing Scale Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Ambient Sparkle Ring Rotation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget() {
    if (widget.imageBytes != null) {
      return Image.memory(
        widget.imageBytes!,
        fit: BoxFit.contain,
      );
    } else if (widget.customUrl != null) {
      return Image.network(
        widget.customUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildAssetFallback(),
      );
    } else {
      return _buildAssetFallback();
    }
  }

  Widget _buildAssetFallback() {
    if (widget.defaultAssetPath.toLowerCase().endsWith('.json')) {
      return Lottie.asset(
        widget.defaultAssetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }
    return Image.asset(
      widget.defaultAssetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.point_of_sale, size: 48, color: AppTheme.instance.secondaryColor),
        const SizedBox(height: 6),
        Text(
          'BGA Co. Cashier',
          style: GoogleFonts.sourceSerif4(
            fontWeight: FontWeight.bold,
            color: AppTheme.instance.primaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;

    return Stack(
      children: [
        // Main Outer Container with Gradient Shimmer & Border
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: theme.isDarkMode
                  ? [
                      theme.surfaceContainerLow,
                      theme.secondaryContainer.withValues(alpha: 0.3),
                    ]
                  : [
                      theme.secondaryContainer.withValues(alpha: 0.4),
                      theme.surfaceContainerLow,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.secondaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.secondaryColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating Ambient Sparkle Stars in Background
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: Container(
                        width: widget.height * 1.5,
                        height: widget.height * 1.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.secondaryColor.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Animated Cartoon Logo Content (Floating & Pulsing)
                AnimatedBuilder(
                  animation: Listenable.merge([_floatController, _pulseController]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildImageWidget(),
                  ),
                ),

                // Animated "LIVE CARTOON LOGO" Badge Indicator
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'KARTUN ANIMASI BERGERAK',
                          style: GoogleFonts.workSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Colors.white,
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

        // Optional Edit Button Overlay
        if (widget.showEditButton && widget.onChangeRequested != null)
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: widget.onChangeRequested,
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
}
