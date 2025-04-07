abstract class ContactsEvent {}

class FetchContacts extends ContactsEvent {}

class CheckOrCreateConversation extends ContactsEvent {
  final String contactId;
  final String contactName;

  CheckOrCreateConversation({required this.contactId, required this.contactName});
}

class AddContact extends ContactsEvent {
  final String email;

  AddContact(this.email);
}
