import 'package:locket_beta/model/chat_model.dart';

abstract class ChatState {}

class ChatInitialState extends ChatState {

}

class ChatLoadingState extends ChatState {

}

class ChatLoadedState extends ChatState {
  List<ChatModel> chats;
  List<ChatModel> chatFilter;
  String receiverStatus;

  ChatLoadedState({
    required this.chats,
    required this.chatFilter,
    this.receiverStatus = 'Offline',
  });

  ChatLoadedState copyWith({
    List<ChatModel>? chats,
    List<ChatModel>? chatFilter,
    String? receiverStatus
  }) {
    return ChatLoadedState(
      chats: chats ?? this.chats, 
      chatFilter: chatFilter ?? this.chatFilter,
      receiverStatus: receiverStatus ?? this.receiverStatus
    );
  }
}

class ChatErrorState extends ChatState {

}