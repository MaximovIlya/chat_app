import 'package:chat_app/features/chat/domain/entities/daily_question_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';

abstract class MessageRepository {
  Future<List<MessageEntity>> fetchMessages(String conversationId);
  Future<void> sendMessage(MessageEntity message);
  Future<DailyQuestionEntity> fetchDailyQuestion(String conversationId);
  Future<String> convertToFormal(String message);
  Future<String> convertToSlang(String message);
  Future<String> convertToHumorous(String message);
  Future<String> convertToRomantic(String message);

}
