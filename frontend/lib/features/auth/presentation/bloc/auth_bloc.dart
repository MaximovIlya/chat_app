import 'package:chat_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final _storage = FlutterSecureStorage();


  AuthBloc({required this.registerUseCase, required this.loginUseCase}) : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);

    
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(event.username, event.phone_number, event.password, event.first_name, event.second_name);
      emit(AuthSuccess(message: "Registration successful"));
    } catch (e) {
      print("${e.toString()} test");
      emit(AuthFailure(error: 'Registration failed'));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.phone_number, event.password);
      await _storage.write(key: 'token', value: user.token);
      await _storage.write(key: 'userId', value: user.id);
      await _storage.write(key: 'username', value: user.username);
      await _storage.write(key: 'phone_number', value: user.phone_number);
      await _storage.write(key: 'birth', value: user.birth);
      await _storage.write(key: 'first_name', value: user.first_name);
      await _storage.write(key: 'second_name', value: user.second_name);
      await _storage.write(key: 'image', value: user.image);
      print('token : ${user.token}');
      emit(AuthSuccess(message: "Login successful"));
    } catch (e) {
      print(e.toString());
      emit(AuthFailure(error: 'Login failed'));
    }
  }
}