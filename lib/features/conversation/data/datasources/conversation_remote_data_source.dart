import 'dart:convert';

import 'package:chat_app/features/conversation/data/models/conversation_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ConversationRemoteDataSource {
  final String basUrl = 'http://10.91.52.49:6000';
  final _storage = FlutterSecureStorage();

  Future<List<ConversationModel>> fetchConversations() async {
    String token = await _storage.read(key: 'token') ?? '';
    final response =
        await http.get(Uri.parse('$basUrl/conversations'), headers: {
      'Authorization': 'Bearer $token',
    });

    
   
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch conversations');
    }
  }
}
