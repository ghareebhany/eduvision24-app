import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/widgets/error_widget.dart';
import '../../domain/entities/assignment.dart';
import '../providers/assignment_provider.dart';

class AssignmentDetailScreen extends ConsumerWidget {
  final int assignmentId;
  final int courseId;
  const AssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(assignmentDetailProvider(assignmentId));
    return Scaffold(
      appBar: AppBar(title: const Text('الواجب')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString().replaceAll('Exception: ', ''),
          onRetry: () => ref.invalidate(assignmentDetailProvider(assignmentId)),
        ),
        data: (a) => _AssignmentBody(assignment: a, courseId: courseId),
      ),
    );
  }
}

class _AssignmentBody extends ConsumerStatefulWidget {
  final Assignment assignment;
  final int courseId;
  const _AssignmentBody({required this.assignment, required this.courseId});

  @override
  ConsumerState<_AssignmentBody> createState() => _AssignmentBodyState();
}

class _AssignmentBodyState extends ConsumerState<_AssignmentBody> {
  late final TextEditingController _answerCtrl;
  final List<File> _picked = [];

  @override
  void initState() {
    super.initState();
    _answerCtrl = TextEditingController(
      text: widget.assignment.submission?.answer ?? '',
    );
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final limit = widget.assignment.filesLimit;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: limit != 1,
    );
    if (result == null) return;
    final files = result.paths
        .where((p) => p != null)
        .map((p) => File(p!))
        .toList();
    setState(() {
      _picked
        ..clear()
        ..addAll(limit > 0 ? files.take(limit) : files);
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submit() async {
    final answer = _answerCtrl.text.trim();
    if (answer.isEmpty && _picked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أدخل إجابة أو أرفق ملفاً')));
      return;
    }
    final ok = await ref.read(submitAssignmentProvider.notifier).submit(
          assignmentId: widget.assignment.id,
          courseId: widget.courseId,
          answer: answer,
          files: _picked,
        );
    if (!mounted) return;
    if (ok) {
      setState(() => _picked.clear());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال تسليمك')));
    } else {
      final err = ref.read(submitAssignmentProvider).error ??
          'تعذّر الإرسال، حاول مرة أخرى';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = widget.assignment;
    final sub = a.submission;
    final submitting = ref.watch(submitAssignmentProvider).loading;
    final isEvaluated = sub?.isEvaluated ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(a.title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip(theme, Icons.grade_rounded,
                'الدرجة الكلية: ${a.totalMark}'),
            _chip(theme, Icons.check_circle_outline_rounded,
                'درجة النجاح: ${a.passMark}'),
          ],
        ),
        const SizedBox(height: 16),
        if (a.content.trim().isNotEmpty) ...[
          Html(data: a.content),
          const Divider(height: 32),
        ],

        // حالة التقييم
        if (isEvaluated) ...[
          _resultCard(theme, a, sub!),
          const SizedBox(height: 16),
        ] else if (sub?.submitted == true) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded,
                    color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                    child: Text('تم استلام تسليمك — بانتظار تقييم المدرّس')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // مرفقات التسليم السابق
        if (sub != null && sub.attachments.isNotEmpty) ...[
          Text('ملفاتك المرفوعة:',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          for (final att in sub.attachments)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.attach_file_rounded),
              title: Text(att.name, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => _openUrl(att.url),
            ),
          const SizedBox(height: 16),
        ],

        // نموذج التسليم (متاح ما لم يُقيّم)
        if (!isEvaluated) ...[
          Text(sub?.submitted == true ? 'تعديل تسليمك:' : 'إجابتك:',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _answerCtrl,
            enabled: !submitting,
            maxLines: 6,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب إجابتك هنا...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: submitting ? null : _pickFiles,
            icon: const Icon(Icons.upload_file_rounded, size: 18),
            label: Text(a.filesLimit == 1
                ? 'إرفاق ملف (حتى ${a.sizeLimitMb} ميجا)'
                : 'إرفاق ملفات (حتى ${a.filesLimit}، ${a.sizeLimitMb} ميجا للملف)'),
          ),
          if (_picked.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final f in _picked)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(f.path.split('/').last,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: submitting ? null : _submit,
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(sub?.submitted == true ? 'تحديث التسليم' : 'إرسال التسليم'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _chip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _resultCard(ThemeData theme, Assignment a, AssignmentSubmission sub) {
    final mark = sub.mark ?? 0;
    final passed = mark >= a.passMark;
    final color = passed ? const Color(0xFFE26D5C) : const Color(0xFFB83232);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(passed ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                  color: color),
              const SizedBox(width: 8),
              Text(passed ? 'ناجح' : 'لم تجتز الحد الأدنى',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color)),
              const Spacer(),
              Text('${sub.mark ?? 0} / ${a.totalMark}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          if (sub.instructorNote.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('ملاحظة المدرّس:',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub.instructorNote),
          ],
        ],
      ),
    );
  }
}
