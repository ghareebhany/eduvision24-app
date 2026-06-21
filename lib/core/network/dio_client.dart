import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'api_interceptor.dart';

class DioClient {
  DioClient._();
  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late Dio _dio;
  bool _initialized = false;

  void _ensureInit() {
    if (!_initialized) _init();
  }

  Dio get dio {
    _ensureInit();
    return _dio;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // setNonce / clearNonce / restoreNonce — محذوفة بالكامل
  // ══════════════════════════════════════════════════════════════════════════
  //
  // السبب: X-WP-Nonce هو آلية مصادقة مخصصة للمتصفح (browser cookie session).
  // إرساله من التطبيق المحمول يُسبب تعارضاً خطيراً:
  //
  //   1. الـ nonce endpoint يُخدَّم من cache الخادم → نفس القيمة لجميع المستخدمين
  //   2. WordPress يُعطي الأولوية لـ nonce على JWT عند وجودهما معاً
  //   3. النتيجة: أي مستخدم يرسل nonce مرتبطاً بمستخدم آخر يُعرَّف بهوية الأول
  //
  // JWT Bearer وحده كافٍ تماماً للتطبيق المحمول.
  // ══════════════════════════════════════════════════════════════════════════

  /// يمسح JWT token من headers الـ Dio عند تسجيل الخروج
  void clearToken() {
    _ensureInit();
    _dio.options.headers.remove('Authorization');
  }

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // X-WP-Nonce محذوف عمداً — انظر التعليق أعلاه
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor());

    // سجلّ الشبكة يعمل في وضع التطوير فقط، مع حجب البيانات الحساسة:
    //   - requestHeader: false  ← لا يُطبع رأس Authorization (توكن JWT)
    //   - filter يتخطّى نقطة /token ← لا تُطبع كلمة المرور ولا التوكن
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          compact: true,
          filter: (options, args) =>
              !options.path.contains('/jwt-auth/v1/token'),
        ),
      );
    }

    _initialized = true;
  }
}
