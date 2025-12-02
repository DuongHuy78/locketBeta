import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/messenger/chat/cubit/chat_state.dart';
import 'package:locket_beta/model/chat_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatCubit extends Cubit<ChatState>{
  String currentUserId;
  WebSocketChannel? _channel;
  final Map<String, Timer> _presenceTimers = {}; // timer per userId
  ChatCubit({
      required this.currentUserId,
  }) :super(ChatInitialState()) {
    _connectWebSocket();
    loadData();
  }

  @override
  Future<void> close() {
    _presenceTimers.values.forEach((t) => t.cancel());
    _presenceTimers.clear();
    return super.close();
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8000?userId=$currentUserId'),
    );

    // Lắng nghe messages từ server
    _channel!.stream.listen((message) {
      // print("Da stream voi server chat");

      // Parse message từ JSON
      final data = jsonDecode(message); // jsonDecode(message) có thể trả String, List, num, hoặc Map tùy payload.
      if (data is! Map<String, dynamic>) return;  // nghĩa là: nếu parsed JSON không phải object (Map) thì bỏ qua message.
      
      if(data['event'] == 'chat_updated') {
        // print("đã nhận được event chat_updated từ server");
        final updatedChat = ChatModel.fromJson(data['chat']);
        if (state is ChatLoadedState) {
          final current = (state as ChatLoadedState);
          final updatedChats = current.chats.map((c) => c.id == updatedChat.id ? updatedChat : c).toList();
          emit(ChatLoadedState(chats: updatedChats, chatFilter: updatedChats));
        }
      } else if (data['event'] == 'presence_update') {
        String status = data['status'];
        String currentFriendId = data['userId'];
        // print("DEBUG: receiverStatus: " + status);

        if (status == 'online' || status == 'heartbeat') {
          if(state is ChatLoadedState) {
            final currentState = state as ChatLoadedState;
            final newMap = Map<String, String>.from(currentState.receiverStatus);
            newMap[currentFriendId] = status;
            emit(currentState.copyWith(receiverStatus: newMap));
          }
        }
        else {
          emit(ChatLoadedState(chats: [], chatFilter: [], receiverStatus: {currentFriendId: status}));
        }

        // manage per-user timer: Nếu online/heartbeat -> đặt lịch offline sau 10s
        _presenceTimers[currentFriendId]?.cancel();
        if (status == 'online' || status == 'heartbeat') {
          _presenceTimers[currentFriendId] = Timer(const Duration(seconds: 10), () {
            // cài offline sau 10s
            if (state is ChatLoadedState) {
              final currentState = state as ChatLoadedState;
              final newMap = Map<String, String>.from(currentState.receiverStatus);
              newMap[currentFriendId] = 'offline';
              emit(currentState.copyWith(receiverStatus: newMap));
            }
            _presenceTimers.remove(currentFriendId);
          });
        } else {
          _presenceTimers.remove(currentFriendId);
          if (state is ChatLoadedState) {
            final currentState = state as ChatLoadedState;
            final newMap = Map<String, String>.from(currentState.receiverStatus);
            newMap[currentFriendId] = 'offline';
            emit(currentState.copyWith(receiverStatus: newMap));
          }
        }
      }

    }, onError: (error) {
      emit(ChatErrorState());
    });
  }

  void loadData() async {
    Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000"));
    emit(ChatLoadingState());
    try {
      final response = await dio.get("/api/chats/$currentUserId");
      if(response.statusCode == 200) {
        final data = response.data;
        
        // Server trả về { chats: [...] }
        final List<dynamic> chatsJson = data['chats'] ?? [];
        
        // Parse danh sách chat từ JSON
        List<ChatModel> chats = chatsJson
            .map((json) {
              // print('Raw chat JSON: $json');
              return ChatModel.fromJson(json as Map<String, dynamic>);
            })
            .toList();
        
        emit(ChatLoadedState(chats: chats, chatFilter: chats,));
      } else {
        emit(ChatErrorState());
      }
    }
    catch(e) {
      emit(ChatErrorState());
    }
  }

    void filter(String query) {
    final current = state;
    if (current is ChatLoadedState) {
      final q = query.trim().toLowerCase();
      final filtered = q.isEmpty
          ? current.chats
          : current.chats.where((m) {
            return m.members.any((member) {
              final username = member.username ?? '';
              final isNotSelf = member.id != currentUserId;
              return username.toLowerCase().contains(q) && isNotSelf ;
            });
          }).toList();

      emit(ChatLoadedState(chats: current.chats, chatFilter: filtered));
    }
  }
}