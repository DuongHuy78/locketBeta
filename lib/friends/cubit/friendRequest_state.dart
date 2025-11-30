import 'package:locket_beta/model/friend_request_model.dart';

abstract class FriendRequestState {}

class FriendRequestInitial extends FriendRequestState {}

class FriendRequestLoading extends FriendRequestState {}

class FriendRequestLoaded extends FriendRequestState {
  final List<FriendRequest> requests;
  FriendRequestLoaded(this.requests);
}

class FriendRequestError extends FriendRequestState {
  final String message;
  FriendRequestError(this.message);
}
