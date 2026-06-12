import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/models/user_profile.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'user_service.dart';

/// UserService Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// 현재 유저 프로필 스트림 Provider
final userProfileProvider = StreamProvider.autoDispose<UserProfile?>((ref) {
  final userService = ref.watch(userServiceProvider);
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated || authState.userId == null) {
    return Stream.value(null);
  }

  return userService.getUserProfileStream(authState.userId!);
});
