import 'package:cashier/extension/navigator.dart';
import 'package:cashier/CASHIER/utils/app_localization.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/CASHIER/views/setting/contact_support_screen.dart';
import 'package:cashier/CASHIER/views/setting/live_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _expandedFaqIndex;
  String _searchQuery = '';

  List<Map<String, String>> _firebaseFaqs = [];
  bool _isLoadingFaqs = true;

  @override
  void initState() {
    super.initState();
    _fetchFaqsFromFirebase();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _fetchFaqsFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('faqs')
          .limit(10)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final faqs = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'q': (data['question'] ?? data['q'] ?? '').toString(),
            'a': (data['answer'] ?? data['a'] ?? '').toString(),
          };
        }).where((f) => f['q']!.isNotEmpty).toList();

        if (mounted && faqs.isNotEmpty) {
          setState(() {
            _firebaseFaqs = faqs;
            _isLoadingFaqs = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Firestore fetch FAQs notice: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingFaqs = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.instance;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.secondaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.secondaryColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
  }) {
    final theme = AppTheme.instance;
    final isExpanded = _expandedFaqIndex == index;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedFaqIndex = isExpanded ? null : index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.workSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more, color: theme.primaryColor),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              color: theme.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Text(
                answer,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  height: 1.5,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.instance;
    final theme = AppTheme.instance;
    final currentFbUser = FirebaseAuth.instance.currentUser;

    // Build FAQ list (Dynamic from Firebase or fallback)
    final defaultFaqs = [
      {
        'q': loc.getText('faq_1_q'),
        'a': loc.getText('faq_1_a'),
      },
      {
        'q': loc.getText('faq_2_q'),
        'a': loc.getText('faq_2_a'),
      },
      {
        'q': loc.getText('faq_3_q'),
        'a': loc.getText('faq_3_a'),
      },
      {
        'q': 'Bagaimana cara reset kata sandi kasir via Firebase?',
        'a': 'Buka menu Ganti Kata Sandi di Pengaturan, atau gunakan fitur "Lupa Kata Sandi" di halaman Login untuk menerima tautan reset otomatis ke email Anda.',
      },
    ];

    final sourceFaqs = _firebaseFaqs.isNotEmpty ? _firebaseFaqs : defaultFaqs;
    final filteredFaqs = _searchQuery.isEmpty
        ? sourceFaqs
        : sourceFaqs
            .where((f) =>
                f['q']!.toLowerCase().contains(_searchQuery) ||
                f['a']!.toLowerCase().contains(_searchQuery))
            .toList();

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: loc.currentLanguageNotifier,
          builder: (context, langCode, child) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,

              // Top App Bar
              appBar: AppBar(
                backgroundColor: theme.backgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0.5,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  loc.getText('help_center_title'),
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(color: theme.dividerColor, height: 1.0),
                ),
              ),

              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 24.0,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Box Section
                          Container(
                            decoration: BoxDecoration(
                              color: theme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.workSans(
                                color: theme.primaryColor,
                              ),
                              decoration: InputDecoration(
                                hintText: loc.getText('search_help_hint'),
                                hintStyle: GoogleFonts.workSans(
                                  color: theme.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.onSurfaceVariant,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Firebase Cloud Support Status Banner (If User Logged In)
                          if (currentFbUser != null) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: theme.surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.secondaryColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cloud_done_outlined,
                                    color: theme.secondaryColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Akun Kasir Terhubung Cloud: ${currentFbUser.email ?? "Aktif"}',
                                      style: GoogleFonts.workSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Category Cards Grid
                          Text(
                            loc.getText('categories_title'),
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.35,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildCategoryCard(
                                icon: Icons.receipt_long,
                                title: loc.getText('cat_order_issues'),
                                onTap: () => _showSnackBar(
                                  loc.getText('cat_order_issues'),
                                ),
                              ),
                              _buildCategoryCard(
                                icon: Icons.schedule,
                                title: loc.getText('cat_shift_mgmt'),
                                onTap: () => _showSnackBar(
                                  loc.getText('cat_shift_mgmt'),
                                ),
                              ),
                              _buildCategoryCard(
                                icon: Icons.security_outlined,
                                title: loc.getText('cat_account_security'),
                                onTap: () => _showSnackBar(
                                  loc.getText('cat_account_security'),
                                ),
                              ),
                              _buildCategoryCard(
                                icon: Icons.tune,
                                title: loc.getText('cat_app_technical'),
                                onTap: () => _showSnackBar(
                                  loc.getText('cat_app_technical'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 36),

                          // Popular FAQs Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc.getText('popular_faqs'),
                                style: GoogleFonts.sourceSerif4(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                ),
                              ),
                              if (_isLoadingFaqs)
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.secondaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: theme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: filteredFaqs.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Center(
                                        child: Text(
                                          'Tidak ada FAQ yang cocok dengan pencarian "$_searchQuery".',
                                          style: GoogleFonts.workSans(
                                            color: theme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: List.generate(
                                        filteredFaqs.length,
                                        (index) => _buildFaqItem(
                                          index: index,
                                          question: filteredFaqs[index]['q']!,
                                          answer: filteredFaqs[index]['a']!,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Need More Help Section
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  loc.getText('need_more_help'),
                                  style: GoogleFonts.sourceSerif4(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Contact Support Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: () => context.push(
                                      const ContactSupportScreen(),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      foregroundColor: theme.surfaceColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.support_agent,
                                      size: 20,
                                    ),
                                    label: Text(
                                      loc.getText('contact_support'),
                                      style: GoogleFonts.workSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Live Chat Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        context.push(const LiveChatScreen()),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          theme.surfaceContainerLow,
                                      foregroundColor: theme.primaryColor,
                                      side: BorderSide(
                                        color: theme.primaryColor,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 20,
                                    ),
                                    label: Text(
                                      loc.getText('live_chat'),
                                      style: GoogleFonts.workSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
