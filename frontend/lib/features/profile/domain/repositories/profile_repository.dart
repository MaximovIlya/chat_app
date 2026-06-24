import 'dart:io';

import 'package:chat_app/features/profile/data/models/image_model.dart';

abstract class ProfileRepository {
  Future<void> addImage({required File imageFile});
  Future<ImageModel> fetchImage({required String userId});
  Future<void> updateBirth({required String birth});
  Future<void> removeBirth();
}