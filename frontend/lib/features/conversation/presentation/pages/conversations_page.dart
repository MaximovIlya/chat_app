import 'package:chat_app/core/theme.dart';
import 'package:chat_app/core/url.dart';
import 'package:chat_app/features/chat/presentation/pages/chat_page.dart';
import 'package:chat_app/features/contacts/presentation/pages/contacts_page.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_bloc.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_event.dart';
import 'package:chat_app/features/conversation/presentation/bloc/conversations_state.dart';
import 'package:chat_app/features/conversation/presentation/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ConversationsBloc>(context).add(FetchConversations());
  }

  String formatLastMessageTime(String lastMessageTime) {
    final date = DateTime.parse(lastMessageTime).toLocal();
    final now = DateTime.now();

    
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      
      return DateFormat('HH:mm').format(date);
    }

    
    final beginningOfWeek = now.subtract(Duration(days: now.weekday - 1));

    if (date.isAfter(beginningOfWeek)) {
      
      return DateFormat('EEE').format(date);
    }

    
    return DateFormat('MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: Menu(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.all(5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildRecentContact('Ilya', context),
                _buildRecentContact('Sasha', context),
                _buildRecentContact('Karim', context),
                _buildRecentContact('Kostia', context),
                _buildRecentContact('Makar', context),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DefaultColors.messageListPage,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: BlocBuilder<ConversationsBloc, ConversationsState>(
                builder: (context, state) {
                  if (state is ConversationsLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is ConversationsLoaded) {
                    return ListView.builder(
                      itemCount: state.conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = state.conversations[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  conversationId: conversation.id,
                                  mateFirstName:
                                      conversation.participantFirstName,
                                  mateSecondName:
                                      conversation.participantSecondName,
                                  image: conversation.participantImage,
                                ),
                              ),
                            );
                          },
                          child: _buildMessageTile(
                              "${conversation.participantFirstName} ${conversation.participantSecondName}",
                              conversation.lastMessage,
                              formatLastMessageTime(
                                  conversation.lastMessageTime.toString()),
                              conversation.participantImage),
                        );
                      },
                    );
                  } else if (state is ConversationsError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }
                  return Center(
                    child: Text(
                      'No conversations found',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ContactsPage()));
        },
        backgroundColor: DefaultColors.buttonColor,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.contacts),
      ),
    );
  }

  Widget _buildMessageTile(
      String name, String message, String time, String? image) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: image != null
            ? NetworkImage('${Url.baseUrl}/uploads/$image')
            : null,
        backgroundColor: Colors.grey[300],
      ),
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        message,
        style: TextStyle(color: Colors.grey, fontSize: 16),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildRecentContact(String name, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            //backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
