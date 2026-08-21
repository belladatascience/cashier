import 'dart:typed_data';

import 'package:cashier/extension/navigator.dart';
import 'package:cashier/halaman1/utils/app_localization.dart';
import 'package:cashier/halaman1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cashier/halaman1/utils/user_data_store.dart';

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

  final List<String> positionOptions = [
    'Senior Barista',
    'Head Barista',
    'Junior Barista',
    'Store Supervisor',
    'Cashier Specialist',
  ];

  final List<String> locationOptions = [
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
    final data = UserDataStore.instance.userDataNotifier.value;
    fullNameC = TextEditingController(
      text: data['accountName'] ?? 'Bella Gita Asmara',
    );
    emailC = TextEditingController(
      text: data['email'] ?? 'bella.gita@bgaco.com',
    );
    cashierIdC = TextEditingController(
      text: data['cashierId'] ?? 'BG188889',
    );
    phoneC = TextEditingController(text: data['phone'] ?? '087888848000');
    selectedPosition = data['accountRole'] ?? 'Senior Barista';
    selectedLocation = data['location'] ?? 'BGA Co. - Central Perk';
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final theme = AppTheme.instance;

      final updatedData = {
        'accountName': fullNameC.text.trim(),
        'email': emailC.text.trim(),
        'cashierId': cashierIdC.text.trim(),
        'phone': phoneC.text.trim(),
        'accountRole': selectedPosition,
        'location': selectedLocation,
        if (_avatarBytes != null) 'avatarBytes': _avatarBytes,
      };

      UserDataStore.instance.updateUserData(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalization.instance.getText('saved'),
            style: GoogleFonts.workSans(color: Colors.white),
          ),
          backgroundColor: theme.secondaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop(updatedData);
    }
  }

  Widget _buildProfilePhotoSection() {
    final theme = AppTheme.instance;

    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.surfaceContainerLow,
                  border: Border.all(color: theme.secondaryColor, width: 2.5),
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
                      ? Image.memory(
                          _avatarBytes!,
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                        )
                      : Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop',
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 60,
                            color: theme.outlineColor,
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
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
                        Icons.photo_camera,
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
              AppLocalization.instance.getText('change_photo'),
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

  InputDecoration _buildInputDecoration() {
    final theme = AppTheme.instance;

    return InputDecoration(
      filled: true,
      fillColor: theme.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

  Widget _buildFieldLabel(String label) {
    final theme = AppTheme.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: GoogleFonts.workSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
          letterSpacing: 0.2,
        ),
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
                  loc.getText('edit_info_title'),
                  style: GoogleFonts.sourceSerif4(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(color: theme.dividerColor, height: 1.0),
                ),
              ),

              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 24.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Profile Photo Section
                                  _buildProfilePhotoSection(),
                                  const SizedBox(height: 32),

                                  // Full Name Input
                                  _buildFieldLabel(loc.getText('full_name')),
                                  TextFormField(
                                    controller: fullNameC,
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
                                  _buildFieldLabel('Email'),
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
                                        return 'Email is required';
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
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.surfaceColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: Text(
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
