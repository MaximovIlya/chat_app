import 'dart:io';

import 'package:chat_app/features/profile/domain/repositories/profile_repository.dart';

class AddImageUseCase {
  final ProfileRepository profileRepository;

  AddImageUseCase({required this.profileRepository});

  Future<void> call({required File imageFile}) async {
    return await profileRepository.addImage(imageFile: imageFile);
  }
}