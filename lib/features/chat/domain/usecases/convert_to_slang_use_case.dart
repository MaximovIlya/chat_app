import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

class ConvertToSlangUseCase {
  final MessageRepository messageRepository;

  ConvertToSlangUseCase({required this.messageRepository});

  Future<String> call(String message) async {
    return await messageRepository.convertToSlang(message);
  }
}
