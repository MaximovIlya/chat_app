import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

class ConvertToRomanticUseCase {
  final MessageRepository messageRepository;

  ConvertToRomanticUseCase({required this.messageRepository});

  Future<String> call(String message) async {
    return await messageRepository.convertToRomantic(message);
  }
}
