// ignore_for_file: avoid_print

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:locket_beta/model/photo_model.dart';
import 'package:locket_beta/photo/cubit/photo_state.dart';

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
      final response = await _dio.get('/photos');

      if (response.statusCode == 200) {
        final List<dynamic> photosJson = response.data['photos'];
        final photos = photosJson.map((e) => PhotoModel.fromJson(e)).toList();
        emit(PhotoLoaded(photos));
      } else {
        emit(PhotoError("Lỗi API: ${response.data}"));
      }
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
}
