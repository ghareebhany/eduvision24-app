import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/assignment.dart';
import '../../domain/entities/qna.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/review.dart';
import 'auth_provider.dart';
import 'dashboard_provider.dart';
import 'di_providers.dart';

/// مرجع مختصر لكورس مُسجَّل به الطالب (يُستخدم لتجميع عناصر كل الكورسات).
class CourseRef {
  final int id;
  final String title;
  const CourseRef(this.id, this.title);
}

/// عنصر في قسم "كل ما يخصّك" مرفقًا معه الكورس الذي ينتمي إليه.
class HubEntry<T> {
  final CourseRef course;
  final T item;
  const HubEntry(this.course, this.item);
}

/// كل الكورسات المُسجَّل بها الطالب (تُجمَع عبر كل الصفحات).
final enrolledCoursesRefProvider = FutureProvider<List<CourseRef>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) {
    throw Exception('يرجى تسجيل الدخول أولاً');
  }

  final List<CourseRef> all = [];
  var page = 1;
  while (page <= 20) {
    final data = await ref.watch(
      myCoursesProvider(MyCoursesFilter(status: 'all', page: page)).future,
    );
    for (final c in data.courses) {
      all.add(CourseRef(c.id, c.title));
    }
    if (data.courses.isEmpty || page >= data.totalPages) break;
    page++;
  }
  return all;
});

/// محاولات الاختبارات عبر كل الكورسات.
final myQuizAttemptsProvider =
    FutureProvider<List<HubEntry<QuizAttempt>>>((ref) async {
  final courses = await ref.watch(enrolledCoursesRefProvider.future);
  final useCase = ref.read(getQuizAttemptsUseCaseProvider);
  final lists = await Future.wait(courses.map((c) async {
    final res = await useCase.call(c.id);
    return res.fold(
      (_) => <HubEntry<QuizAttempt>>[],
      (items) => items.map((e) => HubEntry<QuizAttempt>(c, e)).toList(),
    );
  }));
  return lists.expand((e) => e).toList();
});

/// تسليمات الواجبات عبر كل الكورسات.
final myAssignmentsProvider =
    FutureProvider<List<HubEntry<Assignment>>>((ref) async {
  final courses = await ref.watch(enrolledCoursesRefProvider.future);
  final useCase = ref.read(getAssignmentsUseCaseProvider);
  final lists = await Future.wait(courses.map((c) async {
    final res = await useCase.call(c.id);
    return res.fold(
      (_) => <HubEntry<Assignment>>[],
      (items) => items.map((e) => HubEntry<Assignment>(c, e)).toList(),
    );
  }));
  return lists.expand((e) => e).toList();
});

/// أسئلة الطالب (الجذرية فقط، ومن تأليفه) عبر كل الكورسات.
final myQuestionsProvider =
    FutureProvider<List<HubEntry<QnaItem>>>((ref) async {
  final courses = await ref.watch(enrolledCoursesRefProvider.future);
  final userId = ref.watch(currentUserIdProvider);
  final useCase = ref.read(getQnaUseCaseProvider);
  final lists = await Future.wait(courses.map((c) async {
    final res = await useCase.call(c.id);
    return res.fold(
      (_) => <HubEntry<QnaItem>>[],
      (items) => items
          .where((q) =>
              q.parentId == 0 && (userId == 0 || q.authorId == userId))
          .map((e) => HubEntry<QnaItem>(c, e))
          .toList(),
    );
  }));
  return lists.expand((e) => e).toList();
});

/// تقييمات الطالب عبر كل الكورسات.
final myReviewsProvider =
    FutureProvider<List<HubEntry<Review>>>((ref) async {
  final courses = await ref.watch(enrolledCoursesRefProvider.future);
  final userId = ref.watch(currentUserIdProvider);
  final useCase = ref.read(getReviewsUseCaseProvider);
  final lists = await Future.wait(courses.map((c) async {
    final res = await useCase.call(courseId: c.id);
    return res.fold(
      (_) => <HubEntry<Review>>[],
      (items) => items
          .where((r) => userId == 0 || r.authorId == userId)
          .map((e) => HubEntry<Review>(c, e))
          .toList(),
    );
  }));
  return lists.expand((e) => e).toList();
});
