import 'dart:convert';

import 'package:chat_app/core/url.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {

  final String baseUrl = "${Url.baseUrl}/auth";

  Future<UserModel> login({
    required String phone_number,
    required String password,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/login'),
        body: jsonEncode({'phone_number': phone_number, 'password': password}),
        headers: {'Content-Type': 'application/json'});

    //print(response.body);
    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }

  Future<UserModel> register({
    required String username,
    required String phone_number,
    required String password,
    required String first_name,
    required String second_name,
  }) async {
    final response = await http.post(Uri.parse('$baseUrl/register'),
        body: jsonEncode(
          {
            'username': username,
            'phone_number': phone_number,
            'password': password,
            'first_name': first_name,
            'second_name': second_name
          },
        ),
        headers: {'Content-Type': 'application/json'});

    // print(response.body);

    return UserModel.fromJson(jsonDecode(response.body)['user']);
  }
}
