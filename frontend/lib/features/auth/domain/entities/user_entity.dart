class UserEntity {
  final String id;
  final String phone_number;
  final String username;
  final String? token;
  final String? birth;
  final String first_name;
  final String second_name;
  final String? image;
  UserEntity({
    required this.id,
    required this.phone_number,
    required this.username,
    this.birth = '',
    required this.first_name,
    required this.second_name,
    this.token = '',
    this.image = '',
  });
}
