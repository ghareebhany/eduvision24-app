import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/widgets/error_widget.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/qna.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/review.dart';
import '../providers/hub_provider.dart';

// ── عناصر مشتركة ─────────────────────────────────
BoxShadow _shadow(double blur) => BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: blur,
      offset: Offset(0, blur * 0.4),
    );

class _HubEmpty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HubEmpty({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.coral.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 40, color: AppPalette.coral),
            ),
            const SizedBox(height: 16),
            Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textPrimary(context))),
          ]),
        ),
      );
}

class _CourseTag extends StatelessWidget {
  final String title;
  const _CourseTag({required this.title});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(Icons.menu_book_rounded,
            size: 13, color: AppPalette.textSecondary(context)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11.5, color: AppPalette.textSecondary(context))),
        ),
      ]);
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.40)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}

class _HubCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _HubCard({required this.onTap, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppPalette.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.border(context)),
          boxShadow: [_shadow(10)],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(padding: const EdgeInsets.all(14), child: child),
          ),
        ),
      );
}

Widget _hubList<T>({
  required AsyncValue<List<HubEntry<T>>> async,
  required VoidCallback onRetry,
  required Future<void> Function() onRefresh,
  required IconData emptyIcon,
  required String emptyText,
  required Widget Function(BuildContext, HubEntry<T>) card,
}) {
  return async.when(
    loading: () => const Center(
        child: CircularProgressIndicator(color: AppPalette.coral)),
    error: (e, _) => AppErrorWidget(
        message: e.toString().replaceAll('Exception: ', ''),
        onRetry: onRetry),
    data: (items) {
      if (items.isEmpty) return _HubEmpty(icon: emptyIcon, text: emptyText);
      return RefreshIndicator(
        color: AppPalette.coral,
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: items.length,
          itemBuilder: (c, i) => card(c, items[i]),
        ),
      );
    },
  );
}

PreferredSizeWidget _hubAppBar(BuildContext context, String title) => AppBar(
      backgroundColor: AppPalette.scaffold(context),
      elevation: 0,
      centerTitle: true,
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppPalette.textPrimary(context))),
      iconTheme: IconThemeData(color: AppPalette.textPrimary(context)),
    );

// ── اختباراتي ───────────────────────────────
class HubQuizzesScreen extends ConsumerWidget {
  const HubQuizzesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppPalette.scaffold(context),
      appBar: _hubAppBar(context, 'اختباراتي'),
      body: _hubList<QuizAttempt>(
        async: ref.watch(myQuizAttemptsProvider),
        onRetry: () => ref.invalidate(myQuizAttemptsProvider),
        onRefresh: () async => ref.invalidate(myQuizAttemptsProvider),
        emptyIcon: Icons.quiz_rounded,
        emptyText: 'لا توجد محاولات اختبارات بعد',
        card: (context, entry) {
          final a = entry.item;
          final passed = a.isPassed;
          final color = passed == null
              ? AppPalette.textSecondary(context)
              : (passed ? const Color(0xFF0F9D8C) : AppPalette.coral);
          final label =
              passed == null ? 'مكتمل' : (passed ? 'ناجح' : 'راسب');
          return _HubCard(
            onTap: () => context.push('/course/${entry.course.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(a.quizTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.textPrimary(context))),
                  ),
                  const SizedBox(width: 8),
                  _Chip(text: label, color: color),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.grade_rounded,
                      size: 15, color: AppPalette.coral),
                  const SizedBox(width: 4),
                  Text(
                      '${a.earnedMarks.toStringAsFixed(0)}/${a.totalMarks.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.coral)),
                  const SizedBox(width: 12),
                  Text('${a.percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.textSecondary(context))),
                ]),
                const SizedBox(height: 10),
                _CourseTag(title: entry.course.title),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── أسئلتي ──────────────────────────────────
class HubQnaScreen extends ConsumerWidget {
  const HubQnaScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppPalette.scaffold(context),
      appBar: _hubAppBar(context, 'أسئلتي'),
      body: _hubList<QnaItem>(
        async: ref.watch(myQuestionsProvider),
        onRetry: () => ref.invalidate(myQuestionsProvider),
        onRefresh: () async => ref.invalidate(myQuestionsProvider),
        emptyIcon: Icons.forum_rounded,
        emptyText: 'لم تطرح أي أسئلة بعد',
        card: (context, entry) {
          final q = entry.item;
          final answers = q.answers.length;
          return _HubCard(
            onTap: () => context.push('/course/${entry.course.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.help_outline_rounded,
                      size: 16, color: AppPalette.coral),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(q.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                            color: AppPalette.textPrimary(context))),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _Chip(
                      text: answers > 0 ? '$answers رد' : 'بانتظار رد',
                      color: answers > 0
                          ? const Color(0xFF0F9D8C)
                          : AppPalette.textSecondary(context)),
                  const Spacer(),
                  Flexible(child: _CourseTag(title: entry.course.title)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── واجباتي ─────────────────────────────────
class HubAssignmentsScreen extends ConsumerWidget {
  const HubAssignmentsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppPalette.scaffold(context),
      appBar: _hubAppBar(context, 'واجباتي'),
      body: _hubList<Assignment>(
        async: ref.watch(myAssignmentsProvider),
        onRetry: () => ref.invalidate(myAssignmentsProvider),
        onRefresh: () async => ref.invalidate(myAssignmentsProvider),
        emptyIcon: Icons.assignment_turned_in_rounded,
        emptyText: 'لا توجد واجبات بعد',
        card: (context, entry) {
          final a = entry.item;
          final Color color;
          final String label;
          if (!a.isSubmitted) {
            color = AppPalette.textSecondary(context);
            label = 'لم يُسلّم';
          } else if (a.isEvaluated) {
            color = const Color(0xFF0F9D8C);
            label = a.mark != null
                ? 'تم التقييم · ${a.mark!.toStringAsFixed(0)}/${a.totalMark}'
                : 'تم التقييم';
          } else {
            color = AppPalette.coral;
            label = 'بانتظار التقييم';
          }
          return _HubCard(
            onTap: () => context.push('/course/${entry.course.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(a.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.textPrimary(context))),
                  ),
                  const SizedBox(width: 8),
                  _Chip(text: label, color: color),
                ]),
                const SizedBox(height: 10),
                _CourseTag(title: entry.course.title),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── تقييماتي ─────────────────────────────────
class HubReviewsScreen extends ConsumerWidget {
  const HubReviewsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppPalette.scaffold(context),
      appBar: _hubAppBar(context, 'تقييماتي'),
      body: _hubList<Review>(
        async: ref.watch(myReviewsProvider),
        onRetry: () => ref.invalidate(myReviewsProvider),
        onRefresh: () async => ref.invalidate(myReviewsProvider),
        emptyIcon: Icons.star_rounded,
        emptyText: 'لم تضف أي تقييمات بعد',
        card: (context, entry) {
          final r = entry.item;
          final full = r.rating.round();
          return _HubCard(
            onTap: () => context.push('/course/${entry.course.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    children: List.generate(
                        5,
                        (i) => Icon(
                            i < full
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 18,
                            color: const Color(0xFFE8A23D)))),
                if (r.content.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(r.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: AppPalette.textPrimary(context))),
                ],
                const SizedBox(height: 10),
                _CourseTag(title: entry.course.title),
              ],
            ),
          );
        },
      ),
    );
  }
}
