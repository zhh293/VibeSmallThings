import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geek_toolbox/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';
import 'package:geek_toolbox/features/mesh_messenger/presentation/chat_screen.dart';
import 'package:geek_toolbox/features/mesh_messenger/presentation/providers/mesh_provider.dart';

class MeshMessengerScreen extends ConsumerStatefulWidget {
  const MeshMessengerScreen({super.key});

  @override
  ConsumerState<MeshMessengerScreen> createState() =>
      _MeshMessengerScreenState();
}

class _MeshMessengerScreenState extends ConsumerState<MeshMessengerScreen> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    // Auto-start discovery when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meshRepositoryProvider).startDiscovery();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPeerTap(Peer peer) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(peer: peer)));
  }

  @override
  Widget build(BuildContext context) {
    final peersAsync = ref.watch(meshPeersProvider);
    final peers = peersAsync.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MESH RADAR'),
        actions: [
          Switch(
            value: _isScanning,
            onChanged: (val) {
              setState(() {
                _isScanning = val;
                if (_isScanning) {
                  ref.read(meshRepositoryProvider).startDiscovery();
                } else {
                  ref.read(meshRepositoryProvider).stopDiscovery();
                }
              });
            },
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Radar Background
          Center(child: _RadarView(isScanning: _isScanning)),

          // Device List Overlay (Bottom Sheet like)
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NEARBY DEVICES (${peers.length})',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isScanning && peers.isEmpty)
                      const Center(child: Text('Scanning for mesh nodes...'))
                    else
                      ...peers.map(
                        (peer) => ListTile(
                          onTap: () => _onPeerTap(peer),
                          leading: Icon(
                            peer.type == ConnectionType.ble
                                ? Icons.bluetooth
                                : Icons.wifi,
                            color: peer.status == PeerStatus.connected
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          ),
                          title: Text(
                            peer.deviceName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Signal: ${peer.rssi} dBm',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RadarView extends StatefulWidget {
  final bool isScanning;

  const _RadarView({required this.isScanning});

  @override
  State<_RadarView> createState() => _RadarViewState();
}

class _RadarViewState extends State<_RadarView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_RadarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 300),
          painter: _RadarPainter(
            scanAngle: _controller.value * 2 * 3.14159,
            color: AppTheme.primaryColor,
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double scanAngle;
  final Color color;

  _RadarPainter({required this.scanAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw concentric circles
    for (var i = 1; i <= 4; i++) {
      paint.color = color.withOpacity(0.2 + (i * 0.1));
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    // Draw crosshairs
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint..color = color.withOpacity(0.3),
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Draw sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: scanAngle - 1.0, // Trail length
        endAngle: scanAngle,
        colors: [color.withOpacity(0.0), color.withOpacity(0.5)],
        stops: const [0.0, 1.0],
        transform: GradientRotation(scanAngle), // Rotate the gradient
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.scanAngle != scanAngle;
  }
}
