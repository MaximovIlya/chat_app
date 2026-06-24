import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/chat/data/datasource/messages_remote_data_source.dart';
import 'package:chat_app/features/chat/data/repositories/message_repository_impl.dart';
import 'package:chat_app/features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:chat_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/pages/login_page.dart';
import 'package:chat_app/features/contacts/data/datasources/contacts_remote_data_source.dart';
import 'package:chat_app/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:chat_app/features/contacts/domain/usecases/add_contact_usecase.dart';
import 'package:chat_app/features/contacts/domain/usecases/fetch_contacts_usecase.dart';
import 'package:chat_app/features/contacts/presentation/bloc/contacts_bloc.dart';
import 'package:chat_app/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:chat_app/features/conversation/data/repositories/conversations_repository_impl.dart';
import 'package:chat_app/features/conversation/domain/repository/conversation_repository.dart';
import 'package:chat_app/features/conversation/domain/usecases/check_or_create_conversation_use_case.dart';
import 'package:chat_app/features/conversation/domain/usecases/fetch_conversations_use_case.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chat_app/features/conversation/presentation/pages/conversations_page.dart';
import 'package:chat_app/features/auth/presentation/pages/register_page.dart';
import 'package:chat_app/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:chat_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chat_app/features/profile/domain/usecases/add_image_use_case.dart';
import 'package:chat_app/features/profile/domain/usecases/fetch_image_use_case.dart';
import 'package:chat_app/features/profile/domain/usecases/remove_birth_use_case.dart';
import 'package:chat_app/features/profile/domain/usecases/update_birth_use_case.dart';
import 'package:chat_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:chat_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  final socketService = SocketService();
  await socketService.initSocket();
  final authRepository =
      AuthRepositoryImpl(authRemoteDataSource: AuthRemoteDataSource());
  final conversationRepository = ConversationsRepositoryImpl(
      conversationRemoteDataSource: ConversationRemoteDataSource());
  final messagesRepository =
      MessageRepositoryImpl(remoteDataSource: MessagesRemoteDataSource());
  final contactsRepository =
      ContactsRepositoryImpl(remoteDataSource: ContactsRemoteDataSource());
  final profileRepository =
      ProfileRepositoryImpl(remoteDataSource: ProfileRemoteDataSource());
  runApp(MyApp(
    authRepository: authRepository,
    conversationRepository: conversationRepository,
    messageRepository: messagesRepository,
    contactsRepository: contactsRepository,
    profileRepositoryImpl: profileRepository,
    isLoggedIn: token != null,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final ConversationRepository conversationRepository;
  final MessageRepositoryImpl messageRepository;
  final ContactsRepositoryImpl contactsRepository;
  final ProfileRepositoryImpl profileRepositoryImpl;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.conversationRepository,
    required this.messageRepository,
    required this.contactsRepository,
    required this.profileRepositoryImpl,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            registerUseCase: RegisterUseCase(repository: authRepository),
            loginUseCase: LoginUseCase(repository: authRepository),
          ),
        ),
        BlocProvider(
          create: (_) => ConversationsBloc(
            fetchConversationsUseCase:
                FetchConversationsUseCase(conversationRepository),
          ),
        ),
        BlocProvider(
          create: (_) => ChatBloc(
            fetchMessagesUseCase:
                FetchMessagesUseCase(messageRepository: messageRepository),
          ),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(
            addImageUseCase:
                AddImageUseCase(profileRepository: profileRepositoryImpl),
            fetchImageUseCase:
                FetchImageUseCase(profileRepository: profileRepositoryImpl),
            updateBirthUseCase:
                UpdateBirthUseCase(profileRepository: profileRepositoryImpl),
            removeBirthUseCase:
                RemoveBirthUseCase(profileRepository: profileRepositoryImpl),
          ),
        ),
        BlocProvider(
          create: (_) => ContactsBloc(
            addContactUsecase:
                AddContactUsecase(contactsRepository: contactsRepository),
            fetchContactsUseCase:
                FetchContactsUseCase(contactsRepository: contactsRepository),
            checkOrCreateConversationUseCase: CheckOrCreateConversationUseCase(
                conversationRepository: conversationRepository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
        // home: isLoggedIn ? ConversationsPage() : LoginPage(),
        routes: {
          '/login': (_) => LoginPage(),
          '/register': (_) => RegisterPage(),
          '/conversationsPage': (_) => ConversationsPage(),
          '/profilePage': (_) => ProfilePage(),
        },
      ),
    );
  }
}
