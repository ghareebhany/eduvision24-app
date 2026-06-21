class ApiConstants {
  ApiConstants._();

  // ── Base URLs ─────────────────────────────────────────────────────────────
  // قابل للتغيير عبر: flutter build apk --dart-define=SITE_URL=https://...
  static const String siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'https://eduvision3.com',
  );
  static const String baseUrl = '$siteUrl/wp-json';

  // ── Auth: JWT Auth Plugin ─────────────────────────────────────────────────
  static const String loginEndpoint         = '/jwt-auth/v1/token';
  static const String validateTokenEndpoint = '/jwt-auth/v1/token/validate';

  // ── Register (Hany App API — app/v1) ──────────────────────────────────────
  // يُرسَل إلى الـ endpoint المخصص الذي يعمل بنفس آلية Tutor LMS
  // ولا يحتاج صلاحيات (permission_callback = __return_true)
  static const String registerEndpoint = '/app/v1/register';

  // ── Hany App API Plugin (app/v1) ──────────────────────────────────────────
  // هذه الـ endpoints من الإضافة المخصصة — تعمل بـ JWT فقط بدون Nonce

  // Nonce
  static const String nonceEndpoint = '/app/v1/nonce';

  // Courses
  static const String coursesEndpoint             = '/app/v1/courses';
  static String       courseDetailEndpoint(int id) => '/app/v1/courses/$id';

  // Dashboard
  static const String dashboardEndpoint = '/app/v1/dashboard';

  // My Courses
  static const String myCoursesEndpoint = '/app/v1/my-courses';

  // Profile
  static const String profileMeEndpoint    = '/app/v1/profile/me';
  static const String updateProfileEndpoint = '/app/v1/profile/update';
  static const String uploadAvatarEndpoint  = '/app/v1/profile/avatar';

  // Instructor (public)
  static String instructorEndpoint(int id) => '/app/v1/instructor/$id';

  // Enrollment
  static const String enrollmentEndpoint       = '/app/v1/enroll';
  static String enrollmentStatusEndpoint(int courseId) =>
      '/app/v1/enrollment-status/$courseId';

  // Bundle Code Redemption — wc-teacher-code-generator integration
  static const String redeemBundleCodeEndpoint = '/app/v1/redeem-code';
  static const String bundlesEndpoint             = '/app/v1/bundles';
  static String        bundleEndpoint(int id)     => '/app/v1/bundles/$id';

  // Progress
  static const String markLessonCompleteEndpoint = '/app/v1/lesson/complete';
  static const String markCourseCompleteEndpoint = '/app/v1/course/complete';

  // Lesson View HTML Player
  static String lessonViewUrl(int lessonId) =>
      '$baseUrl/app/v1/lesson-view/$lessonId';

  // TVVL
  static String lessonViewsStatusUrl(int lessonId) =>
      '$baseUrl/app/v1/lesson-views/$lessonId';
  static String lessonViewIncrementUrl(int lessonId) =>
      '/app/v1/lesson-views/$lessonId/increment';

  // ── Topics & Lessons ──────────────────────────────────────────────────────
  static const String topicsEndpoint   = '/app/v1/topics';
  static const String lessonsEndpoint  = '/app/v1/lessons';
  static String lessonDetailEndpoint(int id) => '/app/v1/lesson/$id';

  // Course Content
  static String courseContentEndpoint(int courseId) =>
      '/tutor/v1/course-contents/$courseId';

  // Ratings & Reviews
  static String courseRatingEndpoint(int courseId) =>
      '/tutor/v1/course-rating/$courseId';
  // ✅ إصلاح: تم تغيير /tutor/v1/reviews (يشترط صلاحية admin) إلى /app/v1/reviews (عام)
  static const String reviewsEndpoint      = '/app/v1/reviews';
  static const String submitReviewEndpoint = '/app/v1/reviews/submit';
  // إزالة الجلسات النشطة عند تجاوز حد Tutor LMS
  static const String clearSessionsEndpoint = '/app/v1/clear-sessions';

  // Quiz
  static String quizEndpoint(int quizId)    => '/tutor/v1/quiz/$quizId';
  static const String quizAttemptsEndpoint  = '/app/v1/quiz-attempts';
  static String quizAttemptEndpoint(int id) => '/tutor/v1/quiz-attempts/$id';

  // Q&A
  // ✅ تغيير إلى /app/v1/qna (منفذ الإضافة الخاص — لا يشترط صلاحية admin)
  static const String qnaEndpoint = '/app/v1/qna';

  // Assignments (الواجبات — منفذ الإضافة الخاص)
  static const String assignmentsEndpoint = '/app/v1/assignments';
  static String assignmentDetailEndpoint(int id) => '/app/v1/assignment/$id';
  static String assignmentSubmitEndpoint(int id) =>
      '/app/v1/assignment/$id/submit';

  // Notifications (الإشعارات — منفذ الإضافة الخاص)
  static const String notificationsEndpoint = '/app/v1/notifications';
  static const String markNotificationsReadEndpoint =
      '/app/v1/notifications/read';

  // ── App Mode Player ───────────────────────────────────────────────────────
  static String appModeUrl(String lessonUrl, String token) {
    final separator = lessonUrl.contains('?') ? '&' : '?';
    return '$lessonUrl${separator}app=1&token=${Uri.encodeComponent(token)}';
  }

  static String appPlayerUrl(int lessonId, String token) =>
      '$siteUrl/app-player/$lessonId/?token=${Uri.encodeComponent(token)}';

  // ── Pagination ────────────────────────────────────────────────────────────
  static const int defaultPerPage = 20;
}
