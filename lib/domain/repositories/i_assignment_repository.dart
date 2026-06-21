import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/assignment.dart';

abstract class IAssignmentRepository {
  Future<Either<Failure, List<Assignment>>> getAssignments(int courseId);

  Future<Either<Failure, Assignment>> getAssignment(int assignmentId);

  Future<Either<Failure, AssignmentSubmission>> submitAssignment({
    required int assignmentId,
    required int courseId,
    String answer = '',
    List<File> files = const [],
  });
}
