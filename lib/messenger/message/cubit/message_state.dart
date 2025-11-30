import 'package:locket_beta/model/message_model.dart';

abstract class MessageState {}

class MessageInitialState extends MessageState {

}

class MessageLoadingState extends MessageState {

}

class MessageLoadedState extends MessageState {
  List<MessageModel> messengers;
  String receiverStatus;
  String receiverTyping;

  MessageLoadedState({
    required this.messengers,
    this.receiverStatus = 'Offline',
    this.receiverTyping = 'false'
  });

  MessageLoadedState copyWith({
    List<MessageModel>? messengers,
    String? receiverStatus,
    String? receiverTyping
  }) {
    return MessageLoadedState(
      messengers: messengers ?? this.messengers,
      receiverStatus: receiverStatus ?? this.receiverStatus,
      receiverTyping: receiverTyping ?? this.receiverTyping
    );
  }
}

class MessageErrorState extends MessageState {

}