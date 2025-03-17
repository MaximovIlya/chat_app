import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String username,
    required String email,
    required String token,
  }) : super(id: id, username: username, email: email, token: token);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // print('type id: ${json['id'].runtimeType}' );
    // print('type username: ${json['username'].runtimeType}' );
    // print('type email: ${json['email'].runtimeType}' );
    // print('type token: ${json['token'].runtimeType}' );
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      token: json['token'],
    );
  }
}
