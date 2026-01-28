import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../location/location_provider.dart';

final homeSectionsProvider = FutureProvider<List<dynamic>>((ref) async {
  // Trigger refresh when location changes
  ref.watch(selectedLocationProvider);
  
  final api = ApiClient();
  final response = await api.client.get('/home');
  return response.data['sections'] as List<dynamic>;
});
