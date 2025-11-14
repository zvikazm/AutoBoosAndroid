import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing user credentials using secure storage.
class CredentialsService {
  static const _storage = FlutterSecureStorage();
  static const _usernameKey = 'library_username';
  static const _passwordKey = 'library_password';

  /// Save credentials to secure storage
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
  }

  /// Get stored username (returns null if not found)
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// Get stored password (returns null if not found)
  Future<String?> getPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  /// Check if credentials are stored
  Future<bool> hasStoredCredentials() async {
    final username = await getUsername();
    final password = await getPassword();
    return username != null && password != null;
  }

  /// Clear stored credentials (for logout)
  Future<void> clearCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }
}
