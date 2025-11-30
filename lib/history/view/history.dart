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
  // ignore: unused_field
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = PhotoCubit();
        cubit.fetchPhotos(); // Trigger fetch all photos on init
        return cubit;
      },
      child: Scaffold(
        backgroundColor: showGrid ? Colors.black : const Color(0xff1d1b20),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color(0xff47444c),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        );
                      },
                      icon: Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const FriendsScreen()),
                      );
                    },
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
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: const Color(0xff47444c),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatPage(
                                      currentUserId: "690effbcb90f29f230c54995",
                                    )));
                      },
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildMainView(PhotoState state) {
    if (state is! PhotoLoaded || state.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library_outlined,
                color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text('No history yet',
                style: TextStyle(color: Colors.white54)),
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
              const SizedBox(height: 20), // Adjusted padding after top bar
              Expanded(
                child: _buildHeader(photo),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSenderInfo(photo),
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
    return HistoryGrid(
        photos: state
            .photos); // Pass photos to grid for vertical scrolling with loop
  }

  Widget _buildImage(String url) {
    // Cloudinary trả về URL trực tiếp, chỉ cần Image.network
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[800],
          child:
              const Icon(Icons.broken_image, color: Colors.white54, size: 100),
        );
      },
    );
  }

  Widget _buildHeader(PhotoModel photo) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          child: _buildImage(photo.imageUrl),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.8),
                Colors.transparent,
              ],
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
    final userInitial =
        photo.userId.isNotEmpty ? photo.userId[0].toUpperCase() : '?';
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
          child: Text(
            userInitial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              photo.userId,
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

            // 👉 Chuyển sang trang Home sau 100ms cho animation chạy
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
              border: Border.all(
                color: const Color(0xffFCB600),
                width: 5,
              ),
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
