import 'package:dio/dio.dart';
import 'package:locket_beta/model/friend_model.dart';

class RecommendationApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

  Future<List<Friend>> getRecommendations(String userId) async {
    try {
      final response = await _dio.get('/api/recommendations/$userId');
      return (response.data as List).map((e) => Friend.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load recommendations: $e');
    }
  }
}
