import 'package:dio/dio.dart';
import 'package:locket_beta/model/friend_model.dart';
import 'package:locket_beta/utils/local_storage.dart';

class FriendApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

  Future<List<Friend>> getFriends(String userId) async {
    try {
      final response = await _dio.get('/api/friends/$userId');
      return (response.data as List).map((e) => Friend.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load friends: $e');
    }
  }

  Future<Friend> addFriend(Friend friend) async {
    try {
      final response = await _dio.post('/api/friends', data: friend.toJson());
      return Friend.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add friend: $e');
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception("User not logged in");

      await _dio.delete(
        '/api/friends/$friendId',
        data: {'userId': userId},
      );
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }
}
