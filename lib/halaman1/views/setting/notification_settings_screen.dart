import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Notification toggle states
  bool _newOrders = true;
  bool _orderCancellations = true;
  bool _specialRequests = false;

  bool _scheduleChanges = true;
  bool _shiftReminders = true;
  bool _staffAnnouncements = true;

  bool _securityAlerts = true;
  bool _appUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettingsFromFirebase();
  }

  Future<void> _loadNotificationSettingsFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final notifData = doc.data()!['notifications'] as Map<String, dynamic>?;
        if (notifData != null && mounted) {
          setState(() {
            _newOrders = notifData['newOrders'] ?? _newOrders;
            _orderCancellations = notifData['orderCancellations'] ?? _orderCancellations;
            _specialRequests = notifData['specialRequests'] ?? _specialRequests;
            _scheduleChanges = notifData['scheduleChanges'] ?? _scheduleChanges;
            _shiftReminders = notifData['shiftReminders'] ?? _shiftReminders;
            _staffAnnouncements = notifData['staffAnnouncements'] ?? _staffAnnouncements;
            _securityAlerts = notifData['securityAlerts'] ?? _securityAlerts;
            _appUpdates = notifData['appUpdates'] ?? _appUpdates;
          });
        }
      }
    } catch (e) {
      debugPrint('Firebase load notification settings notice: $e');
    }
  }

  Future<void> _syncNotificationSettingsToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'notifications': {
          'newOrders': _newOrders,
          'orderCancellations': _orderCancellations,
          'specialRequests': _specialRequests,
          'scheduleChanges': _scheduleChanges,
          'shiftReminders': _shiftReminders,
          'staffAnnouncements': _staffAnnouncements,
          'securityAlerts': _securityAlerts,
          'appUpdates': _appUpdates,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firebase sync notification settings error: $e');
    }
  }

  void _showSnackBar(String title, bool isEnabled) {
    final theme = AppTheme.instance;
    final statusText = isEnabled
        ? AppLocalization.instance.getText('status_on')
        : AppLocalization.instance.getText('status_off');
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title: $statusText',
          style: GoogleFonts.workSans(color: Colors.white),
        ),
        backgroundColor: theme.secondaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = AppTheme.instance;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.workSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: theme.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    final theme = AppTheme.instance;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        border: showDivider
            ? Border(bottom: BorderSide(color: theme.dividerColor, width: 1))
            : null,
      ),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.workSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: theme.onSurfaceColor,
                  ),
                ),
              ),
              Switch(
                value: value,
                activeTrackColor: theme.secondaryColor.withValues(alpha: 0.3),
                activeThumbColor: theme.secondaryColor,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: theme.dividerColor,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    final theme = AppTheme.instance;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
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
        child: Column(children: children),
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
                  loc.getText('notifications_title'),
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
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
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section: ORDER NOTIFICATIONS
                          _buildSectionHeader(
                            loc.getText('sec_order_notifications'),
                          ),
                          _buildSectionContainer([
                            _buildSwitchItem(
                              title: loc.getText('item_new_orders'),
                              value: _newOrders,
                              onChanged: (val) {
                                setState(() => _newOrders = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_new_orders'),
                                  val,
                                );
                              },
                            ),
                            _buildSwitchItem(
                              title: loc.getText('item_order_cancellations'),
                              value: _orderCancellations,
                              onChanged: (val) {
                                setState(() => _orderCancellations = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_order_cancellations'),
                                  val,
                                );
                              },
                            ),
                            _buildSwitchItem(
                              title: loc.getText('item_special_requests'),
                              value: _specialRequests,
                              showDivider: false,
                              onChanged: (val) {
                                setState(() => _specialRequests = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_special_requests'),
                                  val,
                                );
                              },
                            ),
                          ]),
                          const SizedBox(height: 28),

                          // Section: SHIFT UPDATES
                          _buildSectionHeader(loc.getText('sec_shift_updates')),
                          _buildSectionContainer([
                            _buildSwitchItem(
                              title: loc.getText('item_schedule_changes'),
                              value: _scheduleChanges,
                              onChanged: (val) {
                                setState(() => _scheduleChanges = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_schedule_changes'),
                                  val,
                                );
                              },
                            ),
                            _buildSwitchItem(
                              title: loc.getText('item_shift_reminders'),
                              value: _shiftReminders,
                              onChanged: (val) {
                                setState(() => _shiftReminders = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_shift_reminders'),
                                  val,
                                );
                              },
                            ),
                            _buildSwitchItem(
                              title: loc.getText('item_staff_announcements'),
                              value: _staffAnnouncements,
                              showDivider: false,
                              onChanged: (val) {
                                setState(() => _staffAnnouncements = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_staff_announcements'),
                                  val,
                                );
                              },
                            ),
                          ]),
                          const SizedBox(height: 28),

                          // Section: SYSTEM
                          _buildSectionHeader(loc.getText('sec_system')),
                          _buildSectionContainer([
                            _buildSwitchItem(
                              title: loc.getText('item_security_alerts'),
                              value: _securityAlerts,
                              onChanged: (val) {
                                setState(() => _securityAlerts = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_security_alerts'),
                                  val,
                                );
                              },
                            ),
                            _buildSwitchItem(
                              title: loc.getText('item_app_updates'),
                              value: _appUpdates,
                              showDivider: false,
                              onChanged: (val) {
                                setState(() => _appUpdates = val);
                                _syncNotificationSettingsToFirebase();
                                _showSnackBar(
                                  loc.getText('item_app_updates'),
                                  val,
                                );
                              },
                            ),
                          ]),
                          const SizedBox(height: 32),
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
