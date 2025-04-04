abstract class ContactsEvent {}

class FetchContacts extends ContactsEvent {}

class AddContact extends ContactsEvent {
  final String email;

  AddContact(this.email);
}
