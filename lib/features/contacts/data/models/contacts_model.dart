import 'package:chat_app/features/contacts/domain/entities/contact_entity.dart';

class ContactsModel extends ContactEntity {
  ContactsModel(
      {required String id, required String username, required String email})
      : super(id: id, email: email, username: username);

  factory ContactsModel.fromJson(Map<String, dynamic> json) {
    return ContactsModel(
      id: json['contact_id'],
      username: json['username'],
      email: json['email'],
    );
  }
}
