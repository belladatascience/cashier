import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/services/firebase_auth_service.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cashier/halaman1/views/Home/data_user.dart';
import 'package:cashier/halaman1/views/Home/login.dart';
import 'package:cashier/halaman1/views/Profile/cashier_profile_screen.dart';
import 'package:cashier/halaman1/widgets/animated_cartoon_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationDrawerScreen extends StatefulWidget {
  final String storeName;
  final String storeLocation;
  final String shift;

  const NavigationDrawerScreen({
    super.key,
    this.storeName = 'Bella Cafe',
    this.storeLocation = 'Jakarta',
    this.shift = 'Pagi',
  });

  @override
  State<NavigationDrawerScreen> createState() => _NavigationDrawerScreenState();
}

class _NavigationDrawerScreenState extends State<NavigationDrawerScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dynamic Color Tokens from AppTheme
  Color get colorPrimary => AppTheme.instance.primaryColor;
  Color get colorSecondary => AppTheme.instance.secondaryColor;
  Color get colorBackground => AppTheme.instance.backgroundColor;
  Color get colorSurfaceContainerLowest => AppTheme.instance.surfaceColor;
  Color get colorSurfaceContainerLow => AppTheme.instance.surfaceContainerLow;
  Color get colorSurfaceContainerHighest => AppTheme.instance.surfaceVariant;
  Color get colorOutlineVariant => AppTheme.instance.outlineVariant;
  Color get colorOutline => AppTheme.instance.outlineColor;
  Color get colorOnSurfaceVariant => AppTheme.instance.onSurfaceVariant;
  Color get colorOnSurface => AppTheme.instance.onSurfaceColor;
  Color get colorError => AppTheme.instance.isDarkMode
      ? const Color(0xFFFFB4AB)
      : const Color(0xFFBA1A1A);
  Color get colorErrorContainer => AppTheme.instance.isDarkMode
      ? const Color(0xFF93000A)
      : const Color(0xFFFFDAD6);

  @override
  void initState() {
    super.initState();
    // Auto-open drawer after build to showcase the drawer UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaffoldKey.currentState?.openDrawer();
    });
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colorSurfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout Firebase',
          style: GoogleFonts.sourceSerif4(
            color: colorPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun Firebase kasir ini?',
          style: GoogleFonts.literata(color: colorOnSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Batal',
              style: GoogleFonts.literata(color: colorOutline),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);

              // Sign out from Firebase Auth
              try {
                await FirebaseAuthService.instance.signOut();
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                debugPrint('Firebase signOut error: $e');
              }

              if (mounted) {
                context.pushAndRemoveAll(const cashierlogin1());
              }
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
              style: GoogleFonts.literata(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppTheme.instance.themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: AppTheme.instance.themePaletteNotifier,
          builder: (context, palette, child) {
            return ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: UserDataStore.instance.userDataNotifier,
              builder: (context, userData, child) {
                final currentFirebaseUser = FirebaseAuth.instance.currentUser;

                final storeDisplayName = (userData['storeName'] as String?)?.isNotEmpty == true
                    ? userData['storeName'] as String
                    : widget.storeName;

                final storeLocation = (userData['location'] as String?)?.isNotEmpty == true
                    ? userData['location'] as String
                    : widget.storeLocation;

                final currentShift = (userData['shift'] as String?)?.isNotEmpty == true
                    ? userData['shift'] as String
                    : widget.shift;

                final cashierName = (userData['cashierName'] as String?)?.isNotEmpty == true
                    ? userData['cashierName'] as String
                    : (currentFirebaseUser?.displayName ?? 'Kasir');

                final cashierRole = (userData['cashierRole'] as String?)?.isNotEmpty == true
                    ? userData['cashierRole'] as String
                    : 'Barista / Kasir';

                final userEmail = currentFirebaseUser?.email ?? (userData['email'] as String? ?? '');

                return Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: colorBackground,

                  // Left Navigation Drawer Component
                  drawer: Drawer(
                    width: 320,
                    backgroundColor: colorSurfaceContainerLowest,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header Card Section
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
                                color: colorOutlineVariant.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeDisplayName,
                                      style: GoogleFonts.sourceSerif4(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: colorOnSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      storeLocation,
                                      style: GoogleFonts.literata(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorOutline,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Shift: $currentShift',
                                      style: GoogleFonts.literata(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorOnSurfaceVariant,
                                      ),
                                    ),
                                    if (userEmail.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        userEmail,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.workSans(
                                          fontSize: 12,
                                          color: colorOutline,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      context.push(const CashierProfileScreen());
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: colorOutline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Animated Cartoon Logo Banner Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 4.0,
                          ),
                          child: const AnimatedCartoonLogo(
                            height: 120,
                            borderRadius: 12,
                            showEditButton: false,
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8.0,
                          ),
                          child: Divider(color: Color(0x33D4C3BE), height: 1),
                        ),

                        // Navigation Links Section
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            children: [
                              _buildDrawerNavItem(
                                icon: Icons.person_outline,
                                title: 'Profile Kasir',
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push(const CashierProfileScreen());
                                },
                              ),
                              _buildDrawerNavItem(
                                icon: Icons.manage_accounts_outlined,
                                title: 'Kelola Pengguna',
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push(const DataUserCashier());
                                },
                              ),
                              _buildDrawerNavItem(
                                icon: Icons.calendar_today_outlined,
                                title: 'Shift & Jadwal',
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              _buildDrawerNavItem(
                                icon: Icons.cloud_done_outlined,
                                title: 'Status Firebase: Terhubung',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        // Logout Section at Bottom
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: InkWell(
                            onTap: _handleLogout,
                            borderRadius: BorderRadius.circular(12),
                            hoverColor: colorErrorContainer.withValues(alpha: 0.5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.logout, size: 22, color: colorError),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Logout Akun',
                                    style: GoogleFonts.literata(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colorError,
                                      letterSpacing: 0.3,
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

                  // Main Dashboard View (Behind Scrim)
                  appBar: AppBar(
                    backgroundColor: colorBackground,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(Icons.menu, color: colorPrimary, size: 28),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    title: Text(
                      'Dashboard Kasir',
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorPrimary,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.search, color: colorOnSurfaceVariant),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: colorOnSurfaceVariant,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  body: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorSurfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorOutline.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang, $cashierName!',
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Peran: $cashierRole',
                                style: GoogleFonts.workSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colorSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toko: $storeDisplayName ($storeLocation)',
                                style: GoogleFonts.oswald(
                                  fontSize: 15,
                                  color: colorOnSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Shift Aktif: $currentShift',
                                style: GoogleFonts.oswald(
                                  fontSize: 15,
                                  color: colorPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Menu Kasir & Statistik',
                          style: GoogleFonts.sourceSerif4(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _buildDashboardCard(
                                icon: Icons.point_of_sale,
                                title: 'POS Kasir',
                                color: const Color(0xFF7D562D),
                              ),
                              _buildDashboardCard(
                                icon: Icons.receipt_long,
                                title: 'Transaksi',
                                color: const Color(0xFF45492D),
                              ),
                              _buildDashboardCard(
                                icon: Icons.inventory_2_outlined,
                                title: 'Stok Produk',
                                color: const Color(0xFF5D4037),
                              ),
                              _buildDashboardCard(
                                icon: Icons.bar_chart,
                                title: 'Laporan Shift',
                                color: const Color(0xFF303030),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildDrawerNavItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(icon, size: 22, color: colorOnSurfaceVariant),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.literata(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorOnSurfaceVariant,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorSurfaceContainerHighest),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.oswald(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
