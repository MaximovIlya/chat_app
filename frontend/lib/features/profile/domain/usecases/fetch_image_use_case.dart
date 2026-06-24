import 'package:chat_app/features/profile/data/models/image_model.dart';
import 'package:chat_app/features/profile/domain/repositories/profile_repository.dart';

class FetchImageUseCase {
  final ProfileRepository profileRepository;

  FetchImageUseCase({required this.profileRepository});

  Future<ImageModel> call({required String userId}) async {
    return await profileRepository.fetchImage(userId: userId);
  }
}