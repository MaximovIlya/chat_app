import 'package:chat_app/features/profile/domain/repositories/profile_repository.dart';

class RemoveBirthUseCase {
  final ProfileRepository profileRepository;

  RemoveBirthUseCase({required this.profileRepository});

  Future<void> call() async {
    return await profileRepository.removeBirth();
  }
}
