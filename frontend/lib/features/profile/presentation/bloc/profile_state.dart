import 'package:chat_app/features/profile/domain/entities/image_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ImageLoaded extends ProfileState {
  final ImageEntity image;

  ImageLoaded(this.image);

}


class ImageAdded extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class BirthUpdated extends ProfileState {
  final String birth;
  BirthUpdated(this.birth);
}

class BirthRemoved extends ProfileState {}