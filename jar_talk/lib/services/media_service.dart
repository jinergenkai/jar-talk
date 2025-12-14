import 'package:dio/dio.dart';
import 'package:jar_talk/models/media_model.dart';
import 'package:jar_talk/services/dio_client.dart';

class MediaService {
  final Dio _dio = DioClient.instance.dio;

  /// Request upload URL from backend
  Future<Map<String, dynamic>> getUploadUrl(
    String fileType,
    String contentType,
  ) async {
    try {
      final response = await _dio.post(
        '/media/upload-url',
        data: {'file_type': fileType, 'content_type': contentType},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get upload URL: $e');
    }
  }

  /// Upload file to MinIO (or storage service) using the presigned URL
  Future<void> uploadFileToMinio(
    String uploadUrl,
    List<int> fileData,
    String contentType,
  ) async {
    try {
      // Create a separate Dio instance for direct upload to avoid default interceptors/headers
      // that might conflict with the presigned URL signature (e.g. Authorization header)
      final uploadDio = Dio();

      await uploadDio.put(
        uploadUrl,
        data: Stream.fromIterable([fileData]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileData.length,
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to upload file to storage: $e');
    }
  }

  /// Create media record in backend
  Future<Media> createMediaRecord(
    int slipId,
    String mediaType,
    String storageUrl,
  ) async {
    try {
      final response = await _dio.post(
        '/media',
        data: {
          'slip_id': slipId,
          'media_type': mediaType,
          'storage_url': storageUrl,
        },
      );
      return Media.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create media record: $e');
    }
  }
}
