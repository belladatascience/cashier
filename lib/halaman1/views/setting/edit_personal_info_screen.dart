import 'dart:typed_data';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:cashier/halaman1/utils/user_data_store.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameC;
  late TextEditingController emailC;
  late TextEditingController cashierIdC;
  late TextEditingController phoneC;

  String selectedPosition = 'Senior Barista';
  String selectedLocation = 'BGA Co. - Central Perk';
  bool _isLoading = false;

  final List<String> positionOptions = [
    'Barista / Kasir',
    'Senior Barista',
    'Head Barista',
    'Junior Barista',
    'Kasir',
    'Head Cashier',
    'Store Supervisor',
    'Store Manager',
    'Cashier Specialist',
    'Administrator',
  ];

  final List<String> locationOptions = [
    'Bella Cafe',
    'BGA Co. - Central Perk',
    'BGA Co. - Downtown Latte',
    'BGA Co. - Westside Brew',
    'BGA Co. - Express Kiosk',
  ];

  Uint8List? _avatarBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final fbUser = FirebaseAuth.instance.currentUser;
    final data = UserDataStore.instance.userDataNotifier.value;

    fullNameC = TextEditingController(
      text: fbUser?.displayName ?? data['accountName'] ?? data['cashierName'] ?? 'Bella Gita Asmara',
    );
    emailC = TextEditingController(
      text: fbUser?.email ?? data['email'] ?? 'bella.gita@bgaco.com',
    );
    cashierIdC = TextEditingController(
      text: data['cashierId'] ?? (fbUser != null ? 'BG${fbUser.uid.substring(0, 6).toUpperCase()}' : 'BG188889'),
    );
    phoneC = TextEditingController(
      text: fbUser?.phoneNumber ?? data['phone'] ?? '087888848000',
    );

    final role = data['accountRole'] ?? data['cashierRole'] ?? 'Senior Barista';
    if (!positionOptions.contains(role)) {
      positionOptions.insert(0, role);
    }
    selectedPosition = role;

    final loc = data['location'] ?? 'BGA Co. - Central Perk';
    if (!locationOptions.contains(loc)) {
      locationOptions.insert(0, loc);
    }
    selectedLocation = loc;

    if (data['avatarBytes'] != null) {
      _avatarBytes = data['avatarBytes'];
    }
  }

  @override
  void dispose() {
    fullNameC.dispose();
    emailC.dispose();
    cashierIdC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageSourceActionSheet() {
    final theme = AppTheme.instance;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: theme.secondaryColor,
                  ),
                  title: Text(
                    'Pilih dari Galeri',
                    style: GoogleFonts.workSans(color: theme.primaryColor),
                  ),
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: theme.secondaryColor),
                  title: Text(
                    'Ambil Foto Kamera',
                    style: GoogleFonts.workSans(color: theme.primaryColor),
                  ),
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final theme = AppTheme.instance;
    final fbUser = FirebaseAuth.instance.currentUser;

    final newName = fullNameC.text.trim();
    final newEmail = emailC.text.trim();
    final newCashierId = cashierIdC.text.trim();
    final newPhone = phoneC.text.trim();

    setState(() {
      _isLoading = true;
    });

    // 1. Sync update to Firebase Authentication
    try {
      if (fbUser != null && fbUser.displayName != newName) {
        await fbUser.updateDisplayName(newName);
      }
    } catch (authErr) {
      debugPrint('Firebase Auth display name update notice: $authErr');
    }

    // 2. Sync update to Cloud Firestore
    try {
      if (fbUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
          'nama': newName,
          'email': newEmail,
          'cashierId': newCashierId,
          'nomor_hp': newPhone,
          'role': selectedPosition,
          'location': selectedLocation,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (firestoreErr) {
      debugPrint('Firestore user sync notice: $firestoreErr');
    }

    // 3. Update UserDataStore singleton
    final updatedData = {
      'accountName': newName,
      'cashierName': newName,
      'email': newEmail,
      'cashierId': newCashierId,
      'phone': newPhone,
      'accountRole': selectedPosition,
      'cashierRole': selectedPosition,
      'location': selectedLocation,
      if (_avatarBytes != null) 'avatarBytes': _avatarBytes,
    };

    await UserDataStore.instance.updateUserData(updatedData);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Profil kasir berhasil diperbarui ke Cloud Firebase!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.secondaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop(updatedData);
  }

  Widget _buildProfilePhotoSection() {
    final theme = AppTheme.instance;
    final loc = AppLocalization.instance;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.surfaceColor,
                  border: Border.all(
                    color: theme.dividerColor,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _avatarBytes != null
                      ? Image.memory(_avatarBytes!, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/img/cat_mascot.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 54,
                              color: theme.primaryColor,
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: theme.secondaryColor,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: _showImageSourceActionSheet,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _showImageSourceActionSheet,
            icon: Icon(Icons.edit, size: 16, color: theme.secondaryColor),
            label: Text(
              loc.getText('change_photo'),
              style: GoogleFonts.workSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    final theme = AppTheme.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({Widget? suffixIcon}) {
    final theme = AppTheme.instance;

    return InputDecoration(
      filled: true,
      fillColor: theme.surfaceColor,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: theme.dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: theme.secondaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
                  loc.getText('edit_personal_info_title'),
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
                child: Column(
                  children: [
                    // Scrollable Form Fields Area
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 24.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Photo
                                  _buildProfilePhotoSection(),
                                  const SizedBox(height: 32),

                                  // Full Name Input
                                  _buildFieldLabel(loc.getText('full_name')),
                                  TextFormField(
                                    controller: fullNameC,
                                    textCapitalization: TextCapitalization.words,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return loc.getText('full_name');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Email Input
                                  _buildFieldLabel(loc.getText('email_address')),
                                  TextFormField(
                                    controller: emailC,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return loc.getText('email_address');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Cashier ID Input
                                  _buildFieldLabel(
                                    loc.getText('cashier_id_field'),
                                  ),
                                  TextFormField(
                                    controller: cashierIdC,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return loc.getText('cashier_id_field');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Phone Number Input
                                  _buildFieldLabel(loc.getText('phone_number')),
                                  TextFormField(
                                    controller: phoneC,
                                    keyboardType: TextInputType.phone,
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return loc.getText('phone_number');
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Position Dropdown
                                  _buildFieldLabel(
                                    loc.getText('position_field'),
                                  ),
                                  DropdownButtonFormField<String>(
                                    initialValue: selectedPosition,
                                    dropdownColor: theme.surfaceColor,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: theme.onSurfaceVariant,
                                    ),
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(),
                                    items: positionOptions.map((String option) {
                                      return DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(option),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedPosition = newValue;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Store Location Dropdown
                                  _buildFieldLabel(
                                    loc.getText('location_field'),
                                  ),
                                  DropdownButtonFormField<String>(
                                    initialValue: selectedLocation,
                                    dropdownColor: theme.surfaceColor,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: theme.onSurfaceVariant,
                                    ),
                                    style: GoogleFonts.workSans(
                                      fontSize: 16,
                                      color: theme.primaryColor,
                                    ),
                                    decoration: _buildInputDecoration(),
                                    items: locationOptions.map((String option) {
                                      return DropdownMenuItem<String>(
                                        value: option,
                                        child: Text(option),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedLocation = newValue;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Action Bar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        border: Border(
                          top: BorderSide(color: theme.dividerColor, width: 1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.surfaceColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.surfaceColor,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      loc.getText('save_changes'),
                                      style: GoogleFonts.workSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
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
}
