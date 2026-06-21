import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../domain/entities/user.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // حالة التهيئة أو التحميل
    if (authState is AuthInitial || authState is AuthLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // غير مسجّل
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول أولاً')),
      );
    }

    final userId = authState.user.id;

    // ✅ إصلاح جوهري (بناءً على تقرير الخبير):
    //
    // ❌ كان:
    //   final user = ref.watch(profileProvider(userId)).valueOrNull ?? cachedUser;
    //
    //   المشكلة: ?? cachedUser = fallback لبيانات قديمة (hany2) عند أي تأخير
    //   يُظهر بيانات مستخدم سابق ريثما يكتمل تحميل المستخدم الجديد
    //
    // ✅ الآن: AsyncValue كامل — loading/error/data بشكل صريح
    //   لا يوجد أي fallback لبيانات قديمة بأي حال

    final profileAsync = ref.watch(profileProvider(userId));

    return profileAsync.when(
      // ── تحميل ────────────────────────────────────────────────────────────
      loading: () => Scaffold(
        appBar: _buildAppBar(context, ref),
        body: const Center(child: CircularProgressIndicator()),
      ),

      // ── خطأ ──────────────────────────────────────────────────────────────
      error: (e, _) => Scaffold(
        appBar: _buildAppBar(context, ref),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'تعذّر تحميل الملف الشخصي',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ref.invalidate(profileProvider(userId)),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),

      // ── بيانات ───────────────────────────────────────────────────────────
      data: (user) => Scaffold(
        appBar: _buildAppBar(context, ref),
        body: _buildBody(context, ref, userId, user),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('ملفي الشخصي',
          style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'تسجيل الخروج',
          onPressed: () => _confirmLogout(context, ref),
        ),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, int userId, User user) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Avatar ────────────────────────────────────────────────────
          Consumer(builder: (_, r, __) {
            final uploading = r.watch(avatarUploadProvider).isLoading;
            return Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? Icon(Icons.person,
                          size: 56, color: theme.colorScheme.primary)
                      : null,
                ),
                if (uploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: uploading
                        ? null
                        : () => _pickAndUploadAvatar(context, ref, userId),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.coral500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Text(
            user.displayName.isNotEmpty ? user.displayName : 'المستخدم',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
                color:
                    theme.colorScheme.onSurface.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 32),
          _InfoTile(
            icon: Icons.info_outline,
            label: 'نبذة عني',
            value: user.bio.isNotEmpty ? user.bio : 'لم تتم الإضافة بعد',
          ),
          if (user.website.isNotEmpty)
            _InfoTile(
                icon: Icons.link, label: 'الموقع', value: user.website),
          if (user.phone.isNotEmpty)
            _InfoTile(
                icon: Icons.phone_outlined,
                label: 'الهاتف',
                value: user.phone),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _showEditSheet(
                context, ref, userId, user.displayName, user.bio, user.phone),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('تعديل الملف الشخصي'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.coral500,
              side: const BorderSide(color: AppTheme.coral500),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          // ── Redeem Bundle Code ───────────────────────────────────────
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [AppTheme.coral400, AppTheme.mocha500],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.coral500.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push('/redeem-code'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'استرداد كود الالتحاق',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── تأكيد تسجيل الخروج ────────────────────────────────────────────────────
  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('تسجيل الخروج'),
          ],
        ),
        content: const Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  // ── تعديل الملف الشخصي ────────────────────────────────────────────────────
  Future<void> _pickAndUploadAvatar(
      BuildContext context, WidgetRef ref, int userId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final ok = await ref.read(avatarUploadProvider.notifier).upload(path);
    if (!context.mounted) return;
    if (ok) {
      ref.invalidate(profileProvider(userId));
      try {
        final updated = await ref.read(profileProvider(userId).future);
        ref.read(authProvider.notifier).updateCurrentUser(updated);
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث الصورة بنجاح'),
          backgroundColor: Color(0xFFE26D5C),
        ),
      );
    } else {
      final err = ref.read(avatarUploadProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'تعذّر رفع الصورة')),
      );
    }
    ref.read(avatarUploadProvider.notifier).reset();
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, int userId,
      String name, String bio, String phone) {
    final nameCtrl  = TextEditingController(text: name);
    final bioCtrl   = TextEditingController(text: bio);
    final phoneCtrl = TextEditingController(text: phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('تعديل الملف الشخصي',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(nameCtrl, 'الاسم', Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField(bioCtrl, 'نبذة عني', Icons.info_outline,
                maxLines: 3),
            const SizedBox(height: 12),
            _buildTextField(phoneCtrl, 'الهاتف', Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            Consumer(builder: (_, r, __) {
              final state = r.watch(updateProfileProvider);
              return FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await r.read(updateProfileProvider.notifier).update({
                          'display_name': nameCtrl.text.trim(),
                          'description': bioCtrl.text.trim(),
                          'phone': phoneCtrl.text.trim(),
                        });
                        final updated = r.read(updateProfileProvider);
                        if (updated.success && ctx.mounted) {
                          Navigator.pop(ctx);
                          // ── FIX: امسح cache profileProvider ─────────────
                          r.invalidate(profileProvider(userId));
                          // ── FIX: حدّث authProvider بالبيانات الجديدة ────
                          // بدون هذا، authState.user يبقى قديماً
                          // وشاشات أخرى تعتمد عليه تُظهر بيانات قديمة
                          try {
                            final profileState = await r.read(profileProvider(userId).future);
                            r.read(authProvider.notifier).updateCurrentUser(profileState);
                          } catch (_) {}
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تحديث الملف بنجاح'),
                              backgroundColor: Color(0xFFE26D5C),
                            ),
                          );
                        } else if (updated.error != null && ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(updated.error!)),
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('حفظ التغييرات'),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
}

// ── InfoTile ───────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15)),
                ]),
          ),
        ],
      ),
    );
  }
}
