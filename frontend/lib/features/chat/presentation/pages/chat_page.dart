import 'package:chat_app/core/theme.dart';
import 'package:chat_app/core/url.dart';
import 'package:chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mateFirstName;
  final String mateSecondName;
  final String? image;

  const ChatPage({
    super.key,
    required this.conversationId,
    required this.mateFirstName,
    required this.mateSecondName,
    this.image,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _storage = FlutterSecureStorage();
  String userId = '';
  final _user = const types.User(id: ''); // placeholder
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    fetchUserId();
    BlocProvider.of<ChatBloc>(context)
        .add(LoadMessagesEvent(widget.conversationId));
  }

  void fetchUserId() async {
    final uid = await _storage.read(key: 'userId') ?? '';
    setState(() {
      userId = uid;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    BlocProvider.of<ChatBloc>(context).add(
      SendMessageEvent(widget.conversationId, message.text),
    );
  }

  List<types.Message> _mapMessages(List<MessageEntity> messages) {
    return messages.map((m) {
      final isImage = m.content.endsWith('.jpg') ||
          m.content.endsWith('.jpeg') ||
          m.content.endsWith('.png');

      final user = types.User(id: m.senderId, imageUrl: '${Url.baseUrl}/uploads/${widget.image}', firstName: widget.mateFirstName)
;
      if (isImage) {
        return types.ImageMessage(
          id: m.id,
          name: m.content,
          uri: '${Url.baseUrl}/uploads/${m.content}',
          author: user,
          createdAt: DateTime.parse(m.createdAt).millisecondsSinceEpoch,
          size: 300,
        );
      }

      return types.TextMessage(
        id: m.id,
        text: m.content,
        author: user,
        createdAt: DateTime.parse(m.createdAt).millisecondsSinceEpoch,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        backgroundColor: DefaultColors.chatAppBar,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.image != null
                  ? NetworkImage('${Url.baseUrl}/uploads/${widget.image}')
                  : null,
            ),
            const SizedBox(width: 10),
            Text('${widget.mateFirstName} ${widget.mateSecondName}',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatLoadedState) {
            return chat_ui.Chat(
              messages: _mapMessages(state.messages).reversed.toList(),
              onSendPressed: _handleSendPressed,
              user: types.User(id: userId),
              showUserAvatars: false,
              showUserNames: false,
              theme: chat_ui.DarkChatTheme(
                backgroundColor: DefaultColors.chatBackgroud,
                inputBackgroundColor: DefaultColors.sentMessageInput,
                primaryColor: DefaultColors.senderMessage,
                secondaryColor: DefaultColors.recieverMessage,
                inputBorderRadius: BorderRadius.circular(50),
                inputMargin: EdgeInsets.all(20),
                
                sendButtonIcon: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            );
          } else if (state is ChatErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No messages'));
        },
      ),
    );
  }
}
