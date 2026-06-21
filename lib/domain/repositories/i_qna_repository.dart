import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/qna.dart';

abstract class IQnaRepository {
  Future<Either<Failure, List<QnaItem>>> getQna(int courseId, {int page});
  Future<Either<Failure, bool>> postQna({
    required int courseId,
    required String content,
    int parentId,
  });
}
