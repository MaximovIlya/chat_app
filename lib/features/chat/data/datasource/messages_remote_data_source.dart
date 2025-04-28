import 'dart:async';
import 'dart:convert';

import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/chat/data/models/daily_question_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MessagesRemoteDataSource {
  final String baseUrl = 'http://localhost:6000';
  final _storage = FlutterSecureStorage();
  final SocketService _socketService = SocketService();

  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
        Uri.parse('$baseUrl/messages/$conversationId'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Messages');
    }
  }

  Future<DailyQuestionModel> fetchDailyQuestion(String conversationId) async {
    String token = await _storage.read(key: 'token') ?? '';
    final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/dayly-question'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
    if (response.statusCode == 200) {
      return DailyQuestionModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch daily question');
    }
  }

  Future<String> convertToFormal(String message) async {
    final completer = Completer<String>();

    
    _socketService.socket.emit('formalStyle', message);

    
    _socketService.socket.once('formalMessage', (data) {
      completer.complete(data);
    });

    return completer.future;
  }

  Future<String> convertToSlang(String message) async {
    final completer = Completer<String>();

    
    _socketService.socket.emit('slangStyle', message);

    
    _socketService.socket.once('slangMessage', (data) {
      completer.complete(data);
    });

    return completer.future;
  }

  Future<String> convertToHumorous(String message) async {
    final completer = Completer<String>();

    
    _socketService.socket.emit('humorousStyle', message);

    
    _socketService.socket.once('humorousMessage', (data) {
      completer.complete(data);
    });

    return completer.future;
  }

  Future<String> convertToRomantic(String message) async {
    final completer = Completer<String>();

    
    _socketService.socket.emit('romanticStyle', message);

    
    _socketService.socket.once('romanticMessage', (data) {
      completer.complete(data);
    });

    return completer.future;
  }
}
