import 'dart:async';
import 'dart:developer' as developer; // Cho better logging
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:locket_beta/friends/cubit/friend_cubit.dart';
import 'package:locket_beta/landing/views/landing_ui.dart';
import 'package:locket_beta/messenger/chat/chat.dart';
import 'package:locket_beta/signup/cubit/signup_cubit.dart';
import 'camera/cubit/camera_cubit.dart';
import 'photo/cubit/photo_cubit.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() async {
    // Wrap với error zone cho production
    try {
      cameras = await availableCameras();
      developer.log('Cameras initialized: ${cameras.length}');
    } catch (e) {
      developer.log('Lỗi camera: $e', level: 1000); // Log error level
    }

    runApp(MyApp(cameras: cameras));
  },
      (error, stack) => developer.log('Uncaught error: $error',
          error: error, stackTrace: stack));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Sử dụng Multi để provide nhiều cubit
      providers: [
        BlocProvider(
          create: (_) => CameraCubit(cameras: cameras)..initializeCamera(),
        ),
        BlocProvider(
          // Thêm PhotoCubit để fix provider error
          create: (_) => PhotoCubit(),
        ),
        BlocProvider<SignupCubit>(
          create: (_) => SignupCubit(), // <- thêm đây
        ),
        BlocProvider(create: (_) => FriendCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Locket Beta',
        home: LandingUI(),
        // home: ChatPage(currentUserId: "690effbcb90f29f230c54996",),
      ),
    );
  }
}
