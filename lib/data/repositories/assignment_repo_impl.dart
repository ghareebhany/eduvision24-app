import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/cache_manager.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/repositories/i_assignment_repository.dart';
import '../datasources/assignment_remote_ds.dart';

class AssignmentRepositoryImpl implements IAssignmentRepository {
  final AssignmentRemoteDataSource _remote;
  final CacheManager _cache;

  AssignmentRepositoryImpl({
    AssignmentRemoteDataSource? remote,
    CacheManager? cache,
  })  : _remote = remote ?? AssignmentRemoteDataSource.instance,
        _cache = cache ?? CacheManager.instance;

  @override
  Future<Either<Failure, List<Assignment>>> getAssignments(
      int courseId) async {
    final key = 'assignments_$courseId';
    final cached = _cache.get<List<Assignment>>(key);
    if (cached != null) return Right(cached);
    try {
      final models = await _remote.getAssignments(courseId);
      _cache.set(key, List<Assignment>.from(models));
      return Right(models);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Assignment>> getAssignment(int assignmentId) async {
    try {
      final model = await _remote.getAssignment(assignmentId);
      return Right(model);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AssignmentSubmission>> submitAssignment({
    required int assignmentId,
    required int courseId,
    String answer = '',
    List<File> files = const [],
  }) async {
    try {
      final sub = await _remote.submitAssignment(
        assignmentId: assignmentId,
        courseId: courseId,
        answer: answer,
        files: files,
      );
      // إبطال كاش الواجبات حتى تتحدّث القائمة
      _cache.invalidatePattern('assignments_');
      return Right(sub);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
