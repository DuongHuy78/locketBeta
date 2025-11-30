import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/logout/cubit/logout_state.dart';
import 'package:locket_beta/utils/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locket_beta/utils/api_client.dart';

class LogoutCubit extends Cubit<LogoutState> {
  LogoutCubit() : super(LogoutInitial());

  final ApiClient _apiClient = ApiClient();

  Future<void> logout() async {
    emit(LogoutLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken') ?? "";

      // Gọi API logout BE
      final response = await _apiClient.dio.post(
        "/api/auth/logout",
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200) {
        // Xóa token và userId local
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await LocalStorage.removeUserId();

        emit(LogoutSuccess());
      } else {
        emit(LogoutFailure("Logout failed, status: ${response.statusCode}"));
      }
    } catch (e) {
      emit(LogoutFailure("Logout Error: $e"));
    }
  }
}
