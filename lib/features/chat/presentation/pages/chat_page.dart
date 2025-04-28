import 'package:chat_app/core/theme.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/chat_state.dart';
import 'package:chat_app/features/chat/presentation/bloc/styles_bloc.dart';
import 'package:chat_app/features/chat/presentation/bloc/styles_event.dart';
import 'package:chat_app/features/chat/presentation/bloc/styles_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  final String mate;
  const ChatPage({super.key, required this.conversationId, required this.mate});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final _storage = FlutterSecureStorage();
  String userId = '';
  String? _aiGeneratedMessage;
  String botId = '00000000-0000-0000-0000-000000000000';

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context)
        .add(LoadMessagesEvent(widget.conversationId));

    fetchUserId();
  }

  fetchUserId() async {
    userId = await _storage.read(key: 'userId') ?? '';
    setState(() {
      userId = userId;
    });
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<ChatBloc>(context)
          .add(SendMessageEvent(widget.conversationId, content));
      _messageController.clear();
    }
  }

  void _convertToFormal() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<StylesBloc>(context).add(ConvertToFormalEvent(content));
    }
  }

  void _convertToSlang() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<StylesBloc>(context).add(ConvertToSlangEvent(content));
    }
  }

  void _convertTohumorous() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<StylesBloc>(context).add(ConvertToHumorousEvent(content));
    }
  }

  void _convertToRomatic() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      BlocProvider.of<StylesBloc>(context).add(ConvertToRomanticEvent(content));
    }
  }

  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
        title: Row(
          children: [
            CircleAvatar(
                //backgroundImage: NetworkImage(''),
                ),
            SizedBox(
              width: 10,
            ),
            Text(
              '${widget.mate}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ChatLoadedState) {
                  return ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isSentMessage = message.senderId == userId;
                      final isDailyQuestion = message.senderId == botId;
                      if (isSentMessage) {
                        return _buildSendMessage(context, message.content);
                      } else if (isDailyQuestion) {
                        return _buildDailyQuestionMessage(
                            context, message.content);
                      } else {
                        return _buildReceiveMessage(context, message.content);
                      }
                    },
                  );
                } else if (state is ChatErrorState) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                return Center(
                  child: Text('No messages found.'),
                );
              },
            ),
          ),
          _messageStyleButtons(),
          if (_aiGeneratedMessage != null)
            _buildAiMessagePreview(_aiGeneratedMessage!),
          BlocListener<StylesBloc, StylesState>(
            listener: (context, state) {
              if (state is FormalMessageLoadedState) {
                setState(() {
                  _aiGeneratedMessage = state.message;
                });
              } else if (state is SlangMessageLoadedState) {
                setState(() {
                  _aiGeneratedMessage = state.message;
                });
              } else if (state is HumorousMessageLoadedState) {
                setState(() {
                  _aiGeneratedMessage = state.message;
                });
              } else if (state is RomanticMessageLoadedState) {
                setState(() {
                  _aiGeneratedMessage = state.message;
                });
              }
            },
            child: SizedBox.shrink(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildReceiveMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          right: 30,
          top: 5,
          bottom: 5,
        ),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.recieverMessage,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildSendMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
          right: 30,
          top: 5,
          bottom: 5,
        ),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.senderMessage,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _messageStyleButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _convertToFormal,
            style: ElevatedButton.styleFrom(
              backgroundColor: DefaultColors.dailyQuestionColor,
            ),
            child: Text(
              'Formal',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
            onPressed: _convertToSlang,
            style: ElevatedButton.styleFrom(
              backgroundColor: DefaultColors.dailyQuestionColor,
            ),
            child: Text(
              'Slang',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
            onPressed: _convertTohumorous,
            style: ElevatedButton.styleFrom(
              backgroundColor: DefaultColors.dailyQuestionColor,
            ),
            child: Text(
              'Humorous',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          ElevatedButton(
            onPressed: _convertToRomatic,
            style: ElevatedButton.styleFrom(
              backgroundColor: DefaultColors.dailyQuestionColor,
            ),
            child: Text(
              'Romantic',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: DefaultColors.sentMessageInput,
        borderRadius: BorderRadius.circular(25),
      ),
      margin: EdgeInsets.fromLTRB(25, 10, 25, 25),
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Row(
        children: [
          GestureDetector(
            child: Icon(
              Icons.camera_alt,
              color: Colors.grey,
            ),
            onTap: () {},
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Icon(
              Icons.send,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestionMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 10,
        ),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: DefaultColors.dailyQuestionColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          "🧠 Daily Question : $message",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildAiMessagePreview(String message) {
    return Container(
      margin: EdgeInsets.fromLTRB(25, 10, 25, 0),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 164, 203, 222),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16),
            ),
          ),
          GestureDetector(
            child: Icon(
              Icons.check,
              color: DefaultColors.messageListPage,
            ),
            onTap: () {
              setState(() {
                _messageController.text = message;
                _aiGeneratedMessage = null;
              });
            },
          ),
          GestureDetector(
            child: Icon(
              Icons.close,
              color: DefaultColors.messageListPage,
            ),
            onTap: () {
              setState(() {
                _aiGeneratedMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
