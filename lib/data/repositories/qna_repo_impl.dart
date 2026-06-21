import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/cache_manager.dart';
import '../../domain/entities/qna.dart';
import '../../domain/repositories/i_qna_repository.dart';
import '../datasources/qna_remote_ds.dart';

class QnaRepositoryImpl implements IQnaRepository {
  final QnaRemoteDataSource _remote;
  final CacheManager _cache;

  QnaRepositoryImpl({QnaRemoteDataSource? remote, CacheManager? cache})
      : _remote = remote ?? QnaRemoteDataSource.instance,
        _cache = cache ?? CacheManager.instance;

  @override
  Future<Either<Failure, List<QnaItem>>> getQna(int courseId,
      {int page = 1}) async {
    final key = 'qna_${courseId}_p$page';
    final cached = _cache.get<List<QnaItem>>(key);
    if (cached != null) return Right(cached);
    try {
      final models = await _remote.getQna(courseId, page: page);
      // مدة قصيرة حتى تظهر ردود الإدارة الجديدة سريعاً دون انتظار
      _cache.set(key, List<QnaItem>.from(models),
          ttl: const Duration(seconds: 12));
      return Right(models);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> postQna({
    required int courseId,
    required String content,
    int parentId = 0,
  }) async {
    try {
      final ok = await _remote.postQna(
        courseId: courseId,
        content: content,
        parentId: parentId,
      );
      if (ok) _cache.invalidatePattern('qna_');
      return Right(ok);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
