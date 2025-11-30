import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/messenger/message/cubit/message_state.dart';
import 'package:locket_beta/model/chat_model.dart';
import 'package:locket_beta/model/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MessageCubit extends Cubit<MessageState> {
  UserShort  currentFriend;
  String chatId;
  String currentUserId;
  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  Timer? _hbTimer;
  MessageCubit({
    required this.currentFriend,
    required this.chatId,
    required this. currentUserId,
  }):super(MessageInitialState()) {
    _connectWebSocket();
  }

  @override
  Future<void> close() {
    // đảm bảo đóng WS khi cubit bị đóng (BlocProvider sẽ gọi close())
    _cleanupSocket();
    return super.close();
  }

  void _connectWebSocket() {
    if(_channel != null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8000?userId=$currentUserId'),
    );

    _sendPresence('online');
    _startHeartbeat();

    // Lắng nghe messages từ server — lưu subscription để cancel sau này
    _wsSub = _channel!.stream.listen((message) {
      
      print("Da stream voi server message");
      // Parse message từ JSON
      final data = jsonDecode(message);
      if (data is! Map<String, dynamic>) return;
      if(data['event'] == 'message') {
        final payload = data['message'];
        final newMessage = MessageModel.fromJson(payload, currentUserId: currentUserId);
      
        // Emit state mới (thêm message vào list hiện tại)
        if (state is MessageLoadedState) {
          final current = List<MessageModel>.from((state as MessageLoadedState).messengers);
          // tránh duplicate nếu server gửi lại message đã có (kiểm tra theo id nếu có)
          final exists = current.any((m) => m.id == newMessage.id);
          if (!exists) {
            current.insert(0, newMessage);
            emit((state as MessageLoadedState).copyWith(messengers: current));
          }
        } else {
          emit(MessageLoadedState(messengers: [newMessage]));
        }
        return;
      }

      else if (data['event'] == 'presence_update') {
        final status = (data['status'] ?? '').toString();
        print("DEBUG: receiverStatus: " + status);
        if (state is MessageLoadedState) {
          final current = List<MessageModel>.from((state as MessageLoadedState).messengers);
          emit((state as MessageLoadedState).copyWith(messengers: current, receiverStatus: status));
        } else {
          emit(MessageLoadedState(messengers: [], receiverStatus: status));
        }
        return;
      }

      //Đóng kết nối an toàn = cancel subscription + channel.sink.close().
    }, onDone: () {
      _cleanupSocket();
    }, onError: (error) {
      _cleanupSocket();
      emit(MessageErrorState());
    });
  }

  void _cleanupSocket() { 
    try { _sendPresence('offline'); } catch (_) {}
    _stopHeartbeat();
    try { _wsSub?.cancel(); } catch (_) {}
    try { _channel?.sink.close(); } catch (_) {}
    _wsSub = null;
    _channel = null;
  }

  void disconnect() => _cleanupSocket();

  void _sendPresence(String status) {
    if (_channel == null) return;
    final payload = jsonEncode({
      'event': 'presence',
      'userId': currentUserId,
      'status': status, // 'online' | 'heartbeat' | 'away' | 'offline'
      'timeSend' : DateTime.now().toIso8601String(),
    });
    try {
      _channel!.sink.add(payload);
    } catch (_) {}
  }

  void _startHeartbeat() {
    _hbTimer?.cancel();
    _hbTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _sendPresence('heartbeat');
    });
  }

  void _stopHeartbeat() {
    _hbTimer?.cancel();
    _hbTimer = null;
  }

  void sendMessage(String content) {
    if (_channel != null) {
      final message = {
        'chatId': chatId,
        'senderId': currentUserId,
        'content': content,
        'type': 'text',
      };
      _channel!.sink.add(jsonEncode(message)); // gửi qua WS
    }
  }

    Future<List<MessageModel>> loadMessage() async {
      Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000"));
    try {
      final response = await dio.get('/api/messages/$chatId');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> items = [];
        //tại sao lại cần đoạn này
        if (data == null) {
          items = [];
        } else if (data is List) {
          items = data;
        } else if (data is Map) {
          if (data['messages'] is List) {
            items = List.from(data['messages']);
          } else if (data['data'] is List) {
            items = List.from(data['data']);
          } else {
            items = [data];
          }
        } else {
          try {
            items = List.from(data);
          } catch (_) {
            items = [];
          }
        }

        return items
            .where((e) => e != null)
            .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map), currentUserId: currentUserId))
            .toList();
      }
    } catch (e) {
      print("Loi: "+ e.toString());
      emit(MessageErrorState());
    }
    return [];
  }

  Future<void> deleteMessage(String idMess) async {
    Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:8000"));
    try {
      final res = await dio.delete("/api/messages/$idMess");
      if(res.statusCode == 200) {
        await loadData();
      }
      else {
        emit(MessageErrorState());
      }
    }
    catch(e) {
      print("Loi: "+ e.toString());
      emit(MessageErrorState());
    }
  }

  Future<void> loadData() async {
    emit(MessageLoadingState());
    try {
      final messages = await loadMessage();
      emit(MessageLoadedState(messengers: messages));
    } catch (e) {
      emit(MessageErrorState());
    }
  }

}