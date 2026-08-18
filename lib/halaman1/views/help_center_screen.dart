import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
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
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalization.instance;
    final theme = AppTheme.instance;

    return ValueListenableBuilder<String>(
      valueListenable: theme.themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: loc.currentLanguageNotifier,
          builder: (context, langCode, child) {
            return Scaffold(
              backgroundColor: theme.backgroundColor,

              // Top Header Sticky AppBar
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
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.account_circle, color: theme.primaryColor),
                    onPressed: () => _showSnackBar('Profil Akun'),
                  ),
                  const SizedBox(width: 8),
                ],
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
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            style: GoogleFonts.workSans(
                              fontSize: 15,
                              color: theme.primaryColor,
                            ),
                            decoration: InputDecoration(
                              hintText: loc.getText('search_faq_hint'),
                              hintStyle: GoogleFonts.workSans(
                                color: theme.onSurfaceVariant,
                                fontSize: 15,
                              ),
                              filled: true,
                              fillColor: theme.surfaceColor,
                              prefixIcon: Icon(
                                Icons.search,
                                color: theme.onSurfaceVariant,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: theme.dividerColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: theme.secondaryColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Popular Categories Title
                          Text(
                            loc.getText('popular_categories'),
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Bento 2-Column Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.3,
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
                          Text(
                            loc.getText('popular_faqs'),
                            style: GoogleFonts.sourceSerif4(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
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
                              child: Column(
                                children: [
                                  _buildFaqItem(
                                    index: 0,
                                    question: loc.getText('faq_1_q'),
                                    answer: loc.getText('faq_1_a'),
                                  ),
                                  _buildFaqItem(
                                    index: 1,
                                    question: loc.getText('faq_2_q'),
                                    answer: loc.getText('faq_2_a'),
                                  ),
                                  _buildFaqItem(
                                    index: 2,
                                    question: loc.getText('faq_3_q'),
                                    answer: loc.getText('faq_3_a'),
                                  ),
                                ],
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
                                    onPressed: () => _showSnackBar(
                                      loc.getText('contact_support'),
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
                                        _showSnackBar(loc.getText('live_chat')),
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
