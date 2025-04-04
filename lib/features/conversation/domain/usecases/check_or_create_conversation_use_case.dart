import 'package:chat_app/features/conversation/domain/repository/conversation_repository.dart';

class CheckOrCreateConversationUseCase {
  final ConversationRepository repository;

  CheckOrCreateConversationUseCase({required this.repository});

  Future<String> call({required String contactId}) async {
    return repository.checkOrCreateConversation(contactId: contactId);
  }
}
