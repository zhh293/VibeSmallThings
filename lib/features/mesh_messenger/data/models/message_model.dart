import 'package:isar/isar.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/message.dart';

part 'message_model.g.dart';

@collection
class MessageModel {
  Id id = Isar.autoIncrement; // Isar id

  @Index(unique: true, replace: true)
  late String messageId; // UUID

  late String senderId;
  late String receiverId;
  late String content;

  @Enumerated(EnumType.name)
  late MessageType type;

  @Enumerated(EnumType.name)
  late MessageStatus status;

  late DateTime timestamp;
  late bool isEncrypted;

  // Mapper to Domain
  Message toDomain() {
    return Message(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      status: status,
      timestamp: timestamp,
      isEncrypted: isEncrypted,
    );
  }

  // Mapper from Domain
  static MessageModel fromDomain(Message message) {
    return MessageModel()
      ..messageId = message.id
      ..senderId = message.senderId
      ..receiverId = message.receiverId
      ..content = message.content
      ..type = message.type
      ..status = message.status
      ..timestamp = message.timestamp
      ..isEncrypted = message.isEncrypted;
  }
}
