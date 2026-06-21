import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/entities/bundle.dart';
import '../providers/auth_provider.dart';
import '../providers/bundles_provider.dart';

// ── Palette shortcuts ─────────────────────────────────────────────────────────
const _bg     = AppTheme.sage100;   // ✅ خلفية فاتحة
const _plum   = AppTheme.mocha500;   // 723D46
const _mocha  = AppTheme.mocha700;   // 472D30
const _coral  = AppTheme.coral500;   // E26D5C
const _sage   = AppTheme.sage500;    // C9CBA3
const _white  = Colors.white;
const _enrolledGreen = Color(0xFF0F9D8C); // أخضر مزرقّ لبادج «مسجّل»

BoxShadow _sh(double b, {Color c = Colors.black, double o = 0.12}) =>
    BoxShadow(color: c.withValues(alpha: o), blurRadius: b, offset: Offset(0, b * 0.4));

// ── Sort state ────────────────────────────────────────────────────────────────
class _Sort {
  static const newest   = 'newest';
  static const enrolled = 'enrolled';
  static String label(String s) => switch (s) {
    enrolled => 'المسجّل أولاً',
    _        => 'الافتراضي',
  };
}

// ══════════════════════════════════════════════════════════════════════════════
//  Courses Screen
// ══════════════════════════════════════════════════════════════════════════════
class CoursesScreen extends ConsumerStatefulWidget {
  const CoursesScreen({super.key});
  @override
  ConsumerState<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends ConsumerState<CoursesScreen> {
  final _searchCtrl = TextEditingController();
  String _q      = '';
  String _sort   = _Sort.newest;
  bool   _onlyEnrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchWhenReady());
  }

  Future<void> _fetchWhenReady() async {
    for (var i = 0; i < 50; i++) {
      if (ref.read(authProvider) is! AuthInitial) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    ref.read(bundlesProvider.notifier).fetch();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<Bundle> _apply(List<Bundle> all) {
    var r = all;
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      r = r.where((b) => b.title.toLowerCase().contains(q)).toList();
    }
    if (_onlyEnrolled) r = r.where((b) => b.isEnrolled).toList();
    if (_sort == _Sort.enrolled) {
      r = [...r]..sort((a, b) => (b.isEnrolled ? 1 : 0) - (a.isEnrolled ? 1 : 0));
    }
    return r;
  }

  bool get _hasFilter => _q.isNotEmpty || _onlyEnrolled || _sort != _Sort.newest;

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(bundlesProvider);
    final all      = state.bundles;
    final filtered = _apply(all);
    final enrolledCount = all.where((b) => b.isEnrolled).length;

    final isDark = AppPalette.isDark(context);
    final bg     = AppPalette.scaffold(context);
    final surf   = AppPalette.surface(context);
    final ink    = AppPalette.textPrimary(context);
    final mut    = AppPalette.textSecondary(context);
    final line   = AppPalette.border(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        body: RefreshIndicator(
          color: _coral,
          backgroundColor: surf,
          onRefresh: () => ref.read(bundlesProvider.notifier).fetch(refresh: true),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [

              // ── Pinned AppBar + search ──────────────────────────────────
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                backgroundColor: bg,
                systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
                expandedHeight: 0,
                title: Row(children: [
                  Text('الحزم التعليمية',
                      style: TextStyle(
                          color: ink, fontWeight: FontWeight.w800, fontSize: 18)),
                  const Spacer(),
                  if (all.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _coral.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _coral.withValues(alpha: 0.30)),
                      ),
                      child: Text('${all.length} حزمة',
                          style: const TextStyle(
                              color: _coral,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                ]),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(58),
                  child: Container(
                    color: bg,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(children: [
                      // ✅ Search field - متوافق مع الوضعين
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: surf,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: line),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: TextStyle(color: ink, fontSize: 13),
                            onChanged: (v) => setState(() => _q = v),
                            decoration: InputDecoration(
                              hintText: 'ابحث عن حزمة...',
                              hintStyle: TextStyle(
                                  color: mut, fontSize: 13),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: mut, size: 20),
                              suffixIcon: _q.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.close_rounded,
                                          color: mut, size: 18),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() => _q = '');
                                      })
                                  : null,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter button
                      Stack(children: [
                        GestureDetector(
                          onTap: () => _showFilterSheet(context, all, enrolledCount),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: _hasFilter
                                  ? _coral.withValues(alpha: 0.15)
                                  : surf,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: _hasFilter
                                    ? _coral.withValues(alpha: 0.5)
                                    : line,
                              ),
                            ),
                            child: Icon(Icons.tune_rounded,
                                color: _hasFilter ? _coral : mut, size: 20),
                          ),
                        ),
                        if (_hasFilter)
                          Positioned(
                            top: 6, right: 6,
                            child: Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                  color: _coral, shape: BoxShape.circle),
                            ),
                          ),
                      ]),
                    ]),
                  ),
                ),
              ),

              // ── Sort bar ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: bg,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Row(children: [
                    for (final s in [
                      (_Sort.newest,   'الافتراضي',     Icons.grid_view_rounded),
                      (_Sort.enrolled, 'المسجّل أولاً', Icons.check_circle_outline_rounded),
                    ]) ...[
                      GestureDetector(
                        onTap: () => setState(() => _sort = s.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _sort == s.$1
                                ? _coral
                                : surf,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _sort == s.$1
                                  ? _coral
                                  : line,
                            ),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(s.$3,
                                size: 13,
                                color: _sort == s.$1
                                    ? _white
                                    : mut),
                            const SizedBox(width: 5),
                            Text(s.$2,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _sort == s.$1
                                        ? _white
                                        : mut)),
                          ]),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (filtered.isNotEmpty)
                      Text('${filtered.length} حزمة',
                          style: TextStyle(
                              fontSize: 11,
                              color: mut)),
                  ]),
                ),
              ),

              // ── Active filter chips ─────────────────────────────────────
              if (_hasFilter)
                SliverToBoxAdapter(
                  child: Container(
                    color: bg,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Wrap(spacing: 8, runSpacing: 6, children: [
                      if (_q.isNotEmpty)
                        _FilterPill(
                          label: 'بحث: $_q',
                          onDelete: () {
                            _searchCtrl.clear();
                            setState(() => _q = '');
                          },
                        ),
                      if (_onlyEnrolled)
                        _FilterPill(
                          label: 'المسجّلة فقط',
                          icon: Icons.check_circle_outline_rounded,
                          onDelete: () => setState(() => _onlyEnrolled = false),
                        ),
                      if (_sort != _Sort.newest)
                        _FilterPill(
                          label: _Sort.label(_sort),
                          icon: Icons.sort_rounded,
                          onDelete: () => setState(() => _sort = _Sort.newest),
                        ),
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() {
                            _q = ''; _sort = _Sort.newest; _onlyEnrolled = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: surf,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: line),
                          ),
                          child: Text('مسح الكل',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: mut)),
                        ),
                      ),
                    ]),
                  ),
                ),

              // ── Content area spacer ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: const SizedBox(height: 12),
                ),
              ),

              // ── Loading ─────────────────────────────────────────────────
              if (state.isLoading)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const _CardShimmer(),
                      childCount: 6,
                    ),
                  ),
                )

              // ── Error ────────────────────────────────────────────────────
              else if (state.error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: bg,
                    child: _ErrorView(
                      message: state.error!,
                      onRetry: () => ref.read(bundlesProvider.notifier).fetch(),
                    ),
                  ),
                )

              // ── Empty ────────────────────────────────────────────────────
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: bg,
                    child: _EmptyView(hasQuery: _q.isNotEmpty, query: _q),
                  ),
                )

              // ── Grid ─────────────────────────────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _FadeSlideIn(
                        index: i,
                        child: _BundleCard(bundle: filtered[i]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),

              // ── Footer bg filler ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: ColoredBox(color: bg,
                    child: const SizedBox(height: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _showFilterSheet(
      BuildContext context, List<Bundle> all, int enrolledCount) {
    var tempSort         = _sort;
    var tempOnlyEnrolled = _onlyEnrolled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.75,
          minChildSize: 0.35,
          expand: false,
          builder: (_, ctrl) => Container(
            decoration: BoxDecoration(
              color: AppPalette.scaffold(ctx),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(children: [
              // Handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: AppPalette.border(ctx), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Text('فلترة الحزم',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.textPrimary(ctx))),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setModal(() {
                      tempSort = _Sort.newest;
                      tempOnlyEnrolled = false;
                    }),
                    child: const Text('إعادة ضبط',
                        style: TextStyle(color: _coral)),
                  ),
                ]),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Sort ─────────────────────────────────────────────
                    Text('ترتيب حسب',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textPrimary(ctx))),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final s in [
                        (_Sort.newest,   'الافتراضي',     Icons.grid_view_rounded),
                        (_Sort.enrolled, 'المسجّل أولاً', Icons.check_circle_outline_rounded),
                      ])
                        GestureDetector(
                          onTap: () => setModal(() => tempSort = s.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: tempSort == s.$1
                                  ? _coral
                                  : AppPalette.surfaceAlt(ctx),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(s.$3,
                                  size: 14,
                                  color: tempSort == s.$1
                                      ? _white
                                      : AppPalette.textSecondary(ctx)),
                              const SizedBox(width: 6),
                              Text(s.$2,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: tempSort == s.$1
                                          ? _white
                                          : AppPalette.textSecondary(ctx))),
                            ]),
                          ),
                        ),
                    ]),

                    const SizedBox(height: 22),

                    // ── Toggle enrolled ──────────────────────────────────
                    if (enrolledCount > 0) ...[
                      Text('تصفية',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary(ctx))),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () =>
                            setModal(() => tempOnlyEnrolled = !tempOnlyEnrolled),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: tempOnlyEnrolled
                                ? AppTheme.success.withValues(alpha: 0.1)
                                : AppPalette.surfaceAlt(ctx),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: tempOnlyEnrolled
                                  ? AppTheme.success.withValues(alpha: 0.4)
                                  : AppPalette.border(ctx),
                            ),
                          ),
                          child: Row(children: [
                            Icon(
                              tempOnlyEnrolled
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: tempOnlyEnrolled
                                  ? AppTheme.success
                                  : AppPalette.textSecondary(ctx),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text('المسجّلة فقط ($enrolledCount حزمة)',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: tempOnlyEnrolled
                                        ? AppTheme.success
                                        : AppPalette.textPrimary(ctx))),
                          ]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Apply
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppTheme.buttonGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          _sh(12, c: _coral, o: 0.3),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _sort = tempSort;
                            _onlyEnrolled = tempOnlyEnrolled;
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('تطبيق',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _white)),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Bundle Card — نسخة داكنة على خلفية فاتحة (Udemy/Netflix style)
// ══════════════════════════════════════════════════════════════════════════════
class _BundleCard extends StatefulWidget {
  final Bundle bundle;
  const _BundleCard({required this.bundle});

  @override
  State<_BundleCard> createState() => _BundleCardState();
}

class _BundleCardState extends State<_BundleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final b = widget.bundle;
    final surf   = AppPalette.surface(context);
    final ink    = AppPalette.textPrimary(context);
    final mut    = AppPalette.textSecondary(context);
    final line   = AppPalette.border(context);
    final isDark = AppPalette.isDark(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push('/bundle/${b.id}');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Thumbnail ───────────────────────────────────────────
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(fit: StackFit.expand, children: [
                  b.thumbnail.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: b.thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _GradBg(index: b.id),
                          errorWidget: (_, __, ___) => _GradBg(index: b.id),
                        )
                      : _GradBg(index: b.id),

                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.30),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  if (b.isEnrolled)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _enrolledGreen,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _enrolledGreen.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.check_circle_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(width: 3),
                          Text('مسجّل',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                        ]),
                      ),
                    ),
                ]),
              ),

              // ── Info ────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 2),
                      Text(b.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: ink,
                              height: 1.3)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.workspace_premium_rounded,
                            size: 13, color: _coral),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                              b.courses.isNotEmpty
                                  ? b.courses.first.title
                                  : 'حزمة تعليمية متكاملة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: mut)),
                        ),
                      ]),
                      if (b.isEnrolled) ...[
                        const SizedBox(height: 8),
                        _MiniProgressDark(courses: b.courses),
                      ],
                      const Spacer(flex: 3),
                      Divider(height: 1, color: line),
                      const SizedBox(height: 8),
                      Row(children: [
                        // ── زر الاشتراك / البدء — يأخذ ثلثَي العرض ──────────
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              // لون الزر عند الاشتراك = نفس لون بادج «مسجّل»
                              gradient: b.isEnrolled ? null : AppTheme.ctaGradient,
                              color: b.isEnrolled ? _enrolledGreen : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(b.isEnrolled ? 'ابدأ' : 'اشترك',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(width: 4),
                                Icon(
                                    b.isEnrolled
                                        ? Icons.play_arrow_rounded
                                        : Icons.arrow_back_ios_rounded,
                                    size: b.isEnrolled ? 14 : 9,
                                    color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ── عدد الدورات — يأخذ الثلث المتبقي ───────────────
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 13, color: mut),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text('${b.courseCount} دورة',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: mut)),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mini Progress للخلفية الداكنة ─────────────────────────────────────────────
class _MiniProgressDark extends StatelessWidget {
  final List<BundleCourse> courses;
  const _MiniProgressDark({required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    final cnt = courses.where((c) => c.isEnrolled).length;
    final pct = cnt / courses.length;
    return Row(children: [
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 5,
            backgroundColor: AppPalette.border(context),
            valueColor: const AlwaysStoppedAnimation(AppTheme.success)),
        ),
      ),
      const SizedBox(width: 6),
      Text('${(pct * 100).round()}%',
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.success)),
    ]);
  }
}

// ── Chip Button للخلفية الداكنة ───────────────────────────────────────────────
class _ChipBtnDark extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final LinearGradient? gradient;
  
  const _ChipBtnDark({
    required this.label, 
    required this.icon,
    required this.bg, 
    required this.fg,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      gradient: gradient,
      color: gradient == null ? bg : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      boxShadow: [
        BoxShadow(
          color: (gradient != null ? bg : bg).withValues(alpha: 0.35),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 13, color: fg),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    ]),
  );
}

// ── Pill Badge للخلفية الداكنة ────────────────────────────────────────────────
class _PillDark extends StatelessWidget {
  final String label;
  final Color bg;
  final IconData icon;
  const _PillDark({required this.label, required this.bg, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: bg.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
      ),
      boxShadow: [
        BoxShadow(
          color: bg.withValues(alpha: 0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: Colors.white),
      const SizedBox(width: 3),
      Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
    ]),
  );
}

// ── Filter Pill محسن ──────────────────────────────────────────────────────────
class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onDelete;
  const _FilterPill({required this.label, this.icon, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
    decoration: BoxDecoration(
      color: AppTheme.coral500.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.coral500.withValues(alpha: 0.35)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[
        Icon(icon, size: 12, color: AppTheme.coral500),
        const SizedBox(width: 4),
      ],
      Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.coral500)),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: onDelete,
        child: Icon(Icons.close_rounded, size: 13, color: AppTheme.coral500),
      ),
    ]),
  );
}

// ── Gradient Background ───────────────────────────────────────────────────────
// ── Entrance animation (fade + slide up) ─────────────────────────────────────
class _FadeSlideIn extends StatelessWidget {
  final int index;
  final Widget child;
  const _FadeSlideIn({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final ms = 350 + (index.clamp(0, 6) * 70);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 22),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _GradBg extends StatelessWidget {
  final int index;
  const _GradBg({required this.index});

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.categoryGradients[index % AppTheme.categoryGradients.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: c, begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: const Center(
        child: Icon(Icons.collections_bookmark_rounded,
            size: 32, color: Colors.white24)),
    );
  }
}

// ── Shimmer Card ──────────────────────────────────────────────────────────────
class _CardShimmer extends StatelessWidget {
  const _CardShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);
    final base = isDark ? const Color(0xFF3A2225) : AppTheme.sage300;
    final hi   = isDark ? const Color(0xFF5C3A3E) : AppTheme.sage100;
    final block = AppPalette.surface(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: hi,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: block,
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(height: 8),
          Container(
              height: 11,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: block,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 6),
          Container(
              height: 11,
              width: 70,
              decoration: BoxDecoration(
                  color: block,
                  borderRadius: BorderRadius.circular(6))),
        ],
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: _coral.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.wifi_off_rounded, size: 40, color: _coral)),
        const SizedBox(height: 14),
        Text(message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppPalette.textSecondary(context))),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [_sh(10, c: _coral, o: 0.3)]),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.refresh_rounded, color: _white, size: 16),
              SizedBox(width: 8),
              Text('إعادة المحاولة',
                  style: TextStyle(color: _white, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ]),
    ),
  );
}

// ── Empty View ────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final bool hasQuery;
  final String query;
  const _EmptyView({required this.hasQuery, required this.query});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: _sage.withValues(alpha: 0.25), shape: BoxShape.circle),
        child: const Icon(Icons.folder_off_outlined, size: 40, color: _plum)),
      const SizedBox(height: 12),
      Text(hasQuery ? 'لا نتائج لـ "$query"' : 'لا توجد حزم متاحة',
          style: TextStyle(
              color: AppPalette.textSecondary(context), fontSize: 14)),
    ]),
  );
}
