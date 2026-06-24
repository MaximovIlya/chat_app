import 'package:chat_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateBirthUseCase {
  final ProfileRepository profileRepository;

  UpdateBirthUseCase({required this.profileRepository});

  Future<void> call({required String birth}) async {
    return await profileRepository.updateBirth(birth: birth);
  }
}
