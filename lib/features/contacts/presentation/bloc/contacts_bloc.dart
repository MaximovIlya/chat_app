import 'package:chat_app/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:chat_app/features/contacts/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chat_app/features/contacts/presentation/bloc/contacts_event.dart';
import 'package:chat_app/features/contacts/presentation/bloc/contacts_state.dart';
import 'package:chat_app/features/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final FetchContactsUseCase fetchContactsUseCase;
  final AddContactUsecase addContactUsecase;
  final CheckOrCreateConversationUseCase checkOrCreateConversationUseCase;

  ContactsBloc(
      {required this.fetchContactsUseCase,
      required this.addContactUsecase,
      required this.checkOrCreateConversationUseCase})
      : super(ContactsInitial()) {
    on<FetchContacts>(_onFetchContacts);
    on<AddContact>(_onAddContact);
    on<CheckOrCreateConversation>(_onCheckOrCreateConversation);
  }

  Future<void> _onFetchContacts(
      FetchContacts event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      final contacts = await fetchContactsUseCase();
      emit(ContactsLoaded(contacts));
    } catch (error) {
      emit(ContactsError('Failed to fetch contacts'));
    }
  }

  Future<void> _onAddContact(
      AddContact event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      await addContactUsecase(email: event.email);
      emit(ContactAdded());
      add(FetchContacts());
    } catch (error) {
      emit(ContactsError('Failed to fetch contacts'));
    }
  }

  Future<void> _onCheckOrCreateConversation(
      CheckOrCreateConversation event, Emitter<ContactsState> emit) async {
    try {
      emit(ContactsLoading());
      final conversationId =
          await checkOrCreateConversationUseCase(contactId: event.contactId);
      emit(ConversationReady(
          conversationId: conversationId, contactName: event.contactName));
    } catch (error) {
      emit(ContactsError('Failed to start conversation'));
    }
  }
}
