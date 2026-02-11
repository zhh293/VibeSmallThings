import 'package:cryptography/cryptography.dart';

class CryptoService {
  final _algorithm = X25519();
  final _cipher = AesGcm.with256bits();
  
  SimpleKeyPair? _myKeyPair;
  final Map<String, SecretKey> _sharedKeys = {};

  Future<void> init() async {
    if (_myKeyPair == null) {
      _myKeyPair = await _algorithm.newKeyPair();
    }
  }

  Future<PublicKey> get myPublicKey async {
    await init();
    return await _myKeyPair!.extractPublicKey();
  }

  // Handshake: Calculate shared secret
  Future<void> computeSharedSecret(String peerId, List<int> remotePublicKeyBytes) async {
    await init();
    final remotePublicKey = SimplePublicKey(
      remotePublicKeyBytes,
      type: KeyPairType.x25519,
    );

    final sharedSecret = await _algorithm.sharedSecretKey(
      keyPair: _myKeyPair!,
      remotePublicKey: remotePublicKey,
    );

    // Derive a session key (e.g., using HKDF, but for now using the shared secret directly or hashed)
    // The sharedSecretKey returns a SharedSecretKey, which might not be directly usable as SecretKey for AES-GCM
    // We typically extract bytes and use them.
    final secretBytes = await sharedSecret.extractBytes();
    
    // Create an AES-GCM key from these bytes
    // Note: X25519 shared secret is 32 bytes, which fits AES-256
    final sessionKey = await _cipher.newSecretKeyFromBytes(secretBytes);
    _sharedKeys[peerId] = sessionKey;
  }

  Future<List<int>> encrypt(String peerId, List<int> plaintext) async {
    final key = _sharedKeys[peerId];
    if (key == null) throw Exception('No shared key for peer $peerId');

    final secretBox = await _cipher.encrypt(
      plaintext,
      secretKey: key,
    );

    return secretBox.concatenation();
  }

  Future<List<int>> decrypt(String peerId, List<int> ciphertext) async {
    final key = _sharedKeys[peerId];
    if (key == null) throw Exception('No shared key for peer $peerId');

    final secretBox = SecretBox.fromConcatenation(
      ciphertext,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );

    return await _cipher.decrypt(
      secretBox,
      secretKey: key,
    );
  }
}
