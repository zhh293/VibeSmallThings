import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';

class PeerData {
  final String peerId;
  final List<int> data;

  const PeerData({required this.peerId, required this.data});
}

abstract class DiscoveryStrategy {
  Stream<List<Peer>> get peers;
  Stream<PeerData> get onDataReceived;

  Future<void> startDiscovery();
  Future<void> stopDiscovery();
  Future<void> connect(Peer peer);
  Future<void> disconnect(Peer peer);
  Future<void> sendData(Peer peer, List<int> data);
}
