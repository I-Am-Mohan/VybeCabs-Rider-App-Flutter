import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main()');
});

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // --- User Profile ---

  bool get isLoggedIn => _prefs.getBool(AppConstants.keyUserLoggedIn) ?? false;

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(AppConstants.keyUserLoggedIn, value);
  }

  String get userName => _prefs.getString(AppConstants.keyUserName) ?? '';

  Future<void> setUserName(String name) async {
    await _prefs.setString(AppConstants.keyUserName, name);
  }

  String get userPhone => _prefs.getString(AppConstants.keyUserPhone) ?? '';

  Future<void> setUserPhone(String phone) async {
    await _prefs.setString(AppConstants.keyUserPhone, phone);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(AppConstants.keyUserLoggedIn);
  }

  // --- Ride History (Dynamic localstorage) ---

  List<Map<String, dynamic>> getRideHistory() {
    final raw = _prefs.getString(AppConstants.keyRideHistory);
    if (raw == null || raw.isEmpty) {
      return _getDefaultInitialRides();
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      final list =
          decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      // Filter out any legacy pre-seeded mock rides so history starts clean and dynamic
      return list.where((ride) {
        final id = ride['id'] as String? ?? '';
        return !id.startsWith('vybe_ride_00');
      }).toList();
    } catch (_) {
      return _getDefaultInitialRides();
    }
  }

  Future<void> saveRide(Map<String, dynamic> rideData) async {
    final currentList = getRideHistory();
    // Insert at beginning of history
    currentList.insert(0, rideData);
    await _prefs.setString(AppConstants.keyRideHistory, jsonEncode(currentList));
  }

  Future<void> updateRide(String rideId, Map<String, dynamic> updatedData) async {
    final currentList = getRideHistory();
    final index = currentList.indexWhere((element) => element['id'] == rideId);
    if (index != -1) {
      currentList[index] = {...currentList[index], ...updatedData};
      await _prefs.setString(AppConstants.keyRideHistory, jsonEncode(currentList));
    }
  }

  // --- Saved Places ---

  List<Map<String, dynamic>> getSavedPlaces() {
    final raw = _prefs.getString(AppConstants.keySavedPlaces);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePlaces(List<Map<String, dynamic>> places) async {
    await _prefs.setString(AppConstants.keySavedPlaces, jsonEncode(places));
  }

  /// Starts with empty history per user specification.
  /// Completed rides will be added dynamically as trips finish.
  List<Map<String, dynamic>> _getDefaultInitialRides() {
    return [];
  }
}
