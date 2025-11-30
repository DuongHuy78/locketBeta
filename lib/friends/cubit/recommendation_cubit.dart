import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/friends/cubit/recommendation_state.dart';
import 'package:locket_beta/model/friend_model.dart';
import 'package:locket_beta/utils/local_storage.dart';
import 'package:locket_beta/api/friends/recommendation_api.dart';

class RecommendationCubit extends Cubit<RecommendationState> {
  RecommendationCubit() : super(RecommendationInitial());

  final RecommendationApi _api = RecommendationApi();

  List<Friend> recommendations = [];

  Future<void> loadRecommendations() async {
    try {
      final userId = await LocalStorage.getUserId();
      if (userId == null) throw Exception("User not logged in");
      recommendations = await _api.getRecommendations(userId);
      emit(RecommendationLoaded(recommendations));
    } catch (e) {
      emit(RecommendationError(e.toString()));
    }
  }
}
