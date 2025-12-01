import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:locket_beta/utils/api_client.dart';

part 'edit_field_state.dart';

class EditFieldCubit extends Cubit<EditFieldState> {
  EditFieldCubit() : super(EditFieldInitial());

  final dio = ApiClient().dio;

  /// Cập nhật avatar (FormData chứa file ảnh)
  Future<void> updateAvatar(FormData formData) async {
    emit(EditFieldLoading());

    try {
      final response = await dio.put(
        "/api/users/avatar",
        data: formData,
      );

      // Backend trả về user object đã cập nhật
      final updatedUser = response.data["user"];

      emit(EditFieldSuccess(updatedUser));
    } catch (e) {
      emit(EditFieldError("Upload thất bại: $e"));
    }
  }

  /// Cập nhật bất kỳ field nào (tên, bio, etc.)
  Future<void> updateField(Map<String, dynamic> data) async {
    emit(EditFieldLoading());

    try {
      final response = await dio.put("/api/users/profile", data: data);

      emit(EditFieldSuccess(response.data));
    } catch (e) {
      emit(EditFieldError("Update thất bại: $e"));
    }
  }
}
