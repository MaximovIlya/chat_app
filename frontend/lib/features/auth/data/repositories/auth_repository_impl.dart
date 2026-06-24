import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<UserEntity> login(String phone_number, String password) async {
    return await authRemoteDataSource.login(phone_number: phone_number, password: password);
  }

  @override
  Future<UserEntity> register(String username, String phone_number, String password, String first_name, String second_name) async{
    print("$username, $phone_number, $password");
    return await authRemoteDataSource.register(username: username, phone_number: phone_number, password: password, first_name: first_name, second_name: second_name);
    
  }
}