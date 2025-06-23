import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../providers/auth_provider.dart';
// import '../../providers/user_provider.dart';
import '../../widgets/custom_appbar.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatDetailScreen extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String? partnerPhone;

  const ChatDetailScreen({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partnerPhone,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  final bool _isLoadingMore = false;
  String? _error;
  bool _disposed = false;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Set up periodic message checking for real-time updates
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_disposed && mounted) {
        _loadMessages(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _messageTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (_isLoadingMore) return;

    try {
      if (!_disposed && mounted && !silent) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('No token found');
      }

      final result = await ChatService.getMessages(token, widget.partnerId);
      if (_disposed) return;

      if (result['success']) {
        final messages =
            (result['messages'] as List).map((msg) {
              try {
                return ChatMessage.fromJson(msg);
              } catch (e) {
                print('Error parsing message: $msg');
                print('Parse error: $e');
                return ChatMessage(
                  id: msg['id'] ?? 0,
                  chatId: msg['chat_id'] ?? 0,
                  senderId: msg['sender_id'] ?? 0,
                  senderPhone: msg['sender_phone'] ?? '',
                  message: msg['message'] ?? 'Message could not be loaded',
                  sentAt: DateTime.now(),
                );
              }
            }).toList();

        if (!_disposed && mounted) {
          final shouldScroll =
              _messages.length != messages.length &&
              _scrollController.hasClients &&
              _scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent - 100;

          setState(() {
            _messages = messages;
            if (!silent) _isLoading = false;
          });

          // Auto-scroll to bottom if user is near the bottom
          if (shouldScroll || !silent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_disposed && mounted) {
                _scrollToBottom();
              }
            });
          }
        }
      } else {
        if (!_disposed && mounted && !silent) {
          setState(() {
            _error = result['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (!_disposed && mounted && !silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Check if we have a phone number to send to
    if (widget.partnerPhone == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot send message: Partner phone number not available',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        throw Exception('No token found');
      }

      // Clear the input field immediately
      _messageController.clear();

      final result = await ChatService.sendMessage(
        token,
        widget.partnerPhone!,
        message,
      );

      if (!_disposed && mounted) {
        if (result['success']) {
          // Refresh messages to get the updated list
          await _loadMessages(silent: true);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: widget.partnerName, showBackButton: true),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildMessageInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMessages,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with ${widget.partnerName}',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        // Message is from me if sender_id is NOT the partner's ID
        final isMe = message.senderId != widget.partnerId;

        // Show date separator if needed
        bool showDateSeparator = false;
        if (index == 0) {
          showDateSeparator = true;
        } else {
          final prevMessage = _messages[index - 1];
          final currentDate = DateTime(
            message.sentAt.year,
            message.sentAt.month,
            message.sentAt.day,
          );
          final prevDate = DateTime(
            prevMessage.sentAt.year,
            prevMessage.sentAt.month,
            prevMessage.sentAt.day,
          );
          showDateSeparator = !currentDate.isAtSameMomentAs(prevDate);
        }

        return Column(
          children: [
            if (showDateSeparator) _buildDateSeparator(message.sentAt),
            _buildMessageBubble(message, isMe),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDateSeparator(date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  String _formatDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Text(
                widget.partnerName[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue[600] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.sentAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
      } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
        return DateFormat('EEE HH:mm').format(dateTime);
      } else {
        return DateFormat('dd/MM HH:mm').format(dateTime);
      }
    } catch (e) {
      print('Error formatting time for $dateTime: $e');
      return 'now';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: _sendMessage,
                color: Colors.white,
                iconSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
