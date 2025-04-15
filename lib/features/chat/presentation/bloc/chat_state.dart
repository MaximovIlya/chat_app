import 'package:chat_app/features/chat/domain/entities/daily_question_entity.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';

abstract class ChatState {}

class ChatLoadingState extends ChatState {}

class ChatLoadedState extends ChatState {
  final List<MessageEntity> messages;
  ChatLoadedState(this.messages);
}

class ChatErrorState extends ChatState {
  final String message;
  ChatErrorState(this.message);
}

class DailyQuestionLoadedState extends ChatState {
  final DailyQuestionEntity dailyQuestion;

  DailyQuestionLoadedState(this.dailyQuestion);
  
}

class FormalMessageLoadedState extends ChatState {
  final String message;
  
  FormalMessageLoadedState(this.message);
}