import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';

final rideHistoryProvider =
    StateNotifierProvider<RideHistoryController, List<Map<String, dynamic>>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return RideHistoryController(storage);
});

class RideHistoryController extends StateNotifier<List<Map<String, dynamic>>> {
  final LocalStorageService _storage;

  RideHistoryController(this._storage) : super([]) {
    loadHistory();
  }

  void loadHistory() {
    state = _storage.getRideHistory();
  }

  Future<void> addRide(Map<String, dynamic> ride) async {
    await _storage.saveRide(ride);
    loadHistory();
  }
}
