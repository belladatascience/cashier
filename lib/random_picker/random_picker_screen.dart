import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cashier/9FondasiProject/constants/app_colors.dart';
import 'package:cashier/CASHIER/utils/app_theme.dart';
import 'package:cashier/random_picker/picker_logic.dart';
import 'package:cashier/utils/button.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RandomPickerScreen extends StatefulWidget {
  const RandomPickerScreen({super.key});

  @override
  State<RandomPickerScreen> createState() => _RandomPickerScreenState();
}

class _RandomPickerScreenState extends State<RandomPickerScreen> {
  List<String> allNames = [];
  List<String> availableNames = [];
  List<String> eliminatedNames = [];
  String selectedName = kPickerPlaceholder;
  bool isPicking = false;
  bool isLoadingCloud = true;
  bool isCloudSynced = false;

  final Random random = Random();
  Timer? _timer;
  int _animationKey = 0;
  late ConfettiController confettiController;
  StreamSubscription<PickerState?>? _cloudSubscription;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    _initState();
  }

  Future<void> _initState() async {
    setState(() => isLoadingCloud = true);

    // 1. Coba ambil daftar nama staf dari Firebase Firestore lebih dahulu
    final firebaseNames = await FirebasePickerService.instance.fetchStaffNamesFromFirebase();
    if (firebaseNames.isNotEmpty) {
      allNames = firebaseNames;
      isCloudSynced = true;
    } else {
      // Fallback ke assets/names.json jika belum ada staf di Firestore
      await _loadNamesFromAssets();
    }

    // 2. Coba muat state dari Firebase Firestore
    final cloudState = await FirebasePickerService.instance.loadStateFromFirebase(
      fallbackNames: allNames,
    );

    if (cloudState != null && (cloudState.availableNames.isNotEmpty || cloudState.eliminatedNames.isNotEmpty)) {
      if (mounted) {
        setState(() {
          selectedName = cloudState.selectedName;
          availableNames = List<String>.from(cloudState.availableNames);
          eliminatedNames = List<String>.from(cloudState.eliminatedNames);
          isLoadingCloud = false;
        });
      }
    } else {
      // Fallback ke SharedPreferences lokal
      await _loadSavedLocalState();
      if (mounted) {
        setState(() => isLoadingCloud = false);
      }
    }

    // 3. Pasang realtime stream listener jika diperlukan
    _listenToCloudState();
  }

  void _listenToCloudState() {
    _cloudSubscription?.cancel();
    _cloudSubscription = FirebasePickerService.instance.streamState().listen((remoteState) {
      if (remoteState != null && !isPicking && mounted) {
        // Hanya update jika berbeda dengan state lokal saat tidak sedang animasi mengundi
        if (remoteState.selectedName != selectedName ||
            remoteState.availableNames.length != availableNames.length ||
            remoteState.eliminatedNames.length != eliminatedNames.length) {
          setState(() {
            selectedName = remoteState.selectedName;
            availableNames = List<String>.from(remoteState.availableNames);
            eliminatedNames = List<String>.from(remoteState.eliminatedNames);
            isCloudSynced = true;
          });
        }
      }
    });
  }

  Future<void> _loadNamesFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/names.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      allNames = List<String>.from(jsonData["names"]);
      if (availableNames.isEmpty && eliminatedNames.isEmpty) {
        setState(() {
          availableNames = List<String>.from(allNames);
        });
      }
    } catch (e) {
      debugPrint('Error loading names from assets: $e');
      allNames = ['Barista 1', 'Barista 2', 'Kasir Utama', 'Store Manager'];
      if (availableNames.isEmpty) {
        availableNames = List<String>.from(allNames);
      }
    }
  }

  Future<void> _loadSavedLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = <String, dynamic>{};
      final storedSelected = prefs.getString(kSelectedNameKey);
      final storedAvailable = prefs.getStringList(kAvailableNamesKey);
      final storedEliminated = prefs.getStringList(kEliminatedNamesKey);
      if (storedSelected != null) payload[kSelectedNameKey] = storedSelected;
      if (storedAvailable != null) payload[kAvailableNamesKey] = storedAvailable;
      if (storedEliminated != null) {
        payload[kEliminatedNamesKey] = storedEliminated;
      }

      final state = loadPickerState(payload.isEmpty ? null : payload, allNames);
      if (mounted) {
        setState(() {
          selectedName = state.selectedName;
          availableNames = List<String>.from(state.availableNames);
          eliminatedNames = List<String>.from(state.eliminatedNames);
        });
      }
    } catch (e) {
      debugPrint('Error loading local state: $e');
    }
  }

  Future<void> _saveState() async {
    final currentState = _currentPickerState();

    // 1. Simpan ke Firebase Cloud Firestore
    FirebasePickerService.instance.saveStateToFirebase(currentState);

    // 2. Simpan ke Local SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = buildPersistencePayload(currentState);
      await prefs.setString(
        kSelectedNameKey,
        payload[kSelectedNameKey] as String,
      );
      await prefs.setStringList(
        kAvailableNamesKey,
        payload[kAvailableNamesKey] as List<String>,
      );
      await prefs.setStringList(
        kEliminatedNamesKey,
        payload[kEliminatedNamesKey] as List<String>,
      );
    } catch (_) {
      Fluttertoast.showToast(msg: "Gagal menyimpan data lokal");
    }
  }

  PickerState _currentPickerState() {
    return PickerState(
      availableNames: availableNames,
      eliminatedNames: eliminatedNames,
      selectedName: selectedName,
      isPicking: isPicking,
    );
  }

  void pickRandomName() {
    if (availableNames.isEmpty || isPicking) return;

    setState(() {
      isPicking = true;
    });

    int count = 0;
    const int totalCycles = 20;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        selectedName = availableNames[random.nextInt(availableNames.length)];
        _animationKey++;
      });

      count++;
      if (count >= totalCycles) {
        timer.cancel();
        confettiController.play();
        _finalizePick();
      }
    });
  }

  void _finalizePick() {
    if (availableNames.isEmpty) return;

    final winner = availableNames.removeAt(
      random.nextInt(availableNames.length),
    );
    eliminatedNames.insert(0, winner);

    setState(() {
      selectedName = winner;
      isPicking = false;
    });

    // Catat histori pemenang ke Firebase Firestore
    FirebasePickerService.instance.logPickWinnerToFirebase(
      winnerName: winner,
      pickMode: 'auto_random',
      eventTitle: 'Undian Acak Kasir & Shift',
    );

    _saveState();
  }

  void pickManualName(String name) {
    final current = _currentPickerState();
    final next = manualPick(current, name);
    if (next != current) {
      finalizeManualPick(name);
    }
  }

  void finalizeManualPick(String name) {
    final result = manualPick(_currentPickerState(), name);
    if (result == _currentPickerState()) return;

    setState(() {
      availableNames = List<String>.from(result.availableNames);
      eliminatedNames = List<String>.from(result.eliminatedNames);
      selectedName = result.selectedName;
    });

    confettiController.play();

    // Catat histori pemenang manual ke Firebase Firestore
    FirebasePickerService.instance.logPickWinnerToFirebase(
      winnerName: name,
      pickMode: 'manual_pick',
      eventTitle: 'Pemilihan Manual Staf / Kasir',
    );

    _saveState();
  }

  void showManualPickSelector() {
    if (isPicking || availableNames.isEmpty) return;

    final names = List<String>.from(availableNames);
    final theme = AppTheme.instance;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          key: const Key('manualPickSelector'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: theme.secondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "Pilih Nama Secara Manual",
                      style: GoogleFonts.sourceSerif4(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    final name = names[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.secondaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: theme.secondaryColor,
                        ),
                      ),
                      title: Text(
                        name,
                        style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        pickManualName(name);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void resetPicker() {
    setState(() {
      availableNames = List<String>.from(allNames);
      eliminatedNames.clear();
      selectedName = kPickerPlaceholder;
    });
    _saveState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cloudSubscription?.cancel();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.instance;
    final fbUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "Random Picker Cloud",
              style: GoogleFonts.sourceSerif4(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCloudSynced ? Icons.cloud_done : Icons.cloud_queue,
                  color: Colors.white70,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  isCloudSynced ? 'Firebase Synced' : 'Offline / Asset Mode',
                  style: GoogleFonts.workSans(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: theme.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Muat Ulang Staf dari Firebase',
            onPressed: () async {
              Fluttertoast.showToast(msg: 'Memperbarui data staf dari Firebase...');
              await _initState();
            },
          ),
        ],
      ),
      body: isLoadingCloud
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.secondaryColor),
                  const SizedBox(height: 12),
                  Text(
                    'Menghubungkan ke Cloud Firestore...',
                    style: GoogleFonts.workSans(color: theme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Card Tampilan Nama Terpilih
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Card(
                      color: theme.secondaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (fbUser != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Operator: ${fbUser.displayName ?? fbUser.email ?? "Kasir"}',
                                    style: GoogleFonts.workSans(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    selectedName,
                                    key: ValueKey('$selectedName-$_animationKey'),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.sourceSerif4(
                                      fontSize: selectedName == kPickerPlaceholder ? 20 : 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Tersedia: ${availableNames.length} | Terpilih: ${eliminatedNames.length}',
                              style: GoogleFonts.workSans(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tombol Putar Acak
                  SizedBox(
                    width: double.infinity,
                    child: DefaultButton(
                      color: AppColors.primaryColor,
                      text: availableNames.isEmpty
                          ? "Semua nama sudah dipilih"
                          : isPicking
                          ? "Memilih..."
                          : "Pilih Nama (Acak Otomatis)",
                      onPressed: isPicking || availableNames.isEmpty
                          ? null
                          : pickRandomName,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Tombol Pilih Manual
                  SizedBox(
                    width: double.infinity,
                    child: DefaultButton(
                      key: const Key('manualPickButton'),
                      color: theme.secondaryColor,
                      text: "Pilih Manual dari Daftar",
                      onPressed: isPicking || availableNames.isEmpty
                          ? null
                          : showManualPickSelector,
                    ),
                  ),
                  ConfettiWidget(
                    confettiController: confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: [
                      Colors.red,
                      Colors.blue,
                      theme.secondaryColor,
                      theme.primaryColor,
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (eliminatedNames.isNotEmpty)
                    DefaultButton(
                      color: const Color(0xFFBA1A1A),
                      text: "Reset Pilihan",
                      onPressed: resetPicker,
                    ),
                  const SizedBox(height: 16),
                  // Daftar Riwayat yang Sudah Terpilih
                  Expanded(
                    child: eliminatedNames.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada nama yang dipilih sesi ini.',
                              style: GoogleFonts.workSans(
                                color: theme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  "Nama yang sudah terpilih:",
                                  style: GoogleFonts.sourceSerif4(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: eliminatedNames.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      elevation: 0.5,
                                      color: theme.surfaceContainerLow,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: theme.secondaryColor,
                                          child: Text(
                                            "${eliminatedNames.length - index}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          eliminatedNames[index],
                                          style: GoogleFonts.workSans(
                                            fontWeight: FontWeight.w600,
                                            color: theme.onSurfaceColor,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
