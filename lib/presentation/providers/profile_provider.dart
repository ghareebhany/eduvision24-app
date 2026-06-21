import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/user.dart';
import 'di_providers.dart';

// ── Profile Provider ──────────────────────────────────────────────────────────
//
// ✅ إصلاح تصميمي جوهري (بناءً على تقرير الخبير):
//
// ❌ كان: يعتمد على authProvider داخلياً → أي تغيير في auth يُعيد بناء الـ provider
// ❌ كان: catch يُعيد authState.user → يُخفي أخطاء API ويُظهر بيانات قديمة
// ❌ كان: إذا userId != authState.user.id → يُعيد authState.user بصمت
//
// ✅ الآن: الـ provider يعتمد فقط على userId كمعامل
//          إذا فشل الطلب → يُرمى Exception حقيقي → الـ UI يُظهر error state
//          لا fallback لبيانات قديمة بأي شكل

final profileProvider =
    FutureProvider.autoDispose.family<User, int>((ref, userId) async {
  // لا اعتماد على authProvider هنا — userId يأتي من auth_provider مباشرةً
  // والـ UI هو المسؤول عن التحقق من حالة المصادقة قبل استدعاء هذا الـ provider
  final result = await ref.read(getProfileUseCaseProvider).call(userId);

  return result.fold(
    (failure) => throw Exception(failure.message), // ← خطأ حقيقي يصل للـ UI
    (user)    => user,                              // ← بيانات صحيحة فقط
  );
  // ❌ لا catch هنا — الأخطاء تُظهر في الـ UI كـ error state
  // ❌ لا fallback لـ authState.user
});

// ── Instructor info ───────────────────────────────────────────────────────────

final instructorProvider =
    FutureProvider.family<User, int>((ref, instructorId) async {
  final result =
      await ref.read(getInstructorInfoUseCaseProvider).call(instructorId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

// ── Reviews ───────────────────────────────────────────────────────────────────

final reviewsProvider =
    FutureProvider.family<List<Review>, int>((ref, courseId) async {
  final result = await ref
      .read(getReviewsUseCaseProvider)
      .call(courseId: courseId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (reviews) => reviews,
  );
});

// ── Update profile notifier ───────────────────────────────────────────────────

class UpdateProfileState {
  final bool isLoading;
  final bool success;
  final String? error;
  const UpdateProfileState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });
}

class UpdateProfileNotifier extends StateNotifier<UpdateProfileState> {
  final Ref _ref;
  UpdateProfileNotifier(this._ref) : super(const UpdateProfileState());

  Future<void> update(Map<String, dynamic> data) async {
    state = const UpdateProfileState(isLoading: true);
    final result = await _ref.read(updateProfileUseCaseProvider).call(data);
    result.fold(
      (f) => state = UpdateProfileState(error: f.message),
      (_) => state = const UpdateProfileState(success: true),
    );
  }

  void reset() => state = const UpdateProfileState();
}

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, UpdateProfileState>(
  (ref) => UpdateProfileNotifier(ref),
);

// ── Avatar upload notifier ───────────────────────────────────

class AvatarUploadState {
  final bool isLoading;
  final bool success;
  final String? error;
  const AvatarUploadState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });
}

class AvatarUploadNotifier extends StateNotifier<AvatarUploadState> {
  final Ref _ref;
  AvatarUploadNotifier(this._ref) : super(const AvatarUploadState());

  Future<bool> upload(String filePath) async {
    state = const AvatarUploadState(isLoading: true);
    final result = await _ref.read(uploadAvatarUseCaseProvider).call(filePath);
    return result.fold(
      (f) {
        state = AvatarUploadState(error: f.message);
        return false;
      },
      (_) {
        state = const AvatarUploadState(success: true);
        return true;
      },
    );
  }

  void reset() => state = const AvatarUploadState();
}

final avatarUploadProvider =
    StateNotifierProvider<AvatarUploadNotifier, AvatarUploadState>(
  (ref) => AvatarUploadNotifier(ref),
);

// ── Submit review notifier ──────────────────────────────────────

class SubmitReviewState {
  final bool isLoading;
  final bool success;
  final String? error;
  const SubmitReviewState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });
}

class SubmitReviewNotifier extends StateNotifier<SubmitReviewState> {
  final Ref _ref;
  SubmitReviewNotifier(this._ref) : super(const SubmitReviewState());

  Future<bool> submit({
    required int courseId,
    required double rating,
    String review = '',
  }) async {
    state = const SubmitReviewState(isLoading: true);
    final result = await _ref.read(submitReviewUseCaseProvider).call(
          courseId: courseId,
          rating: rating,
          review: review,
        );
    return result.fold(
      (f) {
        state = SubmitReviewState(error: f.message);
        return false;
      },
      (_) {
        state = const SubmitReviewState(success: true);
        // أعد تحميل قائمة التقييمات وتفاصيل الكورس (المتوسط)
        _ref.invalidate(reviewsProvider(courseId));
        return true;
      },
    );
  }

  void reset() => state = const SubmitReviewState();
}

final submitReviewProvider =
    StateNotifierProvider<SubmitReviewNotifier, SubmitReviewState>(
  (ref) => SubmitReviewNotifier(ref),
);
