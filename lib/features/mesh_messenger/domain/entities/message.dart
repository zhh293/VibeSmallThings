import 'package:equatable/equatable.dart';

enum MessageType { text, image, sos, handshake }
enum MessageStatus { sending, sent, delivered, failed, received }

class Message extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content; // Text or Path to file
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isEncrypted;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    this.status = MessageStatus.sending,
    required this.timestamp,
    this.isEncrypted = false,
  });

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    bool? isEncrypted,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  @override
  List<Object?> get props => [id, senderId, receiverId, content, type, status, timestamp, isEncrypted];
}
