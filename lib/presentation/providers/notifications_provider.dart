import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import 'di_providers.dart';

final notificationsProvider =
    FutureProvider.autoDispose<NotificationsBundle>((ref) async {
  final result = await ref.read(getNotificationsUseCaseProvider).call();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (bundle) => bundle,
  );
});
