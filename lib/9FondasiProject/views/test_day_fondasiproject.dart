import 'dart:io';

import 'package:cashier/9FondasiProject/constants/app_constants.dart';
import 'package:cashier/9FondasiProject/constants/app_images.dart';
import 'package:cashier/9FondasiProject/constants/app_typography.dart';
import 'package:cashier/utils/button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TestDay20 extends StatefulWidget {
  const TestDay20({super.key});

  @override
  State<TestDay20> createState() => _TestDay20State();
}

class _TestDay20State extends State<TestDay20> {
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.primaryColor,'
      floatingActionButton: FloatingActionButton(onPressed: () {}),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Judul Gambar", style: AppTextStyles.heading1),
            Image.asset(AppImages.dragonBall),
            Image.asset(AppImages.fb),
            Text(AppConstants.version, style: AppTextStyles.heading1),
            DefaultButton(
              text: "Camera",
              onPressed: () {
                _pickImage(ImageSource.camera);
              },
            ),
            SizedBox(height: 20),
            DefaultButton(
              text: "Gallery",
              onPressed: () {
                _pickImage(ImageSource.gallery);
              },
            ),
            Text(_selectedImage != null ? _selectedImage!.path.toString() : ""),

            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Center(child: Text('Belum ada gambar dipilih')),
            ),
          ],
        ),
      ),
    );
  }
}
