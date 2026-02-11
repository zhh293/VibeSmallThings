import 'package:geek_toolbox/features/mesh_messenger/domain/entities/message.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';

abstract class MeshRepository {
  // Discovery
  Stream<List<Peer>> get peers;
  Future<void> startDiscovery();
  Future<void> stopDiscovery();

  // Communication
  Future<void> sendMessage(Message message);
  Stream<List<Message>> getMessages(String peerId);
  Future<void> saveMessage(Message message);
}
