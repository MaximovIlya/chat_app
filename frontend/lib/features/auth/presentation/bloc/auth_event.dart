abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String username;
  final String phone_number;
  final String password;
  final String first_name;
  final String second_name;

  RegisterEvent({
    required this.username,
    required this.phone_number,
    required this.password,
    required this.first_name,
    required this.second_name,
  });
}

class LoginEvent extends AuthEvent {
  final String phone_number;
  final String password;

  LoginEvent({
    required this.phone_number,
    required this.password,
  });
}
