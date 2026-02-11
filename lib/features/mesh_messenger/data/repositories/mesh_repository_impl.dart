import 'dart:async';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:geek_toolbox/features/mesh_messenger/data/datasources/ble_discovery_strategy.dart';
import 'package:geek_toolbox/features/mesh_messenger/data/datasources/wifi_discovery_strategy.dart';
import 'package:geek_toolbox/features/mesh_messenger/data/models/message_model.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/message.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/repositories/discovery_strategy.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/repositories/mesh_repository.dart';
import 'package:path_provider/path_provider.dart';

class MeshRepositoryImpl implements MeshRepository {
  final BleDiscoveryStrategy _bleStrategy;
  final WifiDiscoveryStrategy _wifiStrategy;
  Isar? _isar;

  final _peersController = StreamController<List<Peer>>.broadcast();
  final List<Peer> _currentPeers = [];

  MeshRepositoryImpl({
    BleDiscoveryStrategy? bleStrategy,
    WifiDiscoveryStrategy? wifiStrategy,
  }) : _bleStrategy = bleStrategy ?? BleDiscoveryStrategy(),
       _wifiStrategy = wifiStrategy ?? WifiDiscoveryStrategy();

  Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([MessageModelSchema], directory: dir.path);

    // Listen to strategies
    _bleStrategy.peers.listen(_updatePeers);
    _wifiStrategy.peers.listen(_updatePeers);

    // Listen to incoming data
    _bleStrategy.onDataReceived.listen(_handleIncomingData);
    _wifiStrategy.onDataReceived.listen(_handleIncomingData);
  }

  void _handleIncomingData(PeerData data) async {
    try {
      // Basic decoding for now (UTF-8)
      final content = utf8.decode(data.data);
      // Construct message (assuming text)
      // In real implementation, we'd parse protocol headers
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: data.peerId,
        receiverId: 'me',
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now(),
      );

      await saveMessage(message);
    } catch (e) {
      print('Error handling incoming data: $e');
    }
  }

  // ... _updatePeers

  @override
  Future<void> sendMessage(Message message) async {
    await saveMessage(message);

    // Find peer to send to
    try {
      final peer = _currentPeers.firstWhere((p) => p.id == message.receiverId);
      final data = utf8.encode(message.content);

      if (peer.type == ConnectionType.ble) {
        await _bleStrategy.sendData(peer, data);
      } else if (peer.type == ConnectionType.wifi) {
        await _wifiStrategy.sendData(peer, data);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Future<void> saveMessage(Message message) async {
    await init();
    final model = MessageModel.fromDomain(message);
    await _isar!.writeTxn(() async {
      await _isar!.messageModels.put(model);
    });
  }

  @override
  Stream<List<Message>> getMessages(String peerId) async* {
    await init();
    // Yield initial query
    yield* _isar!.messageModels
        .filter()
        .senderIdEqualTo(peerId)
        .or()
        .receiverIdEqualTo(peerId)
        .sortByTimestamp()
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }
}
