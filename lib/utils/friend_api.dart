// import 'package:dio/dio.dart';
// import 'package:locket_beta/model/friend_model.dart';

// class FriendApi {
//   final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

//   Future<List<Friend>> getFriends(String userId) async {
//     try {
//       final response = await _dio.get('/api/friends/$userId');
//       return (response.data as List)
//           .map((json) => Friend.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to load friends: $e');
//     }
//   }

//   Future<Friend> addFriend(Friend friend) async {
//     try {
//       final response = await _dio.post('/api/friends', data: friend.toJson());
//       return Friend.fromJson(response.data);
//     } catch (e) {
//       throw Exception('Failed to add friend: $e');
//     }
//   }

//   Future<void> removeFriend(String friendId) async {
//     try {
//       await _dio.delete('/api/friends/$friendId');
//     } catch (e) {
//       throw Exception('Failed to remove friend: $e');
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:locket_beta/model/friend_model.dart';
import 'package:locket_beta/model/friend_request_model.dart';

class FriendApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

  // Friends
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
      await _dio.delete('/api/friends/$friendId');
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  // Friend Requests
  Future<List<FriendRequest>> getFriendRequests(String userId) async {
    try {
      final response = await _dio.get('/api/friends/requests/$userId');
      return (response.data as List)
          .map((e) => FriendRequest.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to load friend requests: $e');
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _dio.patch('/api/friends/requests/accept/$requestId');
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _dio.patch('/api/friends/requests/reject/$requestId');
    } catch (e) {
      throw Exception('Failed to reject friend request: $e');
    }
  }

  // Recommendations
  Future<List<Friend>> getRecommendations(String userId) async {
    try {
      final response =
          await _dio.get('/api/friends/users/recommendation/$userId');
      return (response.data as List).map((e) => Friend.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load recommendations: $e');
    }
  }
}
