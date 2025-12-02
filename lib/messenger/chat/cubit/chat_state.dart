import 'package:locket_beta/model/chat_model.dart';

abstract class ChatState {}

class ChatInitialState extends ChatState {

}

class ChatLoadingState extends ChatState {

}

class ChatLoadedState extends ChatState {
  List<ChatModel> chats;
  List<ChatModel> chatFilter;
  Map<String, String> receiverStatus; // userId -> status ('online'|'offline'|'heartbeat'...)


  ChatLoadedState({
    required this.chats,
    required this.chatFilter,
    Map<String, String>? receiverStatus
  }) : receiverStatus = receiverStatus ?? {};

  ChatLoadedState copyWith({
    List<ChatModel>? chats,
    List<ChatModel>? chatFilter,
    Map<String, String>? receiverStatus,
  }) {
    return ChatLoadedState(
      chats: chats ?? this.chats, 
      chatFilter: chatFilter ?? this.chatFilter,
      receiverStatus: receiverStatus ?? Map<String, String>.from(this.receiverStatus),
    );
  }
}

class ChatErrorState extends ChatState {

}