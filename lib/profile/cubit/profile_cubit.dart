import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/model/photo_model.dart';
import 'package:locket_beta/model/profile_model.dart';
import 'package:locket_beta/utils/local_storage.dart';
import 'package:locket_beta/utils/api_client.dart';
import 'package:intl/intl.dart';
import 'package:locket_beta/api/friends/friend_api.dart';


part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FriendApi friendApi = FriendApi();
  ProfileCubit() : super(ProfileInitial());

  Future<void> fetchProfile() async {
    try {
      emit(ProfileLoading());

      // Get current logged-in user ID
      final userId = await LocalStorage.getUserId();
      if (userId == null) {
        throw Exception("User is not logged in.");
      }
      print("THISS ISS THE USERR IDD" + userId);

      final dio = ApiClient().dio;

      // 1️⃣ Fetch user profile
      final profileResponse = await dio.get("/api/users/me");
      final profileData = profileResponse.data;
      print("PROFILE RESPONSE: " + profileData.toString());
      final userProfile = UserProfileModel(
        id: profileData["_id"],
        username: profileData["username"] ?? "N/A",
        handle: profileData["username"] ?? "",
        profileImageUrl: profileData["avatarUrl"] ?? "https://static.vecteezy.com/system/resources/previews/024/983/914/non_2x/simple-user-default-icon-free-png.png",
        locketCount: 0, // Will update after fetching photosR
        streak: 0, // You can compute streak if needed
      );

      // 2️⃣ Fetch user photos
      final photosResponse = await dio.get("/api/photos/user/$userId");
      print("PHOTOS RESPONSE: " + photosResponse.data.toString());
      final List<dynamic> photosJson = photosResponse.data['photos'] ?? [];
      final userPhotos =
          photosJson.map((json) => PhotoModel.fromJson(json)).toList();

      // Update locketCount
      userProfile.locketCount = userPhotos.length;
      
      final friends = await friendApi.getFriends(userId);
      userProfile.friendCount = friends.length;

      // emit(ProfileLoaded(userProfile, userPhotos));
      emit(ProfileLoaded(userProfile, userPhotos));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }
}
