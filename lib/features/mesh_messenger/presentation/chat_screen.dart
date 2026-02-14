import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/core/theme/app_theme.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/message.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';
import 'package:geek_toolbox/features/mesh_messenger/presentation/providers/mesh_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Peer peer;

  const ChatScreen({super.key, required this.peer});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.isEmpty) return;

    final message = Message(
      id: DateTime.now().toString(),
      senderId: 'me', // Will be replaced by repository with actual ID
      receiverId: widget.peer.id,
      content: _controller.text,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );

    ref.read(meshRepositoryProvider).sendMessage(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(meshMessagesProvider(widget.peer.id));
    final messages = messagesAsync.value ?? [];

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
            icon: const Icon(Icons.lock),
            onPressed: () {
              // Show encryption status
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.peer.type == ConnectionType.ble)
            Container(
              color: Colors.amber.withOpacity(0.2),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: const Text(
                'Note: BLE Mesh Chat is currently in experimental mode (Scanning Only). Please use WiFi for full chat functionality.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ),
          Expanded(
            child: ListView.builder(
              reverse: true, // Chat usually starts from bottom
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                // Reverse index for reverse list
                final msg = messages[index];
                // We need to know 'my' ID.
                // For now, let's assume if it's NOT the peer's ID, it's mine.
                // Or better, check if senderId != widget.peer.id
                // (This assumes 1-on-1 chat)
                final isMe = msg.senderId != widget.peer.id;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppTheme.primaryColor.withOpacity(0.2)
                          : Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMe ? AppTheme.primaryColor : Colors.grey[800]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(
                            color: isMe ? AppTheme.primaryColor : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${msg.timestamp.hour}:${msg.timestamp.minute}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
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
                    enabled: widget.peer.type != ConnectionType.ble,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: widget.peer.type == ConnectionType.ble
                          ? 'BLE Chat not supported yet'
                          : 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppTheme.primaryColor,
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
