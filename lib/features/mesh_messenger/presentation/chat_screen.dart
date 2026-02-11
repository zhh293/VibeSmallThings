import 'package:flutter/material.dart';
import 'package:geek_toolbox/core/theme/app_theme.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/message.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';

class ChatScreen extends StatefulWidget {
  final Peer peer;

  const ChatScreen({super.key, required this.peer});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = []; // TODO: Load from Repository

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    
    final message = Message(
      id: DateTime.now().toString(),
      senderId: 'me',
      receiverId: widget.peer.id,
      content: _controller.text,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _controller.clear();
    });

    // TODO: Send via Repository
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peer.deviceName, style: const TextStyle(fontSize: 16)),
            Text(
              'Connected via ${widget.peer.type.name.toUpperCase()}',
              style: TextStyle(fontSize: 10, color: AppTheme.primaryColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.encrypted),
            onPressed: () {
              // Show encryption status
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId == 'me';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMe ? AppTheme.primaryColor : Colors.grey[800]!,
                      ),
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        color: isMe ? AppTheme.primaryColor : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {}, // Voice
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
