class ConversationEntity {
  final String id;
  final String participantFirstName;
  final String participantSecondName;
  final String? participantImage;
  final String lastMessage;
  final DateTime lastMessageTime;

  ConversationEntity({required this.id, required this.participantFirstName, required this.participantSecondName, required this.lastMessage, required this.lastMessageTime, required this.participantImage});
}