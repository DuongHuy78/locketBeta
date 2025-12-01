import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../common/edit_field_cubit.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({super.key});

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  File? imageFile;
  XFile? pickedFile;

  /// Pick ảnh từ gallery
  Future pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      pickedFile = picked;
      setState(() => imageFile = File(picked.path));
      print("Picked image: ${picked.path}");
    }
  }

  /// Upload avatar thông qua Cubit
  Future<void> uploadAvatar(BuildContext context) async {
    if (pickedFile == null) return;

    final cubit = context.read<EditFieldCubit>();

    final formData = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(
        pickedFile!.path,
        filename: "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg",
      ),
    });

    await cubit.updateAvatar(formData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditFieldCubit(),
      child: Builder(
        builder: (context) {
          // context ở đây đã có EditFieldCubit
          return Scaffold(
            backgroundColor: const Color(0xff121212),
            appBar: AppBar(
              title: const Text("Edit Profile Photo", style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xff121212),
            ),
            body: BlocConsumer<EditFieldCubit, EditFieldState>(
              listener: (context, state) {
                if (state is EditFieldSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cập nhật avatar thành công")),
                  );
                  Navigator.pop(context, true);
                } else if (state is EditFieldError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (imageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.file(imageFile!, height: 180),
                        ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: pickImage,
                        child: const Text("Choose Image", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: (imageFile == null || state is EditFieldLoading)
                            ? null
                            : () => uploadAvatar(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: state is EditFieldLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save"),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
