import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/quiz_attempt.dart';
import 'di_providers.dart';

final quizAttemptsProvider =
    FutureProvider.family<List<QuizAttempt>, int>((ref, courseId) async {
  final result = await ref.read(getQuizAttemptsUseCaseProvider).call(courseId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (items) => items,
  );
});
