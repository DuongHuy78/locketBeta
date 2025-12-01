import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/friends/view/friends_screen.dart';
import 'package:locket_beta/home/view/home.dart';
import 'package:locket_beta/messenger/chat/chat.dart';
import 'package:locket_beta/photo/cubit/photo_cubit.dart';
import 'package:locket_beta/photo/cubit/photo_state.dart';
import 'package:locket_beta/profile/profile.dart';
import 'package:locket_beta/model/photo_model.dart';
import 'package:locket_beta/friends/cubit/friend_cubit.dart';
import 'package:locket_beta/utils/local_storage.dart';
import 'history_grid.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool clicked = false;
  bool showGrid = false;
  late final PageController _pageController;
  int _currentIndex = 0;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = PhotoCubit();
            cubit.fetchPhotos();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => FriendCubit()),
      ],
      child: Scaffold(
        backgroundColor: showGrid ? Colors.black : const Color(0xff1d1b20),
        body: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: BlocBuilder<PhotoCubit, PhotoState>(
                builder: (context, state) {
                  if (state is PhotoLoading || state is PhotoDeleting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (state is PhotoError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error,
                              color: Colors.white54, size: 64),
                          const SizedBox(height: 16),
                          Text(state.errorMessage,
                              style: const TextStyle(color: Colors.white54)),
                        ],
                      ),
                    );
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showGrid
                        ? _buildGridView(context, state)
                        : _buildMainView(state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleIconButton(
            icon: Icons.person,
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const FriendsScreen())),
            child: Container(
              alignment: Alignment.center,
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: const Color(0xff47444c),
              ),
              child: const Text(
                "Add Friend",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ),
          _circleIconButton(
            icon: Icons.chat_bubble_outline,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChatPage(currentUserId: "690effbcb90f29f230c54995"))),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: const Color(0xff47444c),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildMainView(PhotoState state) {
    if (state is! PhotoLoaded || state.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.photo_library_outlined, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text('No history yet', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: state.photos.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        final photo = state.photos[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(child: _buildHeader(photo)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSenderInfo(photo),
                    const SizedBox(height: 12),
                    _buildCaptionInput(),
                    const SizedBox(height: 20),
                    _buildSendButton(photo),
                    const SizedBox(height: 40),
                    _buildBottomButtons(photo),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, PhotoState state) {
    if (state is! PhotoLoaded) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return HistoryGrid(photos: state.photos);
  }

  Widget _buildHeader(PhotoModel photo) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: Image.network(photo.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              stops: const [0.0, 0.6],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xff2a2a2a),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              (photo.caption?.isNotEmpty ?? false)
                  ? photo.caption!
                  : 'No caption',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSenderInfo(PhotoModel photo) {
    final username = photo.user['username'] ?? '?';
    final avatarUrl = photo.user['avatarUrl'];
    final userInitial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final diff = DateTime.now().difference(photo.timestamp);
    String timeAgo;
    if (diff.inDays > 0) {
      timeAgo = '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      timeAgo = '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      timeAgo = '${diff.inMinutes}m';
    } else {
      timeAgo = 'now';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xff47444c),
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
            ? Text(
                username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              timeAgo,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptionInput() {
    return TextField(
      controller: _captionController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Nhập tin nhắn…",
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xff2a2a2a),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSendButton(PhotoModel photo) {
    return ElevatedButton.icon(
      onPressed: () => _selectFriendAndSend(photo),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: const Icon(Icons.send),
      label: const Text("Gửi cho bạn bè"),
    );
  }

  void _selectFriendAndSend(PhotoModel photo) async {
    final friendCubit = context.read<FriendCubit>();

    await friendCubit.loadFriends();
    final friends = friendCubit.friends;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1d1b20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Chọn bạn để gửi ảnh",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (_, index) {
                    final friend = friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(friend.name[0].toUpperCase()),
                      ),
                      title: Text(friend.name,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        _sendPhotoTo(friend.id, photo);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendPhotoTo(String friendId, PhotoModel photo) async {
    final senderId = await LocalStorage.getUserId();
    final caption = _captionController.text.trim();

    if (senderId == null) return;

    try {
      final cubit = context.read<PhotoCubit>();

      await cubit.sendPhoto(senderId, friendId, photo.imageUrl, caption);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gửi ảnh thành công!")),
      );

      _captionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi gửi: $e")),
      );
    }
  }

  Widget _buildBottomButtons(PhotoModel photo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            final goingToMain = showGrid;
            setState(() => showGrid = !showGrid);
            if (goingToMain) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _pageController.jumpToPage(0);
              });
            }
          },
          icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
        ),
        GestureDetector(
          onTap: () {
            setState(() => clicked = !clicked);
            Future.delayed(const Duration(milliseconds: 120), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: clicked ? 50 : 70,
            height: clicked ? 50 : 70,
            decoration: BoxDecoration(
              color: clicked ? Colors.grey[800] : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xffFCB600), width: 5),
            ),
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.keyboard_arrow_up,
              color: Colors.white, size: 28),
          onSelected: (String value) {
            final cubit = context.read<PhotoCubit>();
            switch (value) {
              case 'delete':
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận xóa'),
                    content: const Text('Bạn có chắc muốn xóa ảnh này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          cubit.deletePhoto(photo.id);
                        },
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
                break;
              case 'report':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Tính năng báo cáo đang được phát triển')),
                );
                break;
              case 'share':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chia sẻ ảnh')),
                );
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa ảnh'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Báo cáo'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Chia sẻ'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
