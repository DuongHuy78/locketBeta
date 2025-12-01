import 'package:dio/dio.dart';
import 'package:locket_beta/model/friend_request_model.dart';

class FriendRequestApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

  // Lấy danh sách yêu cầu kết bạn
  Future<List<FriendRequest>> getFriendRequests(String userId) async {
    try {
      final response = await _dio.get('/api/friend-requests/$userId');
      return (response.data as List)
          .map((e) => FriendRequest.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load friend requests: $e');
    }
  }

  // Gửi lời mời kết bạn
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    try {
      await _dio.post('/api/friend-requests', data: {
        'senderId': senderId,
        'receiverId': receiverId,
      });
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  // Chấp nhận yêu cầu kết bạn
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _dio.patch('/api/friend-requests/accept/$requestId');
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  // Từ chối yêu cầu kết bạn
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _dio.patch('/api/friend-requests/reject/$requestId');
    } catch (e) {
      throw Exception('Failed to reject friend request: $e');
    }
  }
}
