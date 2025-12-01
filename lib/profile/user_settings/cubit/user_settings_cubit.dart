import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/model/user_settings_model.dart';
import 'package:locket_beta/utils/api_client.dart';

part 'user_settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  // ----------------------------
  // FETCH SETTINGS
  // ----------------------------
  Future<void> fetchSettings() async {
    try {
      emit(SettingsLoading());

      final dio = ApiClient().dio;

      // Interceptor tự gắn Bearer Token
      final response = await dio.get("/api/users/me");
      final data = response.data;

      final settings = UserSettingsModel(
        birthday: data["birthday"] ?? "",
        name: data["name"] ?? "",
        profilePhotoUrl: data["avatarUrl"] ?? "",
        phoneNumber: data["phoneNumber"] ?? "",
        emailAddress: data["email"] ?? "",
        sendReadReceipts: data["sendReadReceipts"] ?? true,
      );

      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError("Failed to load settings: $e"));
    }
  }

  // ----------------------------
  // INTERNAL PUT /users/profile
  // Chỉ gửi field bị thay đổi
  // ----------------------------
  Future<bool> _updateProfileField(Map<String, dynamic> fields) async {
    try {
      final dio = ApiClient().dio;

      print("PUT /users/profile BODY: $fields");

      // Interceptor sẽ tự gắn Authorization: Bearer token
      await dio.put("/api/users/profile", data: fields);

      return true;
    } catch (e) {
      print("UPDATE FAILED: $e");
      return false;
    }
  }

  // ----------------------------
  // UPDATE: Read Receipts
  // ----------------------------
  Future<void> updateReadReceipts(bool newValue) async {
    if (state is! SettingsLoaded) return;

    final current = (state as SettingsLoaded).settings;

    // Optimistic
    emit(SettingsLoaded(current.copyWith(sendReadReceipts: newValue)));

    final ok = await _updateProfileField({
      "sendReadReceipts": newValue,
    });

    if (!ok) {
      emit(SettingsLoaded(current)); // rollback
    }
  }

  // ----------------------------
  // UPDATE: Name
  // ----------------------------
  Future<void> updateName(String newName) async {
    if (state is! SettingsLoaded) return;

    final current = (state as SettingsLoaded).settings;

    emit(SettingsLoaded(current.copyWith(name: newName)));

    final ok = await _updateProfileField({"name": newName});

    if (!ok) emit(SettingsLoaded(current));
  }

  // ----------------------------
  // UPDATE: Birthday
  // ----------------------------
  Future<void> updateBirthday(String birthday) async {
    if (state is! SettingsLoaded) return;

    final current = (state as SettingsLoaded).settings;

    emit(SettingsLoaded(current.copyWith(birthday: birthday)));

    final ok = await _updateProfileField({"birthday": birthday});

    if (!ok) emit(SettingsLoaded(current));
  }

  // ----------------------------
  // UPDATE: Avatar
  // ----------------------------
  Future<void> updateAvatar(String url) async {
    if (state is! SettingsLoaded) return;

    final current = (state as SettingsLoaded).settings;

    emit(SettingsLoaded(current.copyWith(profilePhotoUrl: url)));

    final ok = await _updateProfileField({"avatarUrl": url});

    if (!ok) emit(SettingsLoaded(current));
  }

  // ----------------------------
  // UPDATE: Phone Number
  // ----------------------------
  Future<void> updatePhone(String phone) async {
    if (state is! SettingsLoaded) return;

    final current = (state as SettingsLoaded).settings;

    emit(SettingsLoaded(current.copyWith(phoneNumber: phone)));

    final ok = await _updateProfileField({"phoneNumber": phone});

    if (!ok) emit(SettingsLoaded(current));
  }
}
