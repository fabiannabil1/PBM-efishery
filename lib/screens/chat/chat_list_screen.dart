import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat.dart';
import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_appbar.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Chat> _chats = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('No token found');
      }

      final result = await ChatService.getChats(token);
      if (result['success']) {
        final chats =
            (result['chats'] as List)
                .map((chat) => Chat.fromJson(chat))
                .toList();
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Chats', showBackButton: true),
      body: RefreshIndicator(onRefresh: _loadChats, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadChats, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_chats.isEmpty) {
      return const Center(child: Text('No chats yet'));
    }

    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return _buildChatItem(chat);
      },
    );
  }

  Widget _buildChatItem(Chat chat) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            chat.profilePicture != null
                ? NetworkImage(chat.profilePicture!)
                : null,
        child:
            chat.profilePicture == null
                ? Text(chat.partnerName[0].toUpperCase())
                : null,
      ),
      title: Text(
        chat.partnerName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle:
          chat.lastMessage != null
              ? Text(
                chat.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : null,
      trailing:
          chat.sentAt != null
              ? Text(
                DateFormat('HH:mm').format(chat.sentAt!),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              )
              : null,
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chat-detail',
          arguments: {
            'partnerId': chat.partnerId,
            'partnerName': chat.partnerName,
            'partnerPhone': chat.partnerPhone,
          },
        );
      },
    );
  }
}
