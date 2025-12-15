import 'package:dio/dio.dart';
import 'package:jar_talk/services/dio_client.dart';

class InviteService {
  final Dio _dio = DioClient.instance.dio;

  // POST /invites
  Future<Map<String, dynamic>> createInvite({
    required int containerId,
    int? expiresInHours,
    int? maxUses,
  }) async {
    try {
      final response = await _dio.post(
        '/invites',
        data: {
          'container_id': containerId,
          'expires_in_hours': expiresInHours, // null ok
          'max_uses': maxUses, // null ok
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to create invite: $e');
    }
  }

  // GET /invites/container/{container_id}
  Future<List<Map<String, dynamic>>> getContainerInvites(
    int containerId,
  ) async {
    try {
      final response = await _dio.get('/invites/container/$containerId');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load invites: $e');
    }
  }

  // POST /invites/join?code=...
  Future<void> joinByCode(String code) async {
    try {
      await _dio.post('/invites/join', queryParameters: {'code': code});
    } catch (e) {
      // Pass the specific error message if possible
      if (e is DioException && e.response != null) {
        throw Exception(e.response?.data['detail'] ?? 'Failed to join jar');
      }
      throw Exception('Failed to join jar: $e');
    }
  }

  // DELETE /invites/{invite_id}
  Future<void> deactivateInvite(int inviteId) async {
    try {
      await _dio.delete('/invites/$inviteId');
    } catch (e) {
      throw Exception('Failed to deactivate invite: $e');
    }
  }
}
