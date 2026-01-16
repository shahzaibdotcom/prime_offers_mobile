import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Location State Notifier
class LocationNotifier extends StateNotifier<Map<String, dynamic>?> {
  LocationNotifier() : super(null) {
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('selected_location_id');
    final name = prefs.getString('selected_location_name');
    if (id != null) {
      state = {'id': id, 'name': name ?? ''};
    }
  }

  Future<void> selectLocation(Map<String, dynamic> location) async {
    state = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_location_id', location['id']);
    await prefs.setString('selected_location_name', location['name']);
  }
}

final selectedLocationProvider = StateNotifierProvider<LocationNotifier, Map<String, dynamic>?>((ref) => LocationNotifier());

// Locations List Provider
final locationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ApiClient();
  final response = await api.client.get('/config');
  return response.data['locations'] as List<dynamic>;
});
