import 'dart:io';

import 'package:chat_app/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:chat_app/features/profile/data/models/image_model.dart';
import 'package:chat_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addImage({required File imageFile}) {
    return remoteDataSource.addImage(imageFile: imageFile);
  }

  @override
  Future<ImageModel> fetchImage({required String userId}) {
    return remoteDataSource.fetchImage(userId: userId);
  }
  
  @override
  Future<void> updateBirth({required String birth}) {
    return remoteDataSource.updateBirth(birth: birth);
  }
  
  @override
  Future<void> removeBirth() {
    return remoteDataSource.removeBirth();
  }
}