// ignore_for_file: avoid_print

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:locket_beta/model/photo_model.dart';
import 'package:locket_beta/photo/cubit/photo_state.dart';
import 'package:locket_beta/utils/local_storage.dart';

class PhotoCubit extends Cubit<PhotoState> {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  late final Dio _dio;

  PhotoCubit() : super(PhotoInitial()) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status! < 500,
    ));

    _dio.interceptors
        .add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<void> uploadPhotoFile({
    required File imageFile,
    required String userId,
    String? caption,
    required String imageUrl,
  }) async {
    emit(PhotoUploading());
    try {
      print("🔄 Đang upload file: ${imageFile.path}");

      final fileName = imageFile.path.split('/').last;

      final formData = FormData.fromMap({
        "userId": userId,
        "caption": caption ?? "",
        "image":
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        '/photos/upload',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 201) {
        final photo = PhotoModel.fromJson(response.data["photo"]);
        emit(PhotoUpLoaded(photo));
      } else {
        emit(PhotoError("Upload thất bại: ${response.data}"));
      }
    } catch (e) {
      print("❌ Upload error: $e");
      emit(PhotoError("Không thể upload ảnh: $e"));
    }
  }

  // READ ALL
  Future<void> fetchPhotos() async {
    emit(PhotoLoading());
    try {
      // Lấy userId của bản thân
      final userId = await LocalStorage.getUserId() as String? ??
          '6911d640d34f6a5c5694199e';
      print('userId: $userId');

      // 1. Lấy danh sách bạn bè
      final friendsResponse = await _dio.get('/friends/$userId');
      List<String> friendIds = [];
      if (friendsResponse.statusCode == 200) {
        final List<dynamic> friendsJson = friendsResponse.data;
        friendIds = friendsJson.map<String>((f) => f['id'] as String).toList();
      } else {
        print('Không lấy được danh sách bạn bè: ${friendsResponse.data}');
      }

      // 2. Tạo list tất cả userId cần lấy ảnh (mình + bạn bè)
      final allUserIds = [userId, ...friendIds];

      List<PhotoModel> allPhotos = [];

      // 3. Lấy ảnh từng user
      for (var id in allUserIds) {
        final response = await _dio.get('/photos/user/$id');
        if (response.statusCode == 200) {
          final List<dynamic> photosJson = response.data['photos'];
          final photos = photosJson.map((e) => PhotoModel.fromJson(e)).toList();
          allPhotos.addAll(photos);
        } else {
          print('Lỗi lấy ảnh user $id: ${response.data}');
        }
      }

      // 4. Sắp xếp theo thời gian mới nhất lên đầu
      allPhotos.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(PhotoLoaded(allPhotos));
    } catch (e) {
      emit(PhotoError("Không thể tải danh sách ảnh: $e"));
    }
  }

  // READ ONE
  Future<void> fetchPhotoById(String id) async {
    emit(PhotoLoading());
    try {
      final response = await _dio.get('/photos/$id');

      if (response.statusCode == 200) {
        emit(PhotoLoaded([PhotoModel.fromJson(response.data)]));
      } else {
        emit(PhotoError("Không tìm thấy ảnh"));
      }
    } catch (e) {
      emit(PhotoError("Lỗi lấy ảnh: $e"));
    }
  }

  // DELETE
  Future<void> deletePhoto(String id) async {
    emit(PhotoDeleting());
    try {
      final response = await _dio.delete('/photos/$id');

      if (response.statusCode == 200) {
        emit(PhotoDeleted(id));
        fetchPhotos();
      } else {
        emit(PhotoError("Xóa thất bại"));
      }
    } catch (e) {
      emit(PhotoError("Không thể xóa ảnh: $e"));
    }
  }

  Future<void> sendPhoto(
    String senderId,
    String receiverId,
    String imageUrl,
    String caption,
  ) async {
    try {
      final response = await _dio.post(
        '/photos/sendPhoto',
        data: {
          "senderId": senderId,
          "receiverId": receiverId,
          "imageUrl": imageUrl,
          "caption": caption,
        },
      );

      if (response.statusCode == 200) {
        print("Gửi ảnh thành công: ${response.data}");
      } else {
        print("Lỗi khi gửi ảnh: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi sendPhoto: $e");
    }
  }
}
