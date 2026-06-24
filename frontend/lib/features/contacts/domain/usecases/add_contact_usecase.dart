import 'package:chat_app/features/contacts/domain/repositories/contacts_repository.dart';

class AddContactUsecase {
  final ContactsRepository contactsRepository;

  AddContactUsecase({required this.contactsRepository});

  Future<void> call({required String phone_number}) async {
    return await contactsRepository.addContact(phone_number: phone_number);
  }
}
