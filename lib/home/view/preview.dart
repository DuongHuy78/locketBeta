// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locket_beta/photo/cubit/photo_cubit.dart';
import 'package:locket_beta/photo/cubit/photo_state.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    required this.imagePath,
    required this.onSend,
  });

  final String imagePath;
  final void Function() onSend;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  /// Upload ảnh hiện tại (imagePath) với cubit mới
  Future<void> _uploadPhoto() async {
    final caption = _captionController.text.trim();
    final cubit = context.read<PhotoCubit>();
    final file = File(widget.imagePath);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await cubit.uploadPhotoFile(
      imageFile: file,
      userId: '6911d640d34f6a5c5694199e',
      caption: caption.isNotEmpty ? caption : null,
      imageUrl: widget.imagePath, // giữ đường dẫn gốc nếu cần
    );
  }

  /// Chọn ảnh từ thư viện và upload ngay
  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final caption = _captionController.text.trim();
    final cubit = context.read<PhotoCubit>();
    final file = File(pickedFile.path);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await cubit.uploadPhotoFile(
      imageFile: file,
      userId: '6911d640d34f6a5c5694199e',
      caption: caption.isNotEmpty ? caption : null,
      imageUrl: pickedFile.path,
    );
  }

  /// Chỉ chọn ảnh từ thư viện, xem trước
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreview(
          imagePath: pickedFile.path,
          onSend: widget.onSend,
        ),
      ),
    );
  }

  void _handleDownload() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng tải xuống đang phát triển')),
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chia sẻ ảnh')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoCubit, PhotoState>(
      listener: (context, state) {
        if (state is PhotoUpLoaded) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload thành công!')),
          );
          widget.onSend();
          Navigator.pop(context); // close preview
        }
        if (state is PhotoError) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xff1d1b20),
        body: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download,
                        color: Colors.white, size: 30),
                    onPressed: _handleDownload,
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 30),
                    onPressed: _uploadPhoto,
                  ),
                ],
              ),
            ),
            // Image preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                          child:
                              Icon(Icons.error, color: Colors.red, size: 50));
                    },
                  ),
                ),
              ),
            ),
            // Caption input
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Thêm chú thích...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.send, color: Colors.white54),
                ),
                maxLines: null,
              ),
            ),
            // Bottom menu
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 40),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.check, color: Colors.white, size: 50),
                    onPressed: _uploadPhoto,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz,
                        color: Colors.white, size: 40),
                    onSelected: (String value) {
                      switch (value) {
                        case 'upload_current':
                          _uploadPhoto();
                          break;
                        case 'upload_from_phone':
                          _pickAndUploadPhoto();
                          break;
                        case 'pick_only':
                          _pickImageFromGallery();
                          break;
                        case 'download':
                          _handleDownload();
                          break;
                        case 'share':
                          _handleShare();
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'upload_current',
                        child: Row(
                          children: [
                            Icon(Icons.cloud_upload),
                            SizedBox(width: 8),
                            Text('Tải ảnh hiện tại lên'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'upload_from_phone',
                        child: Row(
                          children: [
                            Icon(Icons.photo_library),
                            SizedBox(width: 8),
                            Text('Chọn & upload ảnh từ điện thoại'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'pick_only',
                        child: Row(
                          children: [
                            Icon(Icons.image_search),
                            SizedBox(width: 8),
                            Text('Chỉ chọn ảnh & xem trước'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text('Tải xuống'),
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
