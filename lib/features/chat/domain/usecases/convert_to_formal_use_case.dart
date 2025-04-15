import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

class ConvertToFormalUseCase {
  final MessageRepository messageRepository;

  ConvertToFormalUseCase({required this.messageRepository});

  Future<String> call(String message) async {
    return await messageRepository.convertToFormal(message);
  }
}
