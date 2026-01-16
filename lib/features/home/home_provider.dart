import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';

final homeSectionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final api = ApiClient();
  final response = await api.client.get('/home');
  return response.data['sections'] as List<dynamic>;
});
