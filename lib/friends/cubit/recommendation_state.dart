import 'package:locket_beta/model/friend_model.dart';

abstract class RecommendationState {}

class RecommendationInitial extends RecommendationState {}

class RecommendationLoading extends RecommendationState {}

class RecommendationLoaded extends RecommendationState {
  final List<Friend> recommendations;
  RecommendationLoaded(this.recommendations);
}

class RecommendationError extends RecommendationState {
  final String message;
  RecommendationError(this.message);
}
