import 'package:locket_beta/model/message_model.dart';

abstract class MessageState {}

class MessageInitialState extends MessageState {

}

class MessageLoadingState extends MessageState {

}

class MessageLoadedState extends MessageState {
  List<MessageModel> messengers;
  String receiverStatus;

  MessageLoadedState({
    required this.messengers,
    this.receiverStatus = 'Offline'
  });

  MessageLoadedState copyWith({
    List<MessageModel>? messengers,
    String? receiverStatus
  }) {
    return MessageLoadedState(
      messengers: messengers ?? this.messengers,
      receiverStatus: receiverStatus ?? this.receiverStatus
    );
  }
}

class MessageErrorState extends MessageState {

}