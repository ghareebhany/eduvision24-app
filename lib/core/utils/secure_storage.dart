import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Token ─────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<String?> getToken() =>
      _storage.read(key: AppConstants.tokenKey);

  Future<void> deleteToken() =>
      _storage.delete(key: AppConstants.tokenKey);

  // ── Nonce — محذوف بالكامل ─────────────────────────────────────────────────
  //
  // X-WP-Nonce لا يُستخدم في التطبيق المحمول.
  // الـ nonce مخصص للمتصفح (cookie session).
  // إرساله من التطبيق يُسبب تعارضاً مع JWT ويجعل WordPress
  // يحل هوية المستخدم بناءً على الـ nonce لا الـ JWT.
  //
  // نُبقي على saveNonce/getNonce/deleteNonce كـ stubs فارغة آمنة
  // حتى لا تنكسر أجزاء أخرى تستدعيها (إن وُجدت).
  Future<void> saveNonce(String nonce) async {}   // no-op
  Future<String?> getNonce() async => null;        // always null
  Future<void> deleteNonce() async {}              // no-op

  // ── User meta ─────────────────────────────────────────────────────────────
  Future<void> saveUserId(int id) =>
      _storage.write(key: AppConstants.userIdKey, value: id.toString());

  Future<int?> getUserId() async {
    final raw = await _storage.read(key: AppConstants.userIdKey);
    return raw != null ? int.tryParse(raw) : null;
  }

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: AppConstants.userEmailKey, value: email);

  Future<String?> getUserEmail() =>
      _storage.read(key: AppConstants.userEmailKey);

  Future<void> saveDisplayName(String name) =>
      _storage.write(key: AppConstants.userDisplayNameKey, value: name);

  Future<String?> getDisplayName() =>
      _storage.read(key: AppConstants.userDisplayNameKey);

  // ── Clear all ─────────────────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();

  // ── Auth state ────────────────────────────────────────────────────────────
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
