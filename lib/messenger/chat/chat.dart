import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/messenger/chat/cubit/chat_cubit.dart';
import 'package:locket_beta/messenger/chat/cubit/chat_state.dart';
import 'package:locket_beta/messenger/message/view/message.dart';
import 'package:locket_beta/model/chat_model.dart';

class ChatPage extends StatefulWidget {
  String currentUserId;
  ChatPage({
    super.key,
    required this.currentUserId,
  });
  
  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(currentUserId: widget.currentUserId)..loadData(),
      child: Scaffold(
        backgroundColor: const Color(0xff1d1b20),
        appBar: AppBar(
          title: const Text(
            "Messenger",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xff1d1b20),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state is ChatLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatLoadedState) {
              //Lấy dữ liệu
              List<ChatModel> chats = state.chatFilter;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    child: Column(
                      children: [
                        // Thanh tìm kiếm
                        TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            context.read<ChatCubit>().filter(value);
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xff2a282c),
                            hintText: "Tìm kiếm",
                            hintStyle: TextStyle(color: Colors.grey[350]),
                            prefixIcon: const Icon(Icons.search, color: Colors.white54),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        
                        // List chat chiếm phần còn lại
                        Expanded(
                          child: chats.isEmpty ? (
                            const Center(
                              child: Text(
                                "Danh sách rỗng",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                           ) :ListView.builder(
                                itemCount: chats.length,
                                itemBuilder: (context, index) {
                                  final chat = chats[index];
                                  
                                  // Lấy thông tin người chat (member khác với currentUser)
                                  final otherMember = chat.members.firstWhere(
                                    (m) => m.id != widget.currentUserId,
                                    orElse: () => chat.members.first,
                                  );
                                  
                                  // xác định trạng thái online (an toàn với nhiều kiểu model)
                                  String status;
                                  status = state.receiverStatus[otherMember.id] ?? "offline";
                                  final bool isOnline = status == 'online' || status == 'heartbeat';

                                  
                                  // Lấy tin nhắn cuối cùng
                                  final lastMessage = chat.lastMessage;
                                  final type = lastMessage?.type;
                                  final lastMessageText = type == 'image' ? 'Hình ảnh' : (lastMessage?.content ?? 'Chưa có tin nhắn');
                                  
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                    leading: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: const Color(0xff47444c),
                                          backgroundImage: otherMember.avatar != null 
                                            ? NetworkImage(otherMember.avatar!)
                                            : null,
                                          child: otherMember.avatar == null
                                            ? Text(
                                                otherMember.username?.substring(0, 1).toUpperCase() ?? '?',
                                                style: const TextStyle(color: Colors.white, fontSize: 20),
                                              )
                                            : null,
                                        ),
                                        if (isOnline)
                                          Positioned(
                                            right: -2,
                                            bottom: -2,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.greenAccent,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: const Color(0xff1d1b20), width: 2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    title: Text(
                                      otherMember.username ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      lastMessageText,
                                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if (chat.updatedAt != null)
                                          Text(
                                            _formatTime(chat.updatedAt!),
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        const Icon(Icons.chevron_right, color: Colors.white54),
                                      ],
                                    ),
                                    onTap: () {
                                      debugPrint('Open chat with ${otherMember.username}');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MessagePage(
                                            chatId: chat.id!,
                                            currentFriend: otherMember,
                                            currentUserId: widget.currentUserId,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
                  ),
                );
            }
            if (state is ChatErrorState) {
              return const Center(
                child: Text(
                  "Có lỗi xảy ra",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Hôm nay - hiển thị giờ
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}