import 'package:dio/dio.dart';
import 'package:jar_talk/models/jar_model.dart';
import 'package:jar_talk/services/dio_client.dart';

class JarService {
  final Dio _dio = DioClient.instance.dio;

  Future<List<Jar>> getUserJars() async {
    try {
      final response = await _dio.get('/containers');
      final List<dynamic> data = response.data;
      return data.map((json) => Jar.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load jars: $e');
    }
  }

  Future<Jar> getJarDetails(int jarId) async {
    try {
      final response = await _dio.get('/containers/$jarId');
      return Jar.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load jar details: $e');
    }
  }

  Future<Jar> createJar(String name, {String? styleSettings}) async {
    try {
      final response = await _dio.post(
        '/containers',
        data: {
          'name': name,
          if (styleSettings != null) 'jar_style_settings': styleSettings,
        },
      );
      return Jar.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create jar: $e');
    }
  }

  Future<void> deleteJar(int jarId) async {
    try {
      await _dio.delete('/containers/$jarId');
    } catch (e) {
      throw Exception('Failed to delete jar: $e');
    }
  }
}
