import 'package:flutter/material.dart';

class UserDataStore {
  static final UserDataStore instance = UserDataStore._internal();
  UserDataStore._internal();

  final ValueNotifier<Map<String, dynamic>> userDataNotifier = ValueNotifier({
    // Profile Akun Data (Edited in EditPersonalInfoScreen)
    'accountName': 'Bella Gita Asmara',
    'email': 'bella.gita@bgaco.com',
    'cashierId': 'BG188889',
    'phone': '087888848000',
    'accountRole': 'Senior Barista',

    // Profile Kasir Data (Edited in Profile screen via Edit Profil Kasir modal)
    'cashierName': 'Bella Saputra',
    'cashierRole': 'Senior Barista',
    'location': 'BGA Co. - Central Perk',
    'storeName': 'Bella Cafe',
    'shift': 'Pagi',
    'startDate': DateTime(2024, 1, 15),
    'avatarBytes': null,
  });

  void updateUserData(Map<String, dynamic> newData) {
    final current = Map<String, dynamic>.from(userDataNotifier.value);
    newData.forEach((key, value) {
      if (value != null) {
        current[key] = value;
      }
    });
    userDataNotifier.value = current;
  }
}
