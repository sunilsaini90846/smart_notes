import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // Singleton pattern
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // PBKDF2 parameters
  static const int _iterations = 10000;
  static const int _keyLength = 32; // 256 bits
  static const int _saltLength = 16; // 128 bits

  /// Derive a key from a password using PBKDF2
  Uint8List _deriveKey(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    
    var key = Uint8List.fromList(passwordBytes);
    for (var i = 0; i < _iterations; i++) {
      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(salt);
      key = Uint8List.fromList(digest.bytes);
    }
    
    // Ensure key is exactly 32 bytes
    if (key.length > _keyLength) {
      return Uint8List.fromList(key.sublist(0, _keyLength));
    } else if (key.length < _keyLength) {
      final paddedKey = Uint8List(_keyLength);
      paddedKey.setRange(0, key.length, key);
      return paddedKey;
    }
    
    return key;
  }

  /// Generate a random salt
  Uint8List _generateSalt() {
    final random = encrypt.IV.fromSecureRandom(_saltLength);
    return Uint8List.fromList(random.bytes);
  }

  /// Encrypt content using AES-GCM with password-based key derivation
  /// Returns base64 encoded string: salt:iv:encryptedData
  String encryptContent(String content, String password) {
    try {
      // Generate salt and derive key
      final salt = _generateSalt();
      final key = _deriveKey(password, salt);
      
      // Generate IV (Initialization Vector)
      final iv = encrypt.IV.fromSecureRandom(16);
      
      // Create encrypter
      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          encrypt.Key(key),
          mode: encrypt.AESMode.gcm,
        ),
      );
      
      // Encrypt the content
      final encrypted = encrypter.encrypt(content, iv: iv);
      
      // Combine salt, IV, and encrypted data
      final combined = <int>[];
      combined.addAll(salt);
      combined.addAll(iv.bytes);
      combined.addAll(encrypted.bytes);
      
      // Return as base64 encoded string
      return base64.encode(combined);
    } catch (e) {
      throw EncryptionException('Encryption failed: $e');
    }
  }

  /// Decrypt content using AES-GCM with password-based key derivation
  /// Input is base64 encoded string: salt:iv:encryptedData
  String decryptContent(String encryptedContent, String password) {
    try {
      // Decode from base64
      final combined = base64.decode(encryptedContent);
      
      // Extract salt, IV, and encrypted data
      if (combined.length < _saltLength + 16) {
        throw EncryptionException('Invalid encrypted data format');
      }
      
      final salt = Uint8List.fromList(combined.sublist(0, _saltLength));
      final iv = encrypt.IV(Uint8List.fromList(
        combined.sublist(_saltLength, _saltLength + 16),
      ));
      final encryptedBytes = Uint8List.fromList(
        combined.sublist(_saltLength + 16),
      );
      
      // Derive key from password and salt
      final key = _deriveKey(password, salt);
      
      // Create encrypter
      final encrypter = encrypt.Encrypter(
        encrypt.AES(
          encrypt.Key(key),
          mode: encrypt.AESMode.gcm,
        ),
      );
      
      // Decrypt the content
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(encryptedBytes),
        iv: iv,
      );
      
      return decrypted;
    } catch (e) {
      throw EncryptionException('Decryption failed: Invalid password or corrupted data');
    }
  }

  /// Verify if a password can decrypt the content
  bool verifyPassword(String encryptedContent, String password) {
    try {
      decryptContent(encryptedContent, password);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Hash a password for comparison (not used for encryption)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a random password
  String generatePassword({int length = 16}) {
    const charset = 
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = encrypt.IV.fromSecureRandom(length);
    return String.fromCharCodes(
      random.bytes.map((byte) => charset.codeUnitAt(byte % charset.length)),
    );
  }
}

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);

  @override
  String toString() => 'EncryptionException: $message';
}

