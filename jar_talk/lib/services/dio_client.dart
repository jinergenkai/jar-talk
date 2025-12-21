import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  late Dio _dio;

  // Android Emulator calls localhost via 10.0.2.2
  // For physical device, use your machine's IP
  // final String _baseUrl = "http://192.168.0.100:8000";
  final String _baseUrl = "http://huynhhanh.com:8000";

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Retrieve backend token from storage
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('jwtBackend');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle 401 Unauthorized globally if needed
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
