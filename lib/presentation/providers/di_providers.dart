import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repo_impl.dart';
import '../../data/repositories/course_repo_impl.dart';
import '../../data/repositories/profile_repo_impl.dart';
import '../../data/repositories/qna_repo_impl.dart';
import '../../data/repositories/assignment_repo_impl.dart';
import '../../data/repositories/quiz_attempts_repo_impl.dart';
import '../../data/repositories/notifications_repo_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../../domain/repositories/i_qna_repository.dart';
import '../../domain/repositories/i_assignment_repository.dart';
import '../../domain/repositories/i_quiz_attempts_repository.dart';
import '../../domain/repositories/i_notifications_repository.dart';
import '../../domain/usecases/usecases.dart';

// ── Repositories ──────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<IAuthRepository>(
  (_) => AuthRepositoryImpl(),
);

final courseRepositoryProvider = Provider<ICourseRepository>(
  (_) => CourseRepositoryImpl(),
);

final profileRepositoryProvider = Provider<IProfileRepository>(
  (_) => ProfileRepositoryImpl(),
);

final qnaRepositoryProvider = Provider<IQnaRepository>(
  (_) => QnaRepositoryImpl(),
);

final assignmentRepositoryProvider = Provider<IAssignmentRepository>(
  (_) => AssignmentRepositoryImpl(),
);

final quizAttemptsRepositoryProvider = Provider<IQuizAttemptsRepository>(
  (_) => QuizAttemptsRepositoryImpl(),
);

// ── Use cases ─────────────────────────────────────────────────────────────────

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider(
  (ref) => LogoutUseCase(ref.read(authRepositoryProvider)),
);

final getCoursesUseCaseProvider = Provider(
  (ref) => GetCoursesUseCase(ref.read(courseRepositoryProvider)),
);

final getCourseDetailUseCaseProvider = Provider(
  (ref) => GetCourseDetailUseCase(ref.read(courseRepositoryProvider)),
);

final getQuizAttemptsUseCaseProvider = Provider(
  (ref) => GetQuizAttemptsUseCase(ref.read(quizAttemptsRepositoryProvider)),
);

final notificationsRepositoryProvider = Provider<INotificationsRepository>(
  (_) => NotificationsRepositoryImpl(),
);

final getNotificationsUseCaseProvider = Provider(
  (ref) => GetNotificationsUseCase(ref.read(notificationsRepositoryProvider)),
);

final markNotificationsReadUseCaseProvider = Provider(
  (ref) =>
      MarkNotificationsReadUseCase(ref.read(notificationsRepositoryProvider)),
);

final getTopicsUseCaseProvider = Provider(
  (ref) => GetTopicsUseCase(ref.read(courseRepositoryProvider)),
);

final getLessonsUseCaseProvider = Provider(
  (ref) => GetLessonsUseCase(ref.read(courseRepositoryProvider)),
);

final markLessonCompleteUseCaseProvider = Provider(
  (ref) => MarkLessonCompleteUseCase(ref.read(courseRepositoryProvider)),
);

final markCourseCompleteUseCaseProvider = Provider(
  (ref) => MarkCourseCompleteUseCase(ref.read(courseRepositoryProvider)),
);

final enrollCourseUseCaseProvider = Provider(
  (ref) => EnrollCourseUseCase(ref.read(courseRepositoryProvider)),
);

final getProfileUseCaseProvider = Provider(
  (ref) => GetProfileUseCase(ref.read(profileRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider(
  (ref) => UpdateProfileUseCase(ref.read(profileRepositoryProvider)),
);

final uploadAvatarUseCaseProvider = Provider(
  (ref) => UploadAvatarUseCase(ref.read(profileRepositoryProvider)),
);

final getInstructorInfoUseCaseProvider = Provider(
  (ref) => GetInstructorInfoUseCase(ref.read(profileRepositoryProvider)),
);

final getReviewsUseCaseProvider = Provider(
  (ref) => GetReviewsUseCase(ref.read(profileRepositoryProvider)),
);

final submitReviewUseCaseProvider = Provider(
  (ref) => SubmitReviewUseCase(ref.read(profileRepositoryProvider)),
);

final getQnaUseCaseProvider = Provider(
  (ref) => GetQnaUseCase(ref.read(qnaRepositoryProvider)),
);

final postQnaUseCaseProvider = Provider(
  (ref) => PostQnaUseCase(ref.read(qnaRepositoryProvider)),
);

final getAssignmentsUseCaseProvider = Provider(
  (ref) => GetAssignmentsUseCase(ref.read(assignmentRepositoryProvider)),
);

final getAssignmentUseCaseProvider = Provider(
  (ref) => GetAssignmentUseCase(ref.read(assignmentRepositoryProvider)),
);

final submitAssignmentUseCaseProvider = Provider(
  (ref) => SubmitAssignmentUseCase(ref.read(assignmentRepositoryProvider)),
);
