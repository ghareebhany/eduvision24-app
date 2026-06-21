import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  شاشة إنشاء حساب جديد
//  تُرسل البيانات إلى: POST /app/v1/register  (hany-app-api)
//  وليس /wp/v2/users الذي يشترط صلاحية Administrator
// ══════════════════════════════════════════════════════════════════════════════

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ────────────────────────────────────────────────────────────
  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _usernameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();
  final _studentPhoneCtrl = TextEditingController();
  final _parentPhoneCtrl  = TextEditingController();
  final _schoolCtrl       = TextEditingController();

  // ── Dropdown selections ────────────────────────────────────────────────────
  String? _selectedGovernorate;
  String? _selectedGrade;
  String? _selectedAttendance;

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  // ── بيانات الـ dropdowns — نفس قيم إضافة Custom Student Fields ────────────
  static const List<String> _governorates = [
    'القاهرة', 'الجيزة', 'القليوبية', 'الإسكندرية', 'البحيرة', 'مطروح',
    'كفر الشيخ', 'الغربية', 'المنوفية', 'الدقهلية', 'دمياط', 'بورسعيد',
    'الإسماعيلية', 'الشرقية', 'السويس', 'شمال سيناء', 'جنوب سيناء',
    'بني سويف', 'الفيوم', 'المنيا', 'أسيوط', 'سوهاج', 'قنا',
    'الأقصر', 'أسوان', 'الوادي الجديد', 'البحر الأحمر',
  ];

  static const List<String> _grades = [
    'الأول الثانوي',
    'الثاني الثانوي',
    'الثالث الثانوي',
  ];

  static const Map<String, String> _attendanceTypes = {
    'online': 'Online',
    'center': 'Center',
  };

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _studentPhoneCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  // ── إرسال النموذج إلى /app/v1/register ────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من الـ dropdowns
    if (_selectedGovernorate == null ||
        _selectedGrade == null ||
        _selectedAttendance == null) {
      _showError('يرجى اختيار المحافظة والصف الدراسي ونوع الحضور');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await DioClient.instance.dio.post(
        ApiConstants.registerEndpoint, // /app/v1/register
        data: {
          'first_name'          : _firstNameCtrl.text.trim(),
          'last_name'           : _lastNameCtrl.text.trim(),
          'username'            : _usernameCtrl.text.trim(),
          'email'               : _emailCtrl.text.trim(),
          'password'            : _passwordCtrl.text,
          'student_phone'       : _studentPhoneCtrl.text.trim(),
          'parent_phone'        : _parentPhoneCtrl.text.trim(),
          'school_name'         : _schoolCtrl.text.trim(),
          'student_governorate' : _selectedGovernorate,
          'student_grade'       : _selectedGrade,
          'attendance_type'     : _selectedAttendance,
        },
        options: Options(extra: {'skipAuth': true}),
      );

      final msg = response.data?['message'] as String? ?? 'تم إنشاء الحساب بنجاح';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Color(0xFFE26D5C)),
        );
        context.go('/login');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg  = (body is Map ? body['message'] : null) as String?
                ?? 'فشل إنشاء الحساب، يرجى المحاولة مرة أخرى';
      _showError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── الاسم الأول والأخير ────────────────────────────────────
                _sectionTitle('البيانات الأساسية'),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _firstNameCtrl, 'الاسم الأول', Icons.person_outline,
                        validator: (v) => v!.trim().isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        _lastNameCtrl, 'الاسم الأخير', Icons.person_outline,
                        validator: (v) => v!.trim().isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── اسم المستخدم ───────────────────────────────────────────
                _field(
                  _usernameCtrl, 'اسم المستخدم', Icons.account_circle_outlined,
                  textDirection: TextDirection.ltr,
                  validator: (v) {
                    if (v!.trim().isEmpty) return 'اسم المستخدم مطلوب';
                    if (v.trim().length < 4) return 'يجب أن يكون 4 أحرف على الأقل';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                      return 'أحرف إنجليزية وأرقام و _ فقط';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── البريد الإلكتروني ──────────────────────────────────────
                _field(
                  _emailCtrl, 'البريد الإلكتروني', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  validator: (v) => !v!.contains('@') ? 'بريد إلكتروني غير صحيح' : null,
                ),
                const SizedBox(height: 14),

                // ── كلمة المرور ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _passwordField(
                        _passwordCtrl, 'كلمة المرور', _obscurePassword,
                        () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) => v!.length < 8
                            ? 'يجب أن تكون 8 أحرف على الأقل'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _passwordField(
                        _confirmCtrl, 'تأكيد كلمة المرور', _obscureConfirm,
                        () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) => v != _passwordCtrl.text
                            ? 'كلمتا المرور غير متطابقتين'
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 8),

                // ── الحقول المخصصة ─────────────────────────────────────────
                _sectionTitle('بيانات الطالب'),

                // هواتف
                Row(
                  children: [
                    Expanded(
                      child: _phoneField(
                        _studentPhoneCtrl, 'رقم تليفون الطالب',
                        Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _phoneField(
                        _parentPhoneCtrl, 'رقم تليفون ولي الأمر',
                        Icons.phone_in_talk_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // المدرسة
                _field(
                  _schoolCtrl, 'اسم المدرسة', Icons.school_outlined,
                  validator: (v) => v!.trim().isEmpty ? 'اسم المدرسة مطلوب' : null,
                ),
                const SizedBox(height: 14),

                // المحافظة
                _dropdown(
                  label: 'المحافظة',
                  icon: Icons.location_on_outlined,
                  value: _selectedGovernorate,
                  items: _governorates,
                  onChanged: (v) => setState(() => _selectedGovernorate = v),
                ),
                const SizedBox(height: 14),

                // الصف والحضور
                Row(
                  children: [
                    Expanded(
                      child: _dropdown(
                        label: 'الصف الدراسي',
                        icon: Icons.class_outlined,
                        value: _selectedGrade,
                        items: _grades,
                        onChanged: (v) => setState(() => _selectedGrade = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdown(
                        label: 'نوع الحضور',
                        icon: Icons.event_seat_outlined,
                        value: _selectedAttendance,
                        items: _attendanceTypes.keys.toList(),
                        displayLabel: (k) => _attendanceTypes[k]!,
                        onChanged: (v) => setState(() => _selectedAttendance = v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── زر الإرسال ─────────────────────────────────────────────
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('إنشاء الحساب',
                          style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),

                // ── رابط تسجيل الدخول ──────────────────────────────────────
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('لديك حساب بالفعل؟ سجّل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets المساعدة ────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    TextDirection textDirection = TextDirection.rtl,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      textDirection: textDirection,
      decoration: _decor(label, icon),
      validator: validator,
    );
  }

  Widget _phoneField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _decor(label, icon),
      validator: (v) {
        final clean = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
        if (clean.isEmpty) return 'مطلوب';
        if (clean.length < 10 || clean.length > 15) return '10-15 رقم';
        return null;
      },
    );
  }

  Widget _passwordField(
    TextEditingController ctrl,
    String label,
    bool obscure,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      textDirection: TextDirection.ltr,
      decoration: _decor(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: toggle,
        ),
      ),
      validator: validator,
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String Function(String)? displayLabel,
  }) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _decor(label, icon),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  displayLabel != null ? displayLabel(item) : item,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'يرجى الاختيار' : null,
      dropdownColor: cs.surface,
    );
  }

  InputDecoration _decor(String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
    );
  }
}
