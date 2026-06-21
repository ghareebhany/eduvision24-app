import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/assignment.dart';
import 'di_providers.dart';

/// قائمة واجبات الكورس.
final assignmentsProvider =
    FutureProvider.family<List<Assignment>, int>((ref, courseId) async {
  final res = await ref.read(getAssignmentsUseCaseProvider).call(courseId);
  return res.fold((f) => throw Exception(f.message), (list) => list);
});

/// تفاصيل واجب واحد (مع تسليم المستخدم).
final assignmentDetailProvider =
    FutureProvider.family<Assignment, int>((ref, assignmentId) async {
  final res = await ref.read(getAssignmentUseCaseProvider).call(assignmentId);
  return res.fold((f) => throw Exception(f.message), (a) => a);
});

/// حالة إرسال التسليم.
class SubmitAssignmentState {
  final bool loading;
  final String? error;
  const SubmitAssignmentState({this.loading = false, this.error});
}

class SubmitAssignmentNotifier extends StateNotifier<SubmitAssignmentState> {
  final Ref _ref;
  SubmitAssignmentNotifier(this._ref)
      : super(const SubmitAssignmentState());

  Future<bool> submit({
    required int assignmentId,
    required int courseId,
    String answer = '',
    List<File> files = const [],
  }) async {
    state = const SubmitAssignmentState(loading: true);
    final res = await _ref.read(submitAssignmentUseCaseProvider).call(
          assignmentId: assignmentId,
          courseId: courseId,
          answer: answer,
          files: files,
        );
    return res.fold(
      (f) {
        state = SubmitAssignmentState(error: f.message);
        return false;
      },
      (_) {
        state = const SubmitAssignmentState();
        // تحديث التفاصيل والقائمة
        _ref.invalidate(assignmentDetailProvider(assignmentId));
        _ref.invalidate(assignmentsProvider(courseId));
        return true;
      },
    );
  }
}

final submitAssignmentProvider =
    StateNotifierProvider<SubmitAssignmentNotifier, SubmitAssignmentState>(
  (ref) => SubmitAssignmentNotifier(ref),
);
