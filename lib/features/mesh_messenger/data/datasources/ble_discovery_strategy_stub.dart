import 'dart:async';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/repositories/discovery_strategy.dart';

class BleDiscoveryStrategy implements DiscoveryStrategy {
  final _peersController = StreamController<List<Peer>>.broadcast();
  final _dataController = StreamController<PeerData>.broadcast();

  @override
  Stream<List<Peer>> get peers => _peersController.stream;

  @override
  Stream<PeerData> get onDataReceived => _dataController.stream;

  @override
  Future<void> startDiscovery() async {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<void> stopDiscovery() async {}

  @override
  Future<void> connect(Peer peer) async {}

  @override
  Future<void> disconnect(Peer peer) async {}

  @override
  Future<void> sendData(Peer peer, List<int> data) async {}
}
