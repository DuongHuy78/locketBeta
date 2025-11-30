import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/friends/cubit/friend_state.dart';
import 'package:locket_beta/model/friend_model.dart';
import 'package:locket_beta/api/friends/friend_api.dart';
import 'package:locket_beta/utils/local_storage.dart';

class FriendCubit extends Cubit<FriendState> {
  FriendCubit() : super(FriendInitial());

  final FriendApi _api = FriendApi();
  List<Friend> friends = [];

  Future<void> loadFriends() async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception("User not logged in");

      friends = await _api.getFriends(userId);
      emit(FriendLoaded(friends));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> addFriend(Friend friend) async {
    try {
      await _api.addFriend(friend);
      await loadFriends();
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _api.removeFriend(friendId);
      await loadFriends();
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }
}
