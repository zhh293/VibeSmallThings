import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/features/mesh_messenger/data/repositories/mesh_repository_impl.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/message.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/entities/peer.dart';
import 'package:geek_toolbox/features/mesh_messenger/domain/repositories/mesh_repository.dart';

// Singleton instance of the repository
final meshRepositoryProvider = Provider<MeshRepository>((ref) {
  final repo = MeshRepositoryImpl();
  // Initialize immediately (or lazily)
  repo.init();
  return repo;
});

// Stream of discovered peers
final meshPeersProvider = StreamProvider<List<Peer>>((ref) {
  final repo = ref.watch(meshRepositoryProvider);
  return repo.peers;
});

// Stream of messages for a specific peer
final meshMessagesProvider = StreamProvider.family<List<Message>, String>((ref, peerId) {
  final repo = ref.watch(meshRepositoryProvider);
  return repo.getMessages(peerId);
});
