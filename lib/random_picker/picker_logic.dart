library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

const String kPickerPlaceholder = 'Tekan tombol untuk memilih';

/// Model status state untuk Random Picker
class PickerState {
  final List<String> availableNames;
  final List<String> eliminatedNames;
  final String selectedName;
  final bool isPicking;
  final DateTime? lastUpdated;

  PickerState({
    List<String>? availableNames,
    List<String>? eliminatedNames,
    this.selectedName = kPickerPlaceholder,
    this.isPicking = false,
    this.lastUpdated,
  }) : availableNames = List<String>.unmodifiable(availableNames ?? const []),
       eliminatedNames = List<String>.unmodifiable(eliminatedNames ?? const []);

  PickerState copyWith({
    List<String>? availableNames,
    List<String>? eliminatedNames,
    String? selectedName,
    bool? isPicking,
    DateTime? lastUpdated,
  }) {
    return PickerState(
      availableNames: availableNames ?? this.availableNames,
      eliminatedNames: eliminatedNames ?? this.eliminatedNames,
      selectedName: selectedName ?? this.selectedName,
      isPicking: isPicking ?? this.isPicking,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PickerState &&
        _listEquals(other.availableNames, availableNames) &&
        _listEquals(other.eliminatedNames, eliminatedNames) &&
        other.selectedName == selectedName &&
        other.isPicking == isPicking;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(availableNames),
    Object.hashAll(eliminatedNames),
    selectedName,
    isPicking,
  );

  @override
  String toString() {
    return 'PickerState('
        'availableNames: $availableNames, '
        'eliminatedNames: $eliminatedNames, '
        'selectedName: $selectedName, '
        'isPicking: $isPicking, '
        'lastUpdated: $lastUpdated)';
  }
}

bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

PickerState manualPick(PickerState state, String name) {
  if (state.isPicking ||
      state.availableNames.isEmpty ||
      !state.availableNames.contains(name)) {
    return state;
  }

  final newAvailable = List<String>.from(state.availableNames);
  final newEliminated = List<String>.from(state.eliminatedNames);

  newAvailable.remove(name);
  newEliminated.insert(0, name);

  return state.copyWith(
    availableNames: newAvailable,
    eliminatedNames: newEliminated,
    selectedName: name,
    lastUpdated: DateTime.now(),
  );
}

PickerState resetState(PickerState state, List<String> allNames) {
  return state.copyWith(
    availableNames: List<String>.from(allNames),
    eliminatedNames: const <String>[],
    selectedName: kPickerPlaceholder,
    lastUpdated: DateTime.now(),
  );
}

/// Persistence keys used when serializing [PickerState] to/from storage / Firebase.
const String kSelectedNameKey = 'selectedName';
const String kAvailableNamesKey = 'availableNames';
const String kEliminatedNamesKey = 'eliminatedNames';
const String kIsPickingKey = 'isPicking';
const String kLastUpdatedKey = 'lastUpdated';

/// Builds a JSON-friendly persistence payload from [state].
Map<String, dynamic> buildPersistencePayload(PickerState state) {
  return <String, dynamic>{
    kSelectedNameKey: state.selectedName,
    kAvailableNamesKey: List<String>.from(state.availableNames),
    kEliminatedNamesKey: List<String>.from(state.eliminatedNames),
    kIsPickingKey: state.isPicking,
    kLastUpdatedKey: state.lastUpdated?.toIso8601String() ?? DateTime.now().toIso8601String(),
  };
}

/// Attempts to reconstruct a [PickerState] from a persistence [payload].
PickerState? pickerStateFromPayload(Map<String, dynamic>? payload) {
  if (payload == null) return null;
  if (!payload.containsKey(kSelectedNameKey) ||
      !payload.containsKey(kAvailableNamesKey) ||
      !payload.containsKey(kEliminatedNamesKey)) {
    return null;
  }

  final dynamic rawSelected = payload[kSelectedNameKey];
  if (rawSelected is! String) return null;

  final List<String>? available = _asStringList(payload[kAvailableNamesKey]);
  final List<String>? eliminated = _asStringList(payload[kEliminatedNamesKey]);
  if (available == null || eliminated == null) return null;

  DateTime? updated;
  if (payload[kLastUpdatedKey] is String) {
    updated = DateTime.tryParse(payload[kLastUpdatedKey] as String);
  } else if (payload[kLastUpdatedKey] is Timestamp) {
    updated = (payload[kLastUpdatedKey] as Timestamp).toDate();
  }

  return PickerState(
    availableNames: available,
    eliminatedNames: eliminated,
    selectedName: rawSelected,
    isPicking: payload[kIsPickingKey] == true,
    lastUpdated: updated,
  );
}

/// Loads a [PickerState] from a persistence [payload], falling back safely.
PickerState loadPickerState(
  Map<String, dynamic>? payload,
  List<String> allNames,
) {
  if (payload != null && payload.isNotEmpty) {
    final PickerState? restored = pickerStateFromPayload(payload);
    if (restored != null) {
      return restored;
    }
  }
  return PickerState(
    availableNames: List<String>.from(allNames),
    eliminatedNames: const <String>[],
    selectedName: kPickerPlaceholder,
  );
}

/// Coerces [value] into a `List<String>` when possible, otherwise `null`.
List<String>? _asStringList(dynamic value) {
  if (value is! List) return null;
  final result = <String>[];
  for (final element in value) {
    if (element is! String) return null;
    result.add(element);
  }
  return result;
}

// =============================================================================
// FIREBASE FIRESTORE & AUTH INTEGRATION SERVICE
// =============================================================================

class FirebasePickerService {
  FirebasePickerService._();
  static final FirebasePickerService instance = FirebasePickerService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser?.uid ?? 'default_session';

  /// Menyimpan status Random Picker ke Cloud Firestore
  Future<void> saveStateToFirebase(PickerState state, {String? customDocId}) async {
    try {
      final docId = customDocId ?? _currentUserId;
      final payload = buildPersistencePayload(state);
      payload['updatedBy'] = _auth.currentUser?.email ?? 'anonymous';
      payload['serverTimestamp'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('random_picker_states')
          .doc(docId)
          .set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirebasePickerService: Error saving state: $e');
    }
  }

  /// Memuat status Random Picker dari Cloud Firestore
  Future<PickerState?> loadStateFromFirebase({
    String? customDocId,
    List<String>? fallbackNames,
  }) async {
    try {
      final docId = customDocId ?? _currentUserId;
      final doc = await _firestore.collection('random_picker_states').doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return pickerStateFromPayload(doc.data());
      }
    } catch (e) {
      debugPrint('FirebasePickerService: Error loading state: $e');
    }

    if (fallbackNames != null && fallbackNames.isNotEmpty) {
      return PickerState(
        availableNames: List<String>.from(fallbackNames),
        eliminatedNames: const <String>[],
        selectedName: kPickerPlaceholder,
      );
    }
    return null;
  }

  /// Real-time stream status Random Picker dari Cloud Firestore
  Stream<PickerState?> streamState({String? customDocId}) {
    final docId = customDocId ?? _currentUserId;
    return _firestore
        .collection('random_picker_states')
        .doc(docId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return pickerStateFromPayload(snapshot.data());
      }
      return null;
    });
  }

  /// Mengambil daftar nama kasir/staf aktif dari Cloud Firestore koleksi 'users'
  Future<List<String>> fetchStaffNamesFromFirebase() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final names = <String>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = data['name'] ??
            data['displayName'] ??
            data['cashierName'] ??
            data['email'];
        if (name != null && name.toString().trim().isNotEmpty) {
          names.add(name.toString().trim());
        }
      }
      if (names.isNotEmpty) {
        names.sort();
        return names;
      }
    } catch (e) {
      debugPrint('FirebasePickerService: Error fetching staff names: $e');
    }
    return [];
  }

  /// Mencatat riwayat pemenang undian / hasil pick ke Cloud Firestore
  Future<void> logPickWinnerToFirebase({
    required String winnerName,
    required String pickMode,
    String? eventTitle,
  }) async {
    try {
      final user = _auth.currentUser;
      await _firestore.collection('picker_history').add({
        'winnerName': winnerName,
        'pickMode': pickMode,
        'eventTitle': eventTitle ?? 'Pengundian Acak Kasir & Shift',
        'operatorUid': user?.uid ?? 'unknown',
        'operatorEmail': user?.email ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('FirebasePickerService: Error logging winner: $e');
    }
  }
}
