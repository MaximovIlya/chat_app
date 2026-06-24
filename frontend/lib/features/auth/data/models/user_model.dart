import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String username,
    required String phone_number,
    required String? token,
    required String? birth,
    required String first_name,
    required String second_name,
    required String? image,
  }) : super(id: id, username: username, phone_number: phone_number, token: token, birth: birth, first_name: first_name, second_name: second_name, image: image);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // print('type id: ${json['id'].runtimeType}' );
    // print('type username: ${json['username'].runtimeType}' );
    // print('type email: ${json['email'].runtimeType}' );
    // print('type token: ${json['token'].runtimeType}' );
    return UserModel(
      id: json['id'],
      username: json['username'],
      phone_number: json['phone_number'],
      token: json['token'],
      birth: json['date_of_birth'],
      second_name: json['second_name'],
      first_name: json['first_name'],
      image: json['image'],
    );
  }
}
