import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

// Location State Provider
final selectedLocationProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Locations List Provider
final locationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ApiClient();
  final response = await api.client.get('/config');
  return response.data['locations'] as List<dynamic>;
});
