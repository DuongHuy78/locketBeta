import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/camera/cubit/camera_state.dart';
import 'package:locket_beta/friends/view/friends_screen.dart';
import 'package:locket_beta/friends/cubit/friend_cubit.dart';
import 'package:locket_beta/messenger/chat/chat.dart';
import 'package:locket_beta/profile/profile.dart';
import 'package:locket_beta/photo/cubit/photo_cubit.dart';
import 'package:locket_beta/settings/sizes.dart';
import 'package:locket_beta/home/view/preview.dart';
import 'package:locket_beta/history/view/history.dart';
import 'package:locket_beta/camera/cubit/camera_cubit.dart';
import 'package:locket_beta/utils/local_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScrollController scrollController = ScrollController();
  bool clicked = false;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  late final CameraCubit _cameraCubit;
  late final PhotoCubit _photoCubit;

  @override
  void initState() {
    super.initState();

    _cameraCubit = context.read<CameraCubit>();
    _photoCubit = context.read<PhotoCubit>();
  }

  @override
  void dispose() {
    // KHÔNG close cameraCubit
    _photoCubit.close();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) async {
    final maxZoom = await (_cameraCubit.state is CameraReady
        ? (_cameraCubit.state as CameraReady).controller.getMaxZoomLevel()
        : Future.value(1.0));
    _currentScale = (_baseScale * details.scale).clamp(1.0, maxZoom);
    _cameraCubit.setZoom(_currentScale);
  }

  // FIX: Không lưu ảnh ngay, chỉ mở preview
  void _onPictureTaken(String path) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => BlocProvider.value(
        // ← FIX: Wrap modal với BlocProvider.value
        value: _photoCubit, // Pass cubit từ HomeScreen
        child: ImagePreview(
          imagePath: path,
          onSend: () {
            setState(() {}); // Refresh UI nếu cần
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cameraCubit),
        BlocProvider.value(value: _photoCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xff1d1b20),
        body: Column(
          children: [
            const SizedBox(height: 40),
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
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //       builder: (_) => const FriendsScreen()),
                      // );
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => BlocProvider.value(
                      //       value: context.read<FriendCubit>(),
                      //       child: FriendsScreen(),
                      //     ),
                      //   ),
                      // );

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => FriendCubit(),
                            child: FriendsScreen(),
                          ),
                        ),
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
                      onPressed: () async {
                        final uid = await LocalStorage.getUserId();
                        final userId = uid ?? "690effbcb90f29f230c54996"; 
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(currentUserId: userId),
                          ),
                        );
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
              child: BlocBuilder<CameraCubit, CameraState>(
                bloc: _cameraCubit,
                builder: (context, state) {
                  if (state is CameraLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }
                  if (state is CameraError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white.withOpacity(0.5),
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is! CameraReady) {
                    return const SizedBox.shrink();
                  }
                  return SingleChildScrollView(
                    controller: scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (details.delta.dy < 0) {
                              scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 50,
                              horizontal: 5,
                            ),
                            width: Sizes.width(context),
                            height: Sizes.height(context),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onDoubleTap: () =>
                                      _cameraCubit.toggleCamera(),
                                  onScaleUpdate: _onScaleUpdate,
                                  onScaleStart: _onScaleStart,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    width: Sizes.width(context),
                                    height: Sizes.width(context),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CameraPreview(
                                        state.controller,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Positioned(
                                              bottom: 10,
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                      sigmaX: 10,
                                                      sigmaY: 10,
                                                    ),
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Center(
                                                        child: Text(
                                                          state.zoom
                                                              .toStringAsFixed(
                                                                  1),
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xffffffff),
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _cameraCubit.toggleFlash(),
                                        icon: Icon(
                                          state.flash
                                              ? Icons.flash_on_outlined
                                              : Icons.flash_off_outlined,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                            color: const Color(0xffFCB600),
                                            width: 5,
                                          ),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              clicked = !clicked;
                                            });
                                            _cameraCubit
                                                .takePicture(_onPictureTaken);
                                          },
                                          onLongPress: () {
                                            setState(() {
                                              clicked = !clicked;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            onEnd: () {
                                              setState(() {
                                                clicked = false;
                                              });
                                            },
                                            duration: const Duration(
                                                milliseconds: 100),
                                            width: clicked ? 50 : 80,
                                            height: clicked ? 50 : 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: clicked
                                                  ? const Color(0xff47444c)
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _cameraCubit.toggleCamera(),
                                        icon: const Icon(
                                          Icons.flip_camera_ios_outlined,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 80),
                                  width: 125,
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color: const Color(0xff47444c),
                                            ),
                                            child: const Icon(
                                              Icons.photo,
                                              color: Color(0xffffffff),
                                              size: 30,
                                            ),
                                          ),
                                          const Text(
                                            "History",
                                            style: TextStyle(
                                              color: Color(0xffffffff),
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 40,
                                        weight: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (details.delta.dy > 0) {
                              scrollController.animateTo(
                                scrollController.position.minScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          child: Container(
                            width: Sizes.width(context),
                            height: Sizes.height(context),
                            child: HistoryScreen(), // Không const
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}