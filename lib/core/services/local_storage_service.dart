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
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
      return [
        {
          'id': 'p1',
          'title': 'Home',
          'address': '2066, Nripen Ghosh Sarani Rd, Kolkata',
          'latitude': 22.50212,
          'longitude': 88.35815,
          'icon': 'home',
        },
        {
          'id': 'p2',
          'title': 'Work',
          'address': 'Salt Lake Sector V, Kolkata',
          'latitude': 22.5735,
          'longitude': 88.4331,
          'icon': 'work',
        },
      ];
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

  // Initial seed rides (per task.md: "hardcode 5–6 past rides with date, pickup, drop, and fare")
  List<Map<String, dynamic>> _getDefaultInitialRides() {
    final initial = [
      {
        'id': 'vybe_ride_001',
        'date': DateTime.now().subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
        'pickup': '2066, Nripen Ghosh Sarani Rd',
        'destination': 'Park Street Metro, Kolkata',
        'stops': <String>[],
        'fare': 185.0,
        'vehicleType': 'Car (Vybe Go)',
        'driverName': 'Rajesh Kumar',
        'vehicleNumber': 'WB 02 AK 9821',
        'paymentMethod': 'UPI (Google Pay)',
        'paymentStatus': 'PAID',
        'rating': 4.9,
      },
      {
        'id': 'vybe_ride_002',
        'date': DateTime.now().subtract(const Duration(days: 2, hours: 5)).toIso8601String(),
        'pickup': 'South City Mall, Prince Anwar Shah Rd',
        'destination': 'Rabindra Sarobar Lake Gate 3',
        'stops': <String>[],
        'fare': 45.0,
        'vehicleType': 'Tirri (E-Rickshaw)',
        'driverName': 'Sunil Mondal',
        'vehicleNumber': 'WB 19 ER 3310',
        'paymentMethod': 'Cash',
        'paymentStatus': 'PAID',
        'rating': 5.0,
      },
      {
        'id': 'vybe_ride_003',
        'date': DateTime.now().subtract(const Duration(days: 4, hours: 8)).toIso8601String(),
        'pickup': 'Nripen Ghosh Sarani Rd',
        'destination': 'Salt Lake Sector V, Technopolis',
        'stops': ['Gariahat Crossing'],
        'fare': 85.0,
        'vehicleType': 'Bike (Vybe Moto)',
        'driverName': 'Amit Roy',
        'vehicleNumber': 'WB 07 BK 4429',
        'paymentMethod': 'Card (HDFC Visa)',
        'paymentStatus': 'PAID',
        'rating': 4.8,
      },
      {
        'id': 'vybe_ride_004',
        'date': DateTime.now().subtract(const Duration(days: 6, hours: 2)).toIso8601String(),
        'pickup': 'Netaji Subhash Chandra Bose Airport',
        'destination': '2066, Nripen Ghosh Sarani Rd',
        'stops': <String>[],
        'fare': 420.0,
        'vehicleType': 'Car (Vybe Prime)',
        'driverName': 'Deepak Sharma',
        'vehicleNumber': 'WB 04 PR 1109',
        'paymentMethod': 'UPI (PhonePe)',
        'paymentStatus': 'PAID',
        'rating': 5.0,
      },
      {
        'id': 'vybe_ride_005',
        'date': DateTime.now().subtract(const Duration(days: 9, hours: 6)).toIso8601String(),
        'pickup': 'Howrah Railway Station Platform 8',
        'destination': 'South City Mall',
        'stops': <String>[],
        'fare': 230.0,
        'vehicleType': 'Car (Vybe Go)',
        'driverName': 'Manoj Sen',
        'vehicleNumber': 'WB 12 TX 7812',
        'paymentMethod': 'Cash',
        'paymentStatus': 'PAID',
        'rating': 4.7,
      },
      {
        'id': 'vybe_ride_006',
        'date': DateTime.now().subtract(const Duration(days: 12, hours: 4)).toIso8601String(),
        'pickup': '2066, Nripen Ghosh Sarani Rd',
        'destination': 'Jadavpur University 8B Bus Stand',
        'stops': <String>[],
        'fare': 30.0,
        'vehicleType': 'Tirri (E-Rickshaw)',
        'driverName': 'Bikas Ghosh',
        'vehicleNumber': 'WB 19 ER 5521',
        'paymentMethod': 'UPI (Paytm)',
        'paymentStatus': 'PAID',
        'rating': 4.9,
      },
    ];
    _prefs.setString(AppConstants.keyRideHistory, jsonEncode(initial));
    return initial;
  }
}
