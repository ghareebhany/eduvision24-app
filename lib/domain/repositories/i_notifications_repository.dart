import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/notification.dart';

abstract class INotificationsRepository {
  Future<Either<Failure, NotificationsBundle>> getNotifications();
  Future<Either<Failure, int>> markRead();
}
