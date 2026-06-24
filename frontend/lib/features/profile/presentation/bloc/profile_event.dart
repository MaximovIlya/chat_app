import 'dart:io';

abstract class ProfileEvent {}

class AddImage extends ProfileEvent {
  final File imageFile;
  final String userId;
  AddImage(this.imageFile, this.userId);
}

class FetchImage extends ProfileEvent {
  final String userId;

  FetchImage(this.userId);
}

class UpdateBirth extends ProfileEvent {
  final String birth;
  UpdateBirth(this.birth);
}

class RemoveBirth extends ProfileEvent {}
