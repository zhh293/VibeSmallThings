import 'package:equatable/equatable.dart';

enum PeerStatus { discovered, connecting, connected, disconnected }
enum ConnectionType { ble, wifi, unknown }

class Peer extends Equatable {
  final String id;
  final String deviceName;
  final PeerStatus status;
  final ConnectionType type;
  final int rssi; // Signal strength
  final DateTime lastSeen;

  const Peer({
    required this.id,
    required this.deviceName,
    this.status = PeerStatus.discovered,
    this.type = ConnectionType.unknown,
    this.rssi = 0,
    required this.lastSeen,
  });

  Peer copyWith({
    String? id,
    String? deviceName,
    PeerStatus? status,
    ConnectionType? type,
    int? rssi,
    DateTime? lastSeen,
  }) {
    return Peer(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      status: status ?? this.status,
      type: type ?? this.type,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  List<Object?> get props => [id, deviceName, status, type, rssi, lastSeen];
}
