import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/friends/cubit/friendRequest_state.dart';
import 'package:locket_beta/model/friend_request_model.dart';
import 'package:locket_beta/utils/local_storage.dart';
import 'package:locket_beta/api/friends/friendRequest_api.dart';

class FriendRequestCubit extends Cubit<FriendRequestState> {
  FriendRequestCubit() : super(FriendRequestInitial());

  final FriendRequestApi _api = FriendRequestApi();

  List<FriendRequest> requests = [];

  Future<void> loadFriendRequests() async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception("User not logged in");
      requests = await _api.getFriendRequests(userId);
      emit(FriendRequestLoaded(requests));
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }

  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    try {
      await _api.sendFriendRequest(senderId, receiverId);
      await loadFriendRequests();
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }

  Future<void> unsendFriendRequest(String receiverId) async {
    try {
      final senderId = await LocalStorage.getUserId();
      if (senderId == null) throw Exception("User not logged in");
      await _api.unsendFriendRequest(senderId, receiverId);
      await loadFriendRequests();
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _api.acceptFriendRequest(requestId);
      await loadFriendRequests();
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _api.rejectFriendRequest(requestId);
      await loadFriendRequests();
    } catch (e) {
      emit(FriendRequestError(e.toString()));
    }
  }
}
