import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../core/widgets/error_widget.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/notifications_provider.dart';

// ── Shadow helper ─────────────────────────────────────────────────────────────
BoxShadow _shadow(double blur,
        {Color base = Colors.black, double opacity = 0.08}) =>
    BoxShadow(
        color: base.withValues(alpha: opacity),
        blurRadius: blur,
        offset: Offset(0, blur * 0.4));

// ── Scale-tap wrapper ─────────────────────────────────────────────────────────
class _Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Tap({required this.child, required this.onTap});
  @override
  State<_Tap> createState() => _TapState();
}

class _TapState extends State<_Tap> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 110));
  late final Animation<double> _s = Tween(begin: 1.0, end: 0.97)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) => GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) {
          _c.reverse();
          widget.onTap();
        },
        onTapCancel: () => _c.reverse(),
        child: AnimatedBuilder(
            animation: _s,
            builder: (_, ch) => Transform.scale(scale: _s.value, child: ch),
            child: widget.child),
      );
}

// ── User avatar ───────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final User? user;
  final bool isLoading;
  const _Avatar({required this.user, required this.isLoading});

  String _getInitials() {
    final name = user?.displayName ?? '';
    return name.isNotEmpty ? name[0].toUpperCase() : 'م';
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
          border: Border.all(
              color: AppPalette.sage.withValues(alpha: 0.5), width: 2),
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)))
            : (user?.avatarUrl.isNotEmpty == true)
                ? ClipOval(
                    child: CachedNetworkImage(
                        imageUrl: user!.avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _initials()))
                : _initials(),
      );

  Widget _initials() => Center(
          child: Text(
        _getInitials(),
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ));
}

// ══════════════════════════════════════════════════════════════════════════════
//  Dashboard Screen
// ══════════════════════════════════════════════════════════════════════════════
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashAsync = ref.watch(dashboardProvider);

    final User? user = switch (authState) {
      AuthAuthenticated(:final user) => user,
      _ => null,
    };

    final isAuthLoading =
        user == null && (authState is AuthInitial || authState is AuthLoading);

    return Scaffold(
      backgroundColor: AppPalette.scaffold(context),
      body: RefreshIndicator(
        color: AppPalette.coral,
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
        },
        child: CustomScrollView(slivers: [
          // ── Sticky header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 136,
            pinned: true,
            elevation: 0,
            backgroundColor: AppPalette.mocha,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28))),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _DashHeader(
                user: user,
                isLoading: isAuthLoading,
                ref: ref,
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          dashAsync.when(
            loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppPalette.coral))),
            error: (e, _) => SliverToBoxAdapter(
                child: AppErrorWidget(
                    message: e.toString().replaceAll('Exception: ', ''),
                    onRetry: () => ref.invalidate(dashboardProvider))),
            data: (stats) =>
                SliverList(delegate: SliverChildListDelegate([
              const SizedBox(height: 22),
              _SectionLabel(title: 'إحصائياتك'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(
                      child: _StatCard(
                          icon: Icons.library_books_rounded,
                          label: 'مسجّل فيها',
                          value: '${stats.enrolledCount}',
                          colors: const [AppPalette.mocha, AppPalette.plum])),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard(
                          icon: Icons.play_circle_filled_rounded,
                          label: 'قيد التعلم',
                          value: '${stats.activeCount}',
                          colors: const [AppPalette.coral, AppPalette.plum])),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _StatCard(
                          icon: Icons.verified_rounded,
                          label: 'مكتملة',
                          value: '${stats.completedCount}',
                          colors: const [
                            Color(0xFF723D46),
                            Color(0xFF472D30)
                          ])),
                ]),
              ),

              // ── قسم "كل ما يخصّك" ─────────────────────────────────
              const SizedBox(height: 26),
              _SectionLabel(title: 'كل ما يخصّك'),
              const SizedBox(height: 10),
              _FeatureGrid(stats: stats),

              if (stats.inProgress.isNotEmpty) ...[
                const SizedBox(height: 26),
                _SectionLabel(
                  title: 'استكمل تعلمك',
                  trailing: TextButton(
                    onPressed: () => context.push('/my-courses'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('عرض الكل',
                        style:
                            TextStyle(color: AppPalette.coral, fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 10),
                ...stats.inProgress.map((c) => _Tap(
                    onTap: () => context.push('/course/${c.id}'),
                    child: _ProgressCard(item: c))),
              ],
              if (stats.enrolledCount == 0)
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child:
                        _EmptyState(onBrowse: () => context.go('/courses'))),
              const SizedBox(height: 40),
            ])),
          ),
        ]),
      ),
    );
  }
}

// ── Header widget ─────────────────────────────────────────────────────────────
class _DashHeader extends StatelessWidget {
  final User? user;
  final bool isLoading;
  final WidgetRef ref;
  const _DashHeader(
      {required this.user, required this.isLoading, required this.ref});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء النور';
  }

  Future<bool?> _confirmLogout(BuildContext ctx) => showDialog<bool>(
        context: ctx,
        builder: (c) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تسجيل الخروج'),
          content: const Text('هل تريد تسجيل الخروج؟'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('إلغاء')),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: AppPalette.plum),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('خروج'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: AppPalette.headerGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Stack(children: [
          // Decorative circles
          Positioned(
              top: -24,
              right: -18,
              child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppPalette.sage.withValues(alpha: 0.10)))),
          Positioned(
              bottom: -14,
              left: 10,
              child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppPalette.coral.withValues(alpha: 0.12)))),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Row: avatar + name + icons
                  Row(children: [
                    _Avatar(user: user, isLoading: isLoading),
                    const SizedBox(width: 12),
                    Expanded(
                      child: isLoading
                          ? const SizedBox(
                              height: 14,
                              child: Center(
                                child: SizedBox(
                                  width: 80,
                                  height: 8,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.white54),
                                  ),
                                ),
                              ),
                            )
                          : (user != null)
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                      Text('${_greeting()} 👋',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.6),
                                              fontSize: 11)),
                                      Text(user!.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w800)),
                                    ])
                              : const SizedBox.shrink(),
                    ),
                    const _ThemeToggleBtn(),
                    const SizedBox(width: 6),
                    const _NotificationBell(),
                    const SizedBox(width: 6),
                    _HdrBtn(
                      icon: Icons.logout_rounded,
                      onTap: () async {
                        final ok = await _confirmLogout(context);
                        if (ok == true)
                          ref.read(authProvider.notifier).logout();
                      },
                    ),
                  ]),

                  // Tag pill
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppPalette.coral.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppPalette.coral.withValues(alpha: 0.4)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppPalette.coral)),
                        const SizedBox(width: 6),
                        const Text('#اتعلم_ازاي_تتعلم',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
}

class _NotificationBell extends ConsumerStatefulWidget {
  const _NotificationBell();

  @override
  ConsumerState<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<_NotificationBell>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _lastRefresh = DateTime.now();

  // فترة التحديث الدوري + الحد الأدنى بين أي تحديثين لتفادي الطلبات المتكررة
  static const Duration _pollInterval = Duration(minutes: 3);
  static const Duration _minRefreshGap = Duration(minutes: 2);

  void _refreshNotifications() {
    if (!mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastRefresh) < _minRefreshGap) return;
    _lastRefresh = now;
    ref.invalidate(notificationsProvider);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // تحديث دوري كل 3 دقائق لجلب أحدث الإشعارات دون إعادة فتح التطبيق
    _timer = Timer.periodic(_pollInterval, (_) => _refreshNotifications());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // أعد الجلب عند عودة المستخدم للتطبيق (مع احترام الحد الأدنى بين التحديثات)
    if (state == AppLifecycleState.resumed) {
      _refreshNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = ref.watch(notificationsProvider).maybeWhen(
          data: (b) => b.unreadCount,
          orElse: () => 0,
        );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _HdrBtn(
          icon: unread > 0
              ? Icons.notifications_active_rounded
              : Icons.notifications_none_rounded,
          onTap: () => context.push('/notifications'),
        ),
        if (unread > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE26D5C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HdrBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HdrBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: Colors.white.withValues(alpha: 0.13),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );
}

// ── Theme toggle button (light / dark) ────────────────────────────────────────
class _ThemeToggleBtn extends ConsumerWidget {
  const _ThemeToggleBtn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider); // إعادة البناء عند تغيّر الوضع
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(themeModeProvider.notifier).toggle(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppPalette.peach.withValues(alpha: 0.30),
                    AppPalette.coral.withValues(alpha: 0.18),
                  ],
                )
              : null,
          color: isDark ? null : Colors.white.withValues(alpha: 0.13),
          border: Border.all(
              color: isDark
                  ? AppPalette.peach.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.18)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween<double>(begin: 0.55, end: 1.0).animate(anim),
            child: ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            key: ValueKey<bool>(isDark),
            color: isDark ? AppPalette.peach : Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionLabel({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppPalette.coral, AppPalette.plum]),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.textPrimary(context))),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
      );
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final List<Color> colors;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.colors});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [_shadow(12, base: colors[0], opacity: 0.30)],
        ),
        child: Column(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

// ── Progress Card ─────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final InProgressCourse item;
  const _ProgressCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final pct = item.completedPercent / 100;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppPalette.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border(context)),
        boxShadow: [_shadow(10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(17)),
            child: item.thumbnail.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.thumbnail,
                    width: 140,
                    height: 110,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _thumbFallback())
                : _thumbFallback(),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.textPrimary(context),
                            height: 1.3)),
                    const SizedBox(height: 8),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 5,
                          backgroundColor:
                              AppPalette.sage.withValues(alpha: 0.35),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppPalette.coral)),
                    ),
                    const SizedBox(height: 7),

                    Row(children: [
                      Text(
                          '${item.completedLessons}/${item.totalLessons} درس',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppPalette.textSecondary(context),
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppPalette.coral.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  AppPalette.coral.withValues(alpha: 0.35)),
                        ),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('متابعة',
                                  style: TextStyle(
                                      color: AppPalette.coral,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(width: 3),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  color: AppPalette.coral, size: 9),
                            ]),
                      ),
                    ]),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumbFallback() => Container(
        width: 110,
        height: 110,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppPalette.plum, AppPalette.mocha]),
        ),
        child: const Icon(Icons.play_circle_fill_rounded,
            color: Colors.white38, size: 40),
      );
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyState({required this.onBrowse});

  @override
  Widget build(BuildContext context) => Column(children: [
        Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [AppPalette.sageLight, Color(0xFFE8EACE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                border: Border.all(color: AppPalette.sage, width: 1.5)),
            child: const Icon(Icons.school_rounded,
                size: 40, color: AppPalette.plum)),
        const SizedBox(height: 16),
        Text('لم تسجّل في أي دورة بعد',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppPalette.textPrimary(context))),
        const SizedBox(height: 6),
        Text('ابدأ رحلة تعلمك واختر حزمتك المناسبة',
            style: TextStyle(
                fontSize: 13,
                color: AppPalette.textSecondary(context))),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: onBrowse,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
                gradient: AppPalette.btnGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  _shadow(12, base: AppPalette.coral, opacity: 0.3)
                ]),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.explore_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('تصفح الحزم',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ]),
          ),
        ),
      ]);
}

// ── قسم "كل ما يخصّك": شبكة بطاقات ميزات الطالب ────────────────
class _FeatureCardData {
  final IconData icon;
  final String title;
  final int count;
  final String route;
  final List<Color> colors;
  const _FeatureCardData({
    required this.icon,
    required this.title,
    required this.count,
    required this.route,
    required this.colors,
  });
}

class _FeatureGrid extends StatelessWidget {
  final DashboardStats stats;
  const _FeatureGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = <_FeatureCardData>[
      _FeatureCardData(
        icon: Icons.quiz_rounded,
        title: 'اختباراتي',
        count: stats.quizCount,
        route: '/hub/quizzes',
        colors: const [Color(0xFFE26D5C), Color(0xFF723D46)],
      ),
      _FeatureCardData(
        icon: Icons.forum_rounded,
        title: 'أسئلتي',
        count: stats.questionCount,
        route: '/hub/qna',
        colors: const [Color(0xFF0F9D8C), Color(0xFF0B6F63)],
      ),
      _FeatureCardData(
        icon: Icons.assignment_turned_in_rounded,
        title: 'واجباتي',
        count: stats.assignmentCount,
        route: '/hub/assignments',
        colors: const [Color(0xFF723D46), Color(0xFF472D30)],
      ),
      _FeatureCardData(
        icon: Icons.star_rounded,
        title: 'تقييماتي',
        count: stats.reviewCount,
        route: '/hub/reviews',
        colors: const [Color(0xFFE8A23D), Color(0xFFC9772A)],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Row(children: [
          Expanded(child: _FeatureCard(data: cards[0])),
          const SizedBox(width: 12),
          Expanded(child: _FeatureCard(data: cards[1])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _FeatureCard(data: cards[2])),
          const SizedBox(width: 12),
          Expanded(child: _FeatureCard(data: cards[3])),
        ]),
      ]),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureCardData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push(data.route),
        child: Container(
          height: 106,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data.colors,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: data.colors.first.withValues(alpha: 0.30),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                if (data.count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${data.count}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900)),
                  ),
              ]),
              const Spacer(),
              Text(data.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Row(children: [
                Text('عرض الكل',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 3),
                Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.85), size: 9),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
