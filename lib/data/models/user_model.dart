import 'dart:convert';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.avatarUrl,
    required super.token,
    super.bio = '',
    super.website = '',
    super.phone = '',
  });

  /// From JWT /token endpoint
  ///
  /// ── إصلاح السبب الجذري ────────────────────────────────────────────────────
  /// مشكلة التشخيص: JWT Auth Plugin لا يُضمّن user_id في الـ response body،
  /// فيُعيد json['user_id'] == null → id = 0 لجميع المستخدمين.
  ///
  /// النتيجة:
  ///   • CacheManager.setCurrentUser(0) → لا عزل بين الحسابات
  ///   • ProfileRepository يُخزّن "profile_0" أو "u0_profile_0"
  ///   • كل مستخدم يرى نفس الـ cache → hany55 يرى profile hany2
  ///
  /// الحل: نستخرج user_id من JWT payload مباشرة كـ fallback موثوق.
  /// JWT Auth Plugin يُخزّنه في: data.user.id  (بنية ثابتة)
  factory UserModel.fromLoginJson(Map<String, dynamic> json) {
    final token = json['token'] as String? ?? '';

    // ── 1. من الـ response body (يعمل إذا أضاف الـ server user_id) ─────────
    final rawId = json['user_id'];
    int id = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    // ── 2. من JWT payload — fallback أساسي ───────────────────────────────
    if (id == 0 && token.isNotEmpty) {
      id = _parseUserIdFromJwt(token);
    }

    return UserModel(
      id: id,
      email: json['user_email'] as String? ?? '',
      displayName: json['user_display_name'] as String? ??
          json['user_nicename'] as String? ??
          '',
      avatarUrl: '',
      token: token,
    );
  }

  /// يفك ترميز JWT payload (base64url) ويستخرج user_id
  /// البنية التي يُنتجها JWT Auth Plugin:
  ///   {"iss":..., "data": {"user": {"id": "1518"}}}
  static int _parseUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return 0;

      // base64url → base64 مع padding
      var b64 = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      b64 = b64.padRight(b64.length + (4 - b64.length % 4) % 4, '=');

      final payload = json.decode(utf8.decode(base64.decode(b64)))
          as Map<String, dynamic>?;
      if (payload == null) return 0;

      // JWT Auth Plugin: data.user.id
      final data = payload['data'];
      if (data is Map) {
        final user = data['user'];
        if (user is Map) {
          final v = user['id'] ?? user['ID'];
          if (v != null) return int.tryParse(v.toString()) ?? 0;
        }
      }
      // fallbacks: user_id أو sub
      final alt = payload['user_id'] ?? payload['sub'];
      if (alt != null) return int.tryParse(alt.toString()) ?? 0;

      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// From /app/v1/profile/me
  factory UserModel.fromProfileJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserModel(
      id: _parseInt(data['ID'] ?? data['id']),
      email: data['user_email'] as String? ?? '',
      displayName: data['display_name'] as String? ??
          data['name'] as String? ??
          '',
      avatarUrl: data['avatar_url'] as String? ??
          data['profile_photo_url'] as String? ??
          '',
      token: '',
      bio: data['description'] as String? ?? data['bio'] as String? ?? '',
      website: data['user_url'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'display_name': displayName,
        'description': bio,
        'user_url': website,
        'phone': phone,
      };

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
