import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String phone_number, String password);
  Future<UserEntity> register(String username, String phone_number, String password, String first_name, String second_name);
}