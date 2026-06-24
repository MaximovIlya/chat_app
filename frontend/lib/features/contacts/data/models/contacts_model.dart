import 'package:chat_app/features/contacts/domain/entities/contact_entity.dart';

class ContactsModel extends ContactEntity {
  ContactsModel(
      {required String id, required String first_name, required String second_name, required String phone_number, required String? image})
      : super(id: id, phone_number: phone_number, first_name: first_name, second_name: second_name, image: image);

  factory ContactsModel.fromJson(Map<String, dynamic> json) {
    return ContactsModel(
      id: json['contact_id'],
      first_name: json['first_name'],
      second_name: json['second_name'],
      phone_number: json['phone_number'],
      image: json['image'],
    );
  }
}
