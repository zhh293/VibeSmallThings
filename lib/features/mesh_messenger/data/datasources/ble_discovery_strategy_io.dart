import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/repositories/discovery_strategy.dart';

class BleDiscoveryStrategy implements DiscoveryStrategy {
  // UUID for our Mesh Service
  static const String SERVICE_UUID =
      "12345678-1234-1234-1234-1234567890ab"; // TODO: Generate a real random UUID

  final _peersController = StreamController<List<Peer>>.broadcast();
  final _dataController = StreamController<PeerData>.broadcast();
  final Map<String, Peer> _discoveredPeers = {};
  StreamSubscription? _scanSubscription;

  @override
  Stream<List<Peer>> get peers => _peersController.stream;

  @override
  Stream<PeerData> get onDataReceived => _dataController.stream;

  @override
  Future<void> startDiscovery() async {
    // Check if Bluetooth is supported and on
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported");
      return;
    }

    // Listen to scan results
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.platformName.isNotEmpty) {
          final peer = Peer(
            id: r.device.remoteId.str,
            deviceName: r.device.platformName,
            status: PeerStatus.discovered,
            type: ConnectionType.ble,
            rssi: r.rssi,
            lastSeen: DateTime.now(),
          );
          _discoveredPeers[peer.id] = peer;
        }
      }
      _peersController.add(_discoveredPeers.values.toList());
    });

    // Start scanning
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      withServices: [], // Scan for all for now, later filter by SERVICE_UUID
    );
  }

  @override
  Future<void> stopDiscovery() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
  }

  @override
  Future<void> connect(Peer peer) async {
    // TODO: Implement BLE connection
  }

  @override
  Future<void> disconnect(Peer peer) async {
    // TODO: Implement BLE disconnection
  }

  @override
  Future<void> sendData(Peer peer, List<int> data) async {
    // TODO: Implement BLE write characteristic
  }
}
