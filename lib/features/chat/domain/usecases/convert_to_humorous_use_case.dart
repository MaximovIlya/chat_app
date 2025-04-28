import 'package:chat_app/features/chat/domain/repositories/message_repository.dart';

class ConvertToHumorousUseCase {
  final MessageRepository messageRepository;

  ConvertToHumorousUseCase({required this.messageRepository});

  Future<String> call(String message) async {
    return await messageRepository.convertToHumorous(message);
  }
}
