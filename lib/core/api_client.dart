import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8001/api',
  );

  static String get baseImageUrl => baseUrl.replaceAll('/api', '');

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    
    String formattedPath = path;
    if (!path.startsWith('storage/') && !path.startsWith('/storage/')) {
      formattedPath = 'storage/${path.startsWith('/') ? path.substring(1) : path}';
    }
    
    return '$baseImageUrl${formattedPath.startsWith('/') ? '' : '/'}$formattedPath';
  }

  final Dio _dio;

  ApiClient()
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        final locationId = prefs.getInt('selected_location_id');
        if (locationId != null) {
          options.headers['X-Location-Id'] = locationId;
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle global errors like 401 Unauthorized
        if (e.response?.statusCode == 401) {
          // Trigger logout if possible
        }
        return handler.next(e);
      },
      onResponse: (response, handler) {
          return handler.next(response);
      }
    ));
  }

  Dio get client => _dio;
}
