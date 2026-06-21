import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/cache_manager.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_remote_ds.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource _remote;
  final CacheManager _cache;

  ProfileRepositoryImpl({
    ProfileRemoteDataSource? remote,
    CacheManager? cache,
  })  : _remote = remote ?? ProfileRemoteDataSource.instance,
        _cache  = cache  ?? CacheManager.instance;

  @override
  Future<Either<Failure, User>> getProfile(int userId) async {
    // ── FIX: لا تستخدم cache إذا userId=0 (يعني login لم يُعيد user_id صحيح)
    // userId=0 يعني جميع المستخدمين يشتركون نفس المفتاح "profile_0"
    // → hany55 يرى cache hany2 مباشرةً
    if (userId <= 0) {
      try {
        final model = await _remote.getProfile(userId);
        return Right(model);
      } on Failure catch (f) {
        return Left(f);
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    }

    final key    = 'profile_$userId';
    final cached = _cache.get<User>(key);
    if (cached != null) return Right(cached);

    try {
      final model = await _remote.getProfile(userId);
      _cache.set(key, model);
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final ok = await _remote.updateProfile(data);
      if (ok) _cache.invalidatePattern('profile_');
      return Right(ok);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      final url = await _remote.uploadAvatar(filePath);
      _cache.invalidatePattern('profile_');
      return Right(url);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getInstructorInfo(int instructorId) async {
    final key    = 'instructor_$instructorId';
    final cached = _cache.get<User>(key);
    if (cached != null) return Right(cached);

    try {
      final model = await _remote.getInstructorInfo(instructorId);
      _cache.set(key, model);
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getReviews({
    int? courseId,
    int page = 1,
  }) async {
    final key    = 'reviews_${courseId}_p$page';
    final cached = _cache.get<List<Review>>(key);
    if (cached != null) return Right(cached);

    try {
      final models = await _remote.getReviews(courseId: courseId, page: page);
      _cache.set(key, List<Review>.from(models));
      return Right(models);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> submitReview({
    required int courseId,
    required double rating,
    String review = '',
  }) async {
    try {
      final ok = await _remote.submitReview(
        courseId: courseId,
        rating: rating,
        review: review,
      );
      if (ok) {
        // أبطل كاش التقييمات والكورسات حتى يظهر التحديث فوراً
        _cache.invalidatePattern('reviews_');
        _cache.invalidatePattern('courses_');
      }
      return Right(ok);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
