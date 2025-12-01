part of 'edit_field_cubit.dart';

abstract class EditFieldState {}

class EditFieldInitial extends EditFieldState {}

class EditFieldLoading extends EditFieldState {}

class EditFieldSuccess extends EditFieldState {
  final dynamic updatedUser; // Có thể là Map<String, dynamic>
  EditFieldSuccess(this.updatedUser);
}

class EditFieldError extends EditFieldState {
  final String message;
  EditFieldError(this.message);
}
