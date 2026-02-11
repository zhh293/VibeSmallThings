import 'dart:async';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/repositories/discovery_strategy.dart';

class WifiDiscoveryStrategy implements DiscoveryStrategy {
  static const String _serviceType = '_geektoolbox._tcp';
  static const int _defaultPort = 4000;

  final _peersController = StreamController<List<Peer>>.broadcast();
  final _dataController = StreamController<PeerData>.broadcast();
  final Map<String, Peer> _discoveredPeers = {};

  // mDNS
  BonsoirDiscovery? _discovery;
  BonsoirBroadcast? _broadcast;

  // TCP
  ServerSocket? _serverSocket;
  final Map<String, Socket> _activeConnections = {}; // peerId -> Socket
  final Map<String, BonsoirService> _resolvedServices =
      {}; // peerId -> Service Info (IP/Port)

  @override
  Stream<List<Peer>> get peers => _peersController.stream;

  @override
  Stream<PeerData> get onDataReceived => _dataController.stream;

  @override
  Future<void> startDiscovery() async {
    // 0. Start TCP Server
    try {
      _serverSocket = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        _defaultPort,
      );
      _serverSocket!.listen(
        _handleIncomingConnection,
        onError: (e) => print('TCP Server Error: $e'),
      );
      print('TCP Server listening on port ${_serverSocket!.port}');
    } catch (e) {
      print('Failed to bind TCP server: $e');
    }

    // 1. Start Broadcast (Advertising myself)
    final service = BonsoirService(
      name: 'GeekToolbox_${DateTime.now().millisecondsSinceEpoch}', // Unique ID
      type: _serviceType,
      port: _serverSocket?.port ?? _defaultPort,
    );

    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.ready;
    await _broadcast!.start();

    // 2. Start Discovery (Scanning others)
    _discovery = BonsoirDiscovery(type: _serviceType);
    await _discovery!.ready;

    _discovery!.eventStream!.listen((event) {
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        if (event.service != null) {
          event.service!.resolve(event.service!.serviceResolver);
        }
      } else if (event.type ==
          BonsoirDiscoveryEventType.discoveryServiceResolved) {
        if (event.service != null) {
          final service = event.service!;
          _resolvedServices[service.name] = service;

          final peer = Peer(
            id: service.name,
            deviceName: service.name, // Use name as device name for now
            status: PeerStatus.discovered,
            type: ConnectionType.wifi,
            lastSeen: DateTime.now(),
          );
          _discoveredPeers[peer.id] = peer;
          _peersController.add(_discoveredPeers.values.toList());
        }
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (event.service != null) {
          _discoveredPeers.remove(event.service!.name);
          _resolvedServices.remove(event.service!.name);
          _peersController.add(_discoveredPeers.values.toList());
        }
      }
    });

    await _discovery!.start();
  }

  void _handleIncomingConnection(Socket socket) {
    print(
      'New incoming TCP connection from ${socket.remoteAddress.address}:${socket.remotePort}',
    );
    // We don't know the peerID yet, usually there is a handshake.
    // For MVP, we treat connection as just a data pipe.
    // We might need to map IP back to PeerID if possible, or wait for first message containing ID.

    // For now, listen to data
    socket.listen(
      (data) {
        // TODO: Protocol handling (Length-Prefixed or delimiter)
        // Assuming raw data for now or need a way to identify sender
        // Ideally the first packet should contain Sender ID.
        // Let's assume we can map by IP if we have resolved services,
        // OR we just emit with a temporary ID or "unknown".

        // Try to find peer by IP (inefficient but works for small local networks)
        String peerId = 'unknown';
        _resolvedServices.forEach((id, service) {
          // Bonsoir doesn't always give IP easily in the Service object directly without attributes
          // But let's assume we handle it later.
          // For now, pass raw socket hash or address as ID if unknown
        });

        _dataController.add(PeerData(peerId: peerId, data: data));
      },
      onDone: () {
        socket.destroy();
      },
      onError: (e) {
        print('Socket error: $e');
        socket.destroy();
      },
    );
  }

  @override
  Future<void> stopDiscovery() async {
    await _discovery?.stop();
    await _broadcast?.stop();
    await _serverSocket?.close();
    for (var socket in _activeConnections.values) {
      socket.destroy();
    }
    _activeConnections.clear();
    _discovery = null;
    _broadcast = null;
    _serverSocket = null;
  }

  @override
  Future<void> connect(Peer peer) async {
    if (_activeConnections.containsKey(peer.id)) return;

    final service = _resolvedServices[peer.id];
    if (service == null) {
      print('Cannot connect: Service not resolved for ${peer.id}');
      return;
    }

    // Bonsoir service attributes might have IP, or we rely on host resolution.
    // Note: Bonsoir 'host' might be 'computer.local'.
    // We need the IP. BonsoirService doesn't expose IP directly in the simplified model sometimes.
    // However, usually `service.toJson()` or similar might show it, or we rely on MDNS resolution.
    // Let's assume standard mDNS resolution works for host.

    // Workaround: In many Flutter mDNS plugins, getting the IP is tricky.
    // If 'host' is available, Socket.connect handles DNS.
    // If service has attributes with 'ip', use that.

    try {
      // Trying to connect to the service host and port
      // service.host might be null or empty depending on platform implementation
      String host = service.host ?? '';
      if (host.isEmpty) {
        // Fallback or error
        print('Service host is empty for ${peer.id}');
        return;
      }

      final socket = await Socket.connect(host, service.port);
      _activeConnections[peer.id] = socket;

      // Update peer status
      final updatedPeer = _discoveredPeers[peer.id]?.copyWith(
        status: PeerStatus.connected,
      );
      if (updatedPeer != null) {
        _discoveredPeers[peer.id] = updatedPeer;
        _peersController.add(_discoveredPeers.values.toList());
      }

      // Listen to this socket too
      socket.listen(
        (data) {
          _dataController.add(PeerData(peerId: peer.id, data: data));
        },
        onDone: () {
          _activeConnections.remove(peer.id);
          _updatePeerStatus(peer.id, PeerStatus.disconnected);
        },
        onError: (e) {
          _activeConnections.remove(peer.id);
          _updatePeerStatus(peer.id, PeerStatus.disconnected);
        },
      );
    } catch (e) {
      print('Failed to connect to ${peer.id}: $e');
    }
  }

  void _updatePeerStatus(String peerId, PeerStatus status) {
    final updatedPeer = _discoveredPeers[peerId]?.copyWith(status: status);
    if (updatedPeer != null) {
      _discoveredPeers[peerId] = updatedPeer;
      _peersController.add(_discoveredPeers.values.toList());
    }
  }

  @override
  Future<void> disconnect(Peer peer) async {
    final socket = _activeConnections[peer.id];
    if (socket != null) {
      await socket.close();
      _activeConnections.remove(peer.id);
      _updatePeerStatus(peer.id, PeerStatus.disconnected);
    }
  }

  @override
  Future<void> sendData(Peer peer, List<int> data) async {
    final socket = _activeConnections[peer.id];
    if (socket != null) {
      socket.add(data);
      await socket.flush();
    } else {
      print('No active connection to ${peer.id}');
      // Try to connect if not connected?
      await connect(peer);
      // Retry send?
      _activeConnections[peer.id]?.add(data);
    }
  }
}
