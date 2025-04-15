import 'package:chat_app/core/socket_service.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/domain/usecases/convert_to_formal_use_case.dart';
import 'package:chat_app/features/chat/domain/usecases/fetch_daily_question_use_case.dart';
import 'package:chat_app/features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final FetchDailyQuestionUseCase fetchDailyQuestionUseCase;
  final ConvertToFormalUseCase convertToFormalUseCase;
  final SocketService _socketService = SocketService();
  final List<MessageEntity> _messages = [];
  final _storage = FlutterSecureStorage();

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.fetchDailyQuestionUseCase,
    required this.convertToFormalUseCase,
  }) : super(ChatLoadingState()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<RecieveMessageEvent>(_onRecieveMessage);
    on<LoadDailyQuestionEvent>(_onLoadDailyQuestion);
    on<ConvertToFormalEvent>(_onConvertToFormal);
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoadingState());
    try {
      final messages = await fetchMessagesUseCase(event.conversationId);
      _messages.clear();
      _messages.addAll(messages);
      emit(ChatLoadedState(List.from(_messages)));

      _socketService.socket.off('newMessage');

      _socketService.socket.emit('joinConversation', event.conversationId);
      _socketService.socket.on('newMessage', (data) {
        print('step1 - recieve : $data');
        add(RecieveMessageEvent(data));
      });
    } catch (error) {
      emit(ChatErrorState('Failed to load messages'));
      print(error.toString());
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    String userId = await _storage.read(key: 'userId') ?? '';
    print('userId : $userId');

    final newMessage = {
      'conversationId': event.conversationId,
      'content': event.content,
      'senderId': userId,
    };
    _socketService.socket.emit('sendMessage', newMessage);
  }

  Future<void> _onRecieveMessage(
      RecieveMessageEvent event, Emitter<ChatState> emit) async {
    print('step2 - recieve eveny called');
    print(event.message);
    final message = MessageEntity(
      id: event.message['id'],
      conversationId: event.message['conversation_id'],
      senderId: event.message['sender_id'],
      content: event.message['content'],
      createdAt: event.message['created_at'],
    );
    _messages.add(message);
    emit(ChatLoadedState(List.from(_messages)));
  }

  Future<void> _onLoadDailyQuestion(
      LoadDailyQuestionEvent event, Emitter<ChatState> emit) async {
    try {
      emit(ChatLoadingState());
      final dailyQuestion =
          await fetchDailyQuestionUseCase(event.coversationId);
      emit(DailyQuestionLoadedState(dailyQuestion));
    } catch (error) {
      emit(ChatErrorState('Failed to load daily question'));
    }
  }

  Future<void> _onConvertToFormal(
      ConvertToFormalEvent event, Emitter<ChatState> emit) async {
    try {
      final formalMessage = await convertToFormalUseCase(event.message);
      emit(FormalMessageLoadedState(formalMessage));
      
    } catch (error) {
      emit(ChatErrorState('Failed to convert to formal style'));
    }
  }
}
