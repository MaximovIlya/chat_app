import 'dart:convert';
import 'dart:io';
import 'package:chat_app/core/url.dart';
import 'package:chat_app/features/profile/data/models/image_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ProfileRemoteDataSource {
  final String baseUrl = "${Url.baseUrl}/profile";
  final _storage = FlutterSecureStorage();

  Future<void> addImage({required File imageFile}) async {
    final token = await _storage.read(key: 'token') ?? '';
    final uri = Uri.parse('$baseUrl/image');

    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/');
    if (mimeTypeData == null || mimeTypeData.length != 2) {
      throw Exception('Could not determine mime type');
    }

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Failed to add image: ${response.statusCode}');
    }
  }

  Future<ImageModel> fetchImage({required String userId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fetchImage'),
      body: jsonEncode({'userId': userId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ImageModel(url: '${Url.baseUrl}${json['imageUrl']}');
    } else {
      print('Response body: ${response.body}');
      throw Exception('Failed to load image');
    }
  }

  Future<void> updateBirth({required String birth}) async {
    final token = await _storage.read(key: 'token') ?? '';
    final response = await http.post(Uri.parse('$baseUrl/updateBirth'),
        body: jsonEncode({'birth': birth}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Failed to update birth');
    }
  }

  Future<void> removeBirth() async {
    final token = await _storage.read(key: 'token') ?? '';
    final response =
        await http.get(Uri.parse('$baseUrl/removeBirth'), headers: {
      'Authorization': 'Bearer $token',
    });
    print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Failed to remove birth');
    }
  }
}
