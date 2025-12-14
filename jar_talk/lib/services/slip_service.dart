import 'package:dio/dio.dart';
import 'package:jar_talk/models/slip_model.dart';
import 'package:jar_talk/services/dio_client.dart';

class SlipService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Slip>> getSlips(
    int containerId, {
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/slips',
        queryParameters: {
          'container_id': containerId,
          'skip': skip,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Slip.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load slips: $e');
    }
  }

  Future<Slip> createSlip(
    int containerId,
    String textContent, {
    String? title,
    String? emotion,
    String? locationData,
  }) async {
    try {
      final response = await _dio.post(
        '/slips',
        data: {
          'container_id': containerId,
          'text_content': textContent,
          if (title != null) 'title': title,
          if (emotion != null) 'emotion': emotion,
          if (locationData != null) 'location_data': locationData,
        },
      );
      return Slip.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create slip: $e');
    }
  }
}
