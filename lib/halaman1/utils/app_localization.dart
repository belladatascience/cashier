import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalization {
  AppLocalization._internal() {
    _loadLanguage();
  }
  static final AppLocalization instance = AppLocalization._internal();

  static const String keyLanguage = 'app_language_code';

  final ValueNotifier<String> currentLanguageNotifier =
      ValueNotifier<String>('en');

  String get currentCode => currentLanguageNotifier.value;

  String get currentLanguageName {
    switch (currentCode) {
      case 'id':
        return 'Bahasa Indonesia';
      case 'zh':
        return '中文 (Mandarin)';
      case 'en':
      default:
        return 'English';
    }
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(keyLanguage);
      if (savedCode != null && ['en', 'id', 'zh'].contains(savedCode)) {
        currentLanguageNotifier.value = savedCode;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String codeOrName) async {
    String code = 'en';
    final lower = codeOrName.toLowerCase();
    if (lower.contains('indonesia') || lower == 'id') {
      code = 'id';
    } else if (lower.contains('mandarin') || lower.contains('中文') || lower == 'zh') {
      code = 'zh';
    } else {
      code = 'en';
    }

    currentLanguageNotifier.value = code;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyLanguage, code);
    } catch (_) {}
  }

  String getText(String key) {
    final code = currentLanguageNotifier.value;
    final dict = _translations[key];
    if (dict != null && dict.containsKey(code)) {
      return dict[code]!;
    }
    // Fallback to English or key itself
    return dict?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    // Navigation & Common
    'back': {
      'en': 'Back',
      'id': 'Kembali',
      'zh': '返回',
    },
    'save_changes': {
      'en': 'Save Changes',
      'id': 'Simpan Perubahan',
      'zh': '保存更改',
    },
    'saved': {
      'en': 'Saved',
      'id': 'Tersimpan',
      'zh': '已保存',
    },

    // Login Screen
    'cashier_title': {
      'en': 'CASHIER',
      'id': 'KASIR',
      'zh': '收银系统',
    },
    'cashier_id_label': {
      'en': 'Cashier ID / Email',
      'id': 'ID Kasir / Email',
      'zh': '收银员 ID / 邮箱',
    },
    'enter_id_hint': {
      'en': 'Enter your ID or email',
      'id': 'Masukkan ID atau email Anda',
      'zh': '请输入您的 ID 或邮箱',
    },
    'password_label': {
      'en': 'Password',
      'id': 'Kata Sandi',
      'zh': '密码',
    },
    'forgot_password': {
      'en': 'Forgot Password?',
      'id': 'Lupa Kata Sandi?',
      'zh': '忘记密码？',
    },
    'login_button': {
      'en': 'Sign In',
      'id': 'Masuk',
      'zh': '登录',
    },
    'no_account': {
      'en': "Don't have an account? ",
      'id': 'Belum punya akun? ',
      'zh': '还没有账号？ ',
    },
    'register_now': {
      'en': 'Register Now',
      'id': 'Daftar Sekarang',
      'zh': '立即注册',
    },

    // Register Screen
    'register_title': {
      'en': 'REGISTER ACCOUNT',
      'id': 'DAFTAR AKUN',
      'zh': '注册账号',
    },
    'register_subtitle': {
      'en': 'Create a new cashier account for BGA Co.',
      'id': 'Buat akun kasir baru BGA Co.',
      'zh': '创建 BGA Co. 新收银员账号',
    },
    'full_name': {
      'en': 'Full Name',
      'id': 'Nama Lengkap',
      'zh': '姓名',
    },
    'phone_number': {
      'en': 'Phone Number',
      'id': 'Nomor HP',
      'zh': '手机号码',
    },
    'city': {
      'en': 'City',
      'id': 'Asal Kota',
      'zh': '城市',
    },
    'confirm_password': {
      'en': 'Confirm Password',
      'id': 'Konfirmasi Kata Sandi',
      'zh': '确认密码',
    },
    'register_button': {
      'en': 'Register Account',
      'id': 'Daftar Akun',
      'zh': '注册账号',
    },
    'already_have_account': {
      'en': 'Already have an account? ',
      'id': 'Sudah punya akun? ',
      'zh': '已有账号？ ',
    },
    'login_now': {
      'en': 'Sign In Now',
      'id': 'Masuk Sekarang',
      'zh': '立即登录',
    },

    // Settings Screen
    'settings_title': {
      'en': 'Settings',
      'id': 'Pengaturan',
      'zh': '设置',
    },
    'account_section': {
      'en': 'ACCOUNT',
      'id': 'AKUN',
      'zh': '账户',
    },
    'edit_personal_info': {
      'en': 'Edit Personal Info',
      'id': 'Edit Informasi Pribadi',
      'zh': '编辑个人信息',
    },
    'change_password': {
      'en': 'Change Password',
      'id': 'Ubah Kata Sandi',
      'zh': '修改密码',
    },
    'security': {
      'en': 'Security',
      'id': 'Keamanan',
      'zh': '安全',
    },
    'preferences_section': {
      'en': 'PREFERENCES',
      'id': 'PREFERENSI',
      'zh': '偏好设置',
    },
    'language': {
      'en': 'Language',
      'id': 'Bahasa',
      'zh': '语言',
    },
    'notifications': {
      'en': 'Notifications',
      'id': 'Notifikasi',
      'zh': '通知',
    },
    'appearance': {
      'en': 'Appearance',
      'id': 'Tampilan',
      'zh': '外观',
    },
    'support_section': {
      'en': 'SUPPORT',
      'id': 'DUKUNGAN',
      'zh': '支持',
    },
    'help_center': {
      'en': 'Help Center',
      'id': 'Pusat Bantuan',
      'zh': '帮助中心',
    },
    'privacy_policy': {
      'en': 'Privacy Policy',
      'id': 'Kebijakan Privasi',
      'zh': '隐私政策',
    },
    'about_app': {
      'en': 'About App',
      'id': 'Tentang Aplikasi',
      'zh': '关于应用',
    },

    // Edit Personal Info Screen
    'edit_info_title': {
      'en': 'Edit Personal Info',
      'id': 'Edit Informasi Pribadi',
      'zh': '编辑个人信息',
    },
    'change_photo': {
      'en': 'Change Photo',
      'id': 'Ubah Foto',
      'zh': '更换照片',
    },
    'cashier_id_field': {
      'en': 'Cashier ID',
      'id': 'ID Kasir',
      'zh': '收银员 ID',
    },
    'position_field': {
      'en': 'Position',
      'id': 'Jabatan',
      'zh': '职位',
    },
    'location_field': {
      'en': 'Store Location',
      'id': 'Lokasi Toko',
      'zh': '门店位置',
    },

    // Change Password Screen
    'change_password_title': {
      'en': 'Change Password',
      'id': 'Ubah Kata Sandi',
      'zh': '修改密码',
    },
    'change_password_desc': {
      'en': 'Please enter your current password and choose a new one. Your new password must meet the security requirements below.',
      'id': 'Silakan masukkan kata sandi Anda saat ini dan pilih kata sandi baru. Kata sandi baru Anda harus memenuhi persyaratan keamanan di bawah ini.',
      'zh': '请输入您当前的密码并选择新密码。您的新密码必须满足以下安全要求。',
    },
    'current_password': {
      'en': 'Current Password',
      'id': 'Kata Sandi Saat Ini',
      'zh': '当前密码',
    },
    'new_password': {
      'en': 'New Password',
      'id': 'Kata Sandi Baru',
      'zh': '新密码',
    },
    'confirm_new_password': {
      'en': 'Confirm New Password',
      'id': 'Konfirmasi Kata Sandi Baru',
      'zh': '确认新密码',
    },
    'password_req_title': {
      'en': 'Password Requirements',
      'id': 'Persyaratan Kata Sandi',
      'zh': '密码要求',
    },
    'req_min_length': {
      'en': 'At least 8 characters long',
      'id': 'Minimal 8 karakter',
      'zh': '至少 8 个字符',
    },
    'req_uppercase': {
      'en': 'Contains at least one uppercase letter',
      'id': 'Mengandung minimal satu huruf kapital',
      'zh': '包含至少一个大写字母',
    },
    'req_number': {
      'en': 'Contains at least one number',
      'id': 'Mengandung minimal satu angka',
      'zh': '包含至少一个数字',
    },
    'save_password_btn': {
      'en': 'Save Password',
      'id': 'Simpan Kata Sandi',
      'zh': '保存密码',
    },

    // Security Settings Screen
    'security_title': {
      'en': 'Security Settings',
      'id': 'Pengaturan Keamanan',
      'zh': '安全设置',
    },
    'two_fa_title': {
      'en': 'Two-Factor Authentication',
      'id': 'Otentikasi Dua Faktor (2FA)',
      'zh': '双重身份验证 (2FA)',
    },
    'two_fa_desc': {
      'en': 'Add an extra layer of security to your account.',
      'id': 'Tambahkan lapisan keamanan ekstra untuk akun Anda.',
      'zh': '为您的账户添加额外的一层安全保护。',
    },
    'biometric_title': {
      'en': 'Biometric Login',
      'id': 'Login Biometrik',
      'zh': '生物识别登录',
    },
    'biometric_desc': {
      'en': 'Use Fingerprint or Face ID to login faster.',
      'id': 'Gunakan Sidik Jari atau Face ID untuk masuk lebih cepat.',
      'zh': '使用指纹或面容 ID 更快地登录。',
    },
    'login_activity_title': {
      'en': 'Login Activity',
      'id': 'Aktivitas Login',
      'zh': '登录活动',
    },
    'login_activity_desc': {
      'en': 'Monitor your recent login sessions and locations.',
      'id': 'Pantau sesi login dan lokasi terkini Anda.',
      'zh': '监控您最近的登录会话和位置。',
    },
    'trusted_devices_title': {
      'en': 'Trusted Devices',
      'id': 'Perangkat Terpercaya',
      'zh': '受信任的设备',
    },
    'trusted_devices_desc': {
      'en': "Manage devices that don't require 2FA.",
      'id': 'Kelola perangkat yang tidak memerlukan 2FA.',
      'zh': '管理不需要 2FA 验证的设备。',
    },
    'status_label': {
      'en': 'Status',
      'id': 'Status',
      'zh': '状态',
    },
    'status_on': {
      'en': 'On',
      'id': 'Aktif',
      'zh': '开启',
    },
    'status_off': {
      'en': 'Off',
      'id': 'Nonaktif',
      'zh': '关闭',
    },

    // Language Screen
    'language_subtitle': {
      'en': 'Select your preferred language for the app interface and content. This will not affect the language of user-generated reviews.',
      'id': 'Pilih bahasa pilihan Anda untuk antarmuka dan konten aplikasi. Ini tidak akan memengaruhi bahasa ulasan pengguna.',
      'zh': '选择您偏好的应用界面和内容语言。这不会影响用户生成的评价语言。',
    },

    // Notification Settings Screen
    'notifications_title': {
      'en': 'Notifications',
      'id': 'Notifikasi',
      'zh': '通知设置',
    },
    'sec_order_notifications': {
      'en': 'ORDER NOTIFICATIONS',
      'id': 'NOTIFIKASI PESANAN',
      'zh': '订单通知',
    },
    'item_new_orders': {
      'en': 'New Orders',
      'id': 'Pesanan Baru',
      'zh': '新订单',
    },
    'item_order_cancellations': {
      'en': 'Order Cancellations',
      'id': 'Pembatalan Pesanan',
      'zh': '订单取消',
    },
    'item_special_requests': {
      'en': 'Special Requests',
      'id': 'Permintaan Khusus',
      'zh': '特殊要求',
    },
    'sec_shift_updates': {
      'en': 'SHIFT UPDATES',
      'id': 'PEMBARUAN SHIFT',
      'zh': '班次更新',
    },
    'item_schedule_changes': {
      'en': 'Schedule Changes',
      'id': 'Perubahan Jadwal',
      'zh': '日程变更',
    },
    'item_shift_reminders': {
      'en': 'Shift Reminders',
      'id': 'Pengingat Shift',
      'zh': '班次提醒',
    },
    'item_staff_announcements': {
      'en': 'Staff Announcements',
      'id': 'Pengumuman Staf',
      'zh': '员工公告',
    },
    'sec_system': {
      'en': 'SYSTEM',
      'id': 'SISTEM',
      'zh': '系统',
    },
    'item_security_alerts': {
      'en': 'Security Alerts',
      'id': 'Peringatan Keamanan',
      'zh': '安全警报',
    },
    'item_app_updates': {
      'en': 'App Updates',
      'id': 'Pembaruan Aplikasi',
      'zh': '应用更新',
    },

    // Help Center Screen
    'help_center_title': {
      'en': 'Help Center',
      'id': 'Pusat Bantuan',
      'zh': '帮助中心',
    },
    'search_faq_hint': {
      'en': 'Search help or FAQ...',
      'id': 'Cari bantuan atau FAQ...',
      'zh': '搜索帮助或常见问题...',
    },
    'popular_categories': {
      'en': 'Popular Categories',
      'id': 'Kategori Populer',
      'zh': '热门类别',
    },
    'cat_order_issues': {
      'en': 'Order Issues',
      'id': 'Masalah Pesanan',
      'zh': '订单问题',
    },
    'cat_shift_mgmt': {
      'en': 'Shift Management',
      'id': 'Manajemen Shift',
      'zh': '班次管理',
    },
    'cat_account_security': {
      'en': 'Account & Security',
      'id': 'Akun & Keamanan',
      'zh': '账户与安全',
    },
    'cat_app_technical': {
      'en': 'App Technical',
      'id': 'Teknis Aplikasi',
      'zh': '应用技术',
    },
    'popular_faqs': {
      'en': 'Popular FAQs',
      'id': 'FAQ Terpopuler',
      'zh': '常见问题',
    },
    'faq_1_q': {
      'en': 'How to change shifts?',
      'id': 'Bagaimana cara mengganti shift?',
      'zh': '如何更换班次？',
    },
    'faq_1_a': {
      'en': "To change shifts, open the Schedule menu, select the shift you want to change, then tap 'Request Shift Change'. Wait for approval from your manager.",
      'id': "Untuk mengganti shift, buka menu Jadwal, pilih shift yang ingin Anda ganti, lalu ketuk opsi 'Ajukan Penggantian Shift'. Tunggu persetujuan dari manajer Anda.",
      'zh': "要更换班次，请打开“日程”菜单，选择您要更换的班次，然后点击“申请更换班次”。等待经理解批。",
    },
    'faq_2_q': {
      'en': 'Why is the receipt printer not printing?',
      'id': 'Mengapa printer kasir tidak mencetak?',
      'zh': '为什么小票打印机无法打印？',
    },
    'faq_2_a': {
      'en': 'Make sure the printer is connected to the same Wi-Fi network as your cashier device. Also check if receipt paper is still available and the printer cover is securely closed.',
      'id': 'Pastikan printer terhubung ke jaringan Wi-Fi yang sama dengan perangkat kasir Anda. Periksa juga apakah kertas struk masih tersedia dan tutup printer tertutup rapat.',
      'zh': '请确保打印机已连接到与收银设备相同的 Wi-Fi 网络。还要检查热敏纸是否充足，以及打印机盖是否已盖紧。',
    },
    'faq_3_q': {
      'en': 'How to view transaction history?',
      'id': 'Cara melihat riwayat transaksi',
      'zh': '如何查看交易历史记录？',
    },
    'faq_3_a': {
      'en': "Open the 'History' tab on the main menu. You can filter transactions by date, payment status, or cashier name.",
      'id': "Buka tab 'Riwayat' pada menu utama. Anda dapat memfilter transaksi berdasarkan tanggal, status pembayaran, atau nama kasir.",
      'zh': "在主菜单上打开“历史记录”选项卡。您可以按日期、支付状态或收银员姓名筛选交易。",
    },
    'need_more_help': {
      'en': 'Need more help?',
      'id': 'Butuh bantuan lebih lanjut?',
      'zh': '需要更多帮助？',
    },
    'contact_support': {
      'en': 'Contact Support',
      'id': 'Hubungi Support',
      'zh': '联系支持',
    },
    'live_chat': {
      'en': 'Live Chat',
      'id': 'Chat Langsung',
      'zh': '在线客服',
    },

    // Appearance Settings Screen
    'appearance_title': {
      'en': 'Appearance',
      'id': 'Tampilan',
      'zh': '外观设置',
    },
    'sec_theme_mode': {
      'en': 'THEME MODE',
      'id': 'MODE TEMA',
      'zh': '主题模式',
    },
    'theme_light': {
      'en': 'Light Mode',
      'id': 'Mode Terang',
      'zh': '浅色模式',
    },
    'theme_dark': {
      'en': 'Dark Mode',
      'id': 'Mode Gelap',
      'zh': '深色模式',
    },
    'theme_system': {
      'en': 'System',
      'id': 'Sistem',
      'zh': '系统默认',
    },
    'follow_device': {
      'en': 'Follow device',
      'id': 'Ikuti perangkat',
      'zh': '跟随系统',
    },
    'sec_visual_pref': {
      'en': 'VISUAL PREFERENCES',
      'id': 'PREFERENSI VISUAL',
      'zh': '视觉偏好',
    },
    'high_contrast_title': {
      'en': 'High Contrast Mode',
      'id': 'Mode Kontras Tinggi',
      'zh': '高对比度模式',
    },
    'high_contrast_desc': {
      'en': 'Enhance text readability and element borders.',
      'id': 'Tingkatkan keterbacaan teks dan batas elemen.',
      'zh': '增强文本可读性和元素边框。',
    },
    'battery_saver_title': {
      'en': 'Battery Saver Mode',
      'id': 'Mode Penghemat Baterai',
      'zh': '省电模式',
    },
    'battery_saver_desc': {
      'en': 'Reduce animations and background effects.',
      'id': 'Kurangi animasi dan efek latar belakang.',
      'zh': '减少动画和背景效果。',
    },
    'sec_text_size': {
      'en': 'TEXT SIZE',
      'id': 'UKURAN TEKS',
      'zh': '字体大小',
    },
    'size_small': {
      'en': 'Small',
      'id': 'Kecil',
      'zh': '小',
    },
    'size_default': {
      'en': 'Default',
      'id': 'Default',
      'zh': '默认',
    },
    'size_large': {
      'en': 'Large',
      'id': 'Besar',
      'zh': '大',
    },
    'sec_color_palette': {
      'en': 'COLOR PALETTE PRESET',
      'id': 'PALET WARNA TEMA',
      'zh': '主题调色板预设',
    },
    'palette_coffee_title': {
      'en': 'Warm Caramel & Latte',
      'id': 'Caramel Warm & Latte',
      'zh': '暖焦糖与拿铁',
    },
    'palette_coffee_desc': {
      'en': 'Rich roasted coffee, warm amber & creamy gold',
      'id': 'Espresso cokelat kaya, amber hangat & krem emas',
      'zh': '浓郁烘焙咖啡、暖琥珀与奶香金',
    },
    'palette_emerald_title': {
      'en': 'Matcha Botanica & Mint',
      'id': 'Matcha Botanica & Mint',
      'zh': '抹茶植物与薄荷',
    },
    'palette_emerald_desc': {
      'en': 'Deep forest emerald, fresh mint & pearl white',
      'id': 'Hijau emerald deep forest & mint segar',
      'zh': '深林翡翠、新鲜薄荷与珍珠白',
    },
    'palette_berry_title': {
      'en': 'Berry Velvet & Ruby',
      'id': 'Berry Velvet & Ruby Mocha',
      'zh': '浆果丝绒与红宝石',
    },
    'palette_berry_desc': {
      'en': 'Imperial velvet burgundy & coral rose',
      'id': 'Burgundy beludru mewah & coral rose',
      'zh': '帝国丝绒酒红与珊瑚玫瑰',
    },
    'palette_obsidian_title': {
      'en': 'Midnight Obsidian Luxury',
      'id': 'Midnight Obsidian Luxury',
      'zh': '深夜黑曜石奢华',
    },
    'palette_obsidian_desc': {
      'en': 'Midnight onyx, electric indigo & warm gold',
      'id': 'Onyx gelap malam, indigo elektrik & emas hangat',
      'zh': '深夜黑曜石、电光靛蓝与暖金',
    },
    'preview_quote': {
      'en': '"The hearth is the heart of the home, warming both hands and spirit."',
      'id': '"Tungku adalah jantung rumah, menghangatkan tangan dan jiwa."',
      'zh': '“炉膛是家的心脏，温暖双手与心灵。”',
    },
  };
}
