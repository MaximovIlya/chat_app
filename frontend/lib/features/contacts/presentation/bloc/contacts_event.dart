abstract class ContactsEvent {}

class FetchContacts extends ContactsEvent {}

class CheckOrCreateConversation extends ContactsEvent {
  final String contactId;
  final String contactFirstName;
  final String contactSecondName;
  final String? image;

  CheckOrCreateConversation({required this.contactId, required this.contactFirstName, required this.contactSecondName, required this.image});
}

class AddContact extends ContactsEvent {
  final String phone_number;

  AddContact(this.phone_number);
}
