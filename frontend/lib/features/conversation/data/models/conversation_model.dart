import 'package:chat_app/features/conversation/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  
  ConversationModel({
    required id,
    required participantFirstName,
    required participantSecondName,
    required lastMessage,
    required lastMessageTime,
    required participantImage,
  }) : super(
          id: id,
          participantFirstName: participantFirstName,
          participantSecondName: participantSecondName,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          participantImage: participantImage
        );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['conversation_id'], 
      participantFirstName: json['participant_name'],
      participantSecondName: json['participant_surname'],  
      lastMessage: json['last_message'], 
      lastMessageTime: DateTime.parse(json['last_message_time']),
      participantImage: json['participant_image'],
    );
  }
}
