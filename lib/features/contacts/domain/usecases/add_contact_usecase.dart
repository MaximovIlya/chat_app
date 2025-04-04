import 'package:chat_app/features/contacts/domain/repositories/contacts_repository.dart';

class AddContactUsecase {
  final ContactsRepository contactsRepository;

  AddContactUsecase({required this.contactsRepository});

  Future<void> call({required String email}) async {
    return await contactsRepository.addContact(email: email);
  }
}
