import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../core/utils/secure_storage.dart';
import '../../core/utils/cache_manager.dart';
import 'di_providers.dart';
import 'profile_provider.dart';

sealed class AuthState { const AuthState(); }
class AuthInitial       extends AuthState { const AuthInitial(); }
class AuthLoading       extends AuthState { const AuthLoading(); }
class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthError         extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthInitial()) { _checkInitialAuth(); }

  // ── يتطلب تسجيل الدخول في كل مرة يُفتح فيها التطبيق ──────────────────────
  // لا نستعيد الجلسة من التخزين عند بدء التشغيل؛ نمسح أي رمز محفوظ
  // من جلسة سابقة ثم نضع الحالة "غير مسجّل" حتى تظهر شاشة الدخول دائماً.
  // الرمز يُحفظ ويُستخدم طبيعياً أثناء الجلسة بعد تسجيل الدخول.
  Future<void> _checkInitialAuth() async {
    try {
      await SecureStorageService.instance.clearAll();
      CacheManager.instance.clear();
      CacheManager.instance.clearCurrentUser();
    } catch (_) {
      // تجاهل — في كل الأحوال نطلب تسجيل الدخول
    }
    state = const AuthUnauthenticated();
  }

  Future<void> login(String username, String password) async {
    state = const AuthLoading();

    // امسح كل أثر للمستخدم السابق — Riverpod + in-memory cache
    _ref.invalidate(profileProvider);
    CacheManager.instance.clear();
    CacheManager.instance.clearCurrentUser();

    final result = await _ref.read(loginUseCaseProvider).call(username, password);

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user)    => state = AuthAuthenticated(user),
    );
  }

  Future<void> logout() async {
    _ref.invalidate(profileProvider);
    state = const AuthUnauthenticated();
    CacheManager.instance.clear();
    CacheManager.instance.clearCurrentUser();
    await _ref.read(logoutUseCaseProvider).call();
  }

  // ── FIX: تحديث auth state بعد تعديل الملف الشخصي ─────────────────────────
  // بدون هذا، authState.user يحتفظ بالبيانات القديمة
  // وأي شاشة تعتمد عليه (الـ header، الـ greeting) تُظهر بيانات قديمة
  void updateCurrentUser(User updated) {
    if (state is AuthAuthenticated) {
      final current = (state as AuthAuthenticated).user;
      state = AuthAuthenticated(User(
        id:          current.id,          // id لا يتغير
        email:       current.email,       // email لا يتغير
        token:       current.token,       // token لا يتغير
        displayName: updated.displayName,
        avatarUrl:   updated.avatarUrl,
        bio:         updated.bio,
        website:     updated.website,
        phone:       updated.phone,
      ));
      // حفظ displayName الجديد في SecureStorage للـ restart
      SecureStorageService.instance.saveDisplayName(updated.displayName);
    }
  }

  void forceLogout() {
    _ref.invalidate(profileProvider);
    CacheManager.instance.clear();
    CacheManager.instance.clearCurrentUser();
    state = const AuthUnauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authProvider) is AuthAuthenticated,
);
