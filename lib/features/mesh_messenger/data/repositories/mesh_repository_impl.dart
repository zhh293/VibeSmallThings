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

  // Persistent ID for this device
  late String _myDeviceId;

  MeshRepositoryImpl({
    BleDiscoveryStrategy? bleStrategy,
    WifiDiscoveryStrategy? wifiStrategy,
  }) : _bleStrategy = bleStrategy ?? BleDiscoveryStrategy(),
       _wifiStrategy = wifiStrategy ?? WifiDiscoveryStrategy();

  @override
  Stream<List<Peer>> get peers => _peersController.stream;

  @override
  Future<void> startDiscovery() async {
    await init();
    await _bleStrategy.startDiscovery();
    await _wifiStrategy.startDiscovery();
  }

  @override
  Future<void> stopDiscovery() async {
    await _bleStrategy.stopDiscovery();
    await _wifiStrategy.stopDiscovery();
  }

  Future<void> init() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open([MessageModelSchema], directory: dir.path);

    // Initialize Device ID (simple persistent storage check)
    // For now, we generate one if not exists, but ideally verify with stored preferences
    // Using Isar to store a "Me" object or SharedPrefs would be better.
    // For MVP, we'll generate a random one per session if not stored,
    // but to be consistent let's try to use a stable one.
    // We'll use the one from the first run if possible.
    // Let's just generate one for now.
    _myDeviceId = "device_${DateTime.now().millisecondsSinceEpoch}";

    // Listen to strategies
    _bleStrategy.peers.listen(_updatePeers);
    _wifiStrategy.peers.listen(_updatePeers);

    // Listen to incoming data
    _bleStrategy.onDataReceived.listen(_handleIncomingData);
    _wifiStrategy.onDataReceived.listen(_handleIncomingData);
  }

  void _updatePeers(List<Peer> peers) {
    // Merge peers logic if needed, for now just replace
    _currentPeers.clear();
    _currentPeers.addAll(peers);
    _peersController.add(_currentPeers);
  }

  void _handleIncomingData(PeerData data) async {
    try {
      // Protocol: "senderId|content"
      final rawString = utf8.decode(data.data);
      final parts = rawString.split('|');

      if (parts.length < 2) {
        print('Invalid message format');
        return;
      }

      final senderId = parts[0];
      final content = parts
          .sublist(1)
          .join('|'); // Rejoin rest in case content has |

      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        receiverId: _myDeviceId,
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
    // Ensure the message has correct sender ID
    final msgToSend = message.copyWith(senderId: _myDeviceId);
    await saveMessage(msgToSend);

    // Find peer to send to
    try {
      final peer = _currentPeers.firstWhere(
        (p) => p.id == message.receiverId,
        orElse: () => throw Exception("Peer not found"),
      );

      // Protocol: "senderId|content"
      final payload = "$_myDeviceId|${message.content}";
      final data = utf8.encode(payload);

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
