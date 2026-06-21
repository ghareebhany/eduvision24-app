import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/qna.dart';
import 'di_providers.dart';

// ── Q&A list ───────────────────────────────────────────────────

final qnaProvider =
    FutureProvider.autoDispose.family<List<QnaItem>, int>((ref, courseId) async {
  final result = await ref.read(getQnaUseCaseProvider).call(courseId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (items) => items,
  );
});

// ── Post question / answer notifier ───────────────────────────────────

class PostQnaState {
  final bool isLoading;
  final bool success;
  final String? error;
  const PostQnaState({
    this.isLoading = false,
    this.success = false,
    this.error,
  });
}

class PostQnaNotifier extends StateNotifier<PostQnaState> {
  final Ref _ref;
  PostQnaNotifier(this._ref) : super(const PostQnaState());

  Future<bool> post({
    required int courseId,
    required String content,
    int parentId = 0,
  }) async {
    state = const PostQnaState(isLoading: true);
    final result = await _ref.read(postQnaUseCaseProvider).call(
          courseId: courseId,
          content: content,
          parentId: parentId,
        );
    return result.fold(
      (f) {
        state = PostQnaState(error: f.message);
        return false;
      },
      (_) {
        state = const PostQnaState(success: true);
        _ref.invalidate(qnaProvider(courseId));
        return true;
      },
    );
  }

  void reset() => state = const PostQnaState();
}

final postQnaProvider =
    StateNotifierProvider<PostQnaNotifier, PostQnaState>(
  (ref) => PostQnaNotifier(ref),
);
