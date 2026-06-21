import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/i_notifications_repository.dart';
import '../datasources/notifications_remote_ds.dart';

class NotificationsRepositoryImpl implements INotificationsRepository {
  final NotificationsRemoteDataSource _remote;

  NotificationsRepositoryImpl({NotificationsRemoteDataSource? remote})
      : _remote = remote ?? NotificationsRemoteDataSource.instance;

  @override
  Future<Either<Failure, NotificationsBundle>> getNotifications() async {
    try {
      return Right(await _remote.getNotifications());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> markRead() async {
    try {
      return Right(await _remote.markRead());
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
