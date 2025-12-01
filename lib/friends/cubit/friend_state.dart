import 'package:locket_beta/model/friend_model.dart';

abstract class FriendState {}

class FriendInitial extends FriendState {}

class FriendLoading extends FriendState {}

class FriendLoaded extends FriendState {
  final List<Friend> friends;
  FriendLoaded(this.friends);
}

class FriendError extends FriendState {
  final String message;
  FriendError(this.message);
}
