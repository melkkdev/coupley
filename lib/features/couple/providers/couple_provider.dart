import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/couple_service.dart';
import '../../../core/services/user_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/couple.dart';

/// CoupleService Provider
final coupleServiceProvider = Provider<CoupleService>((ref) {
  return CoupleService();
});

/// 현재 유저의 커플 정보 스트림 Provider
///
/// userProfile의 coupleId를 보고, 연결된 커플 정보를 실시간으로 가져옴
final coupleProvider = StreamProvider.autoDispose<Couple?>((ref) {
  final coupleService = ref.watch(coupleServiceProvider);

  // userProfile 전체가 아니라 coupleId만 select
  // (닉네임 등 다른 필드 변경 시 불필요한 재평가 방지)
  final coupleId = ref.watch(
    userProfileProvider.select((async) => async.valueOrNull?.coupleId),
  );

  if (coupleId == null) {
    return Stream.value(null); // 아직 커플 연결 안 됨
  }

  return coupleService.getCoupleStream(coupleId);
});

/// 커플 멤버들의 이름 맵 Provider { userId: userName }
final coupleMemberNamesProvider =
    FutureProvider.autoDispose<Map<String, String>>((ref) async {
      final couple = ref.watch(coupleProvider).valueOrNull;

      if (couple == null || !couple.isConnected) {
        return {};
      }

      final userService = ref.watch(userServiceProvider);
      return userService.getUserNames(couple.members);
    });

/// 커플 연결 액션 (초대 코드 생성/합류/해제)
class CoupleNotifier extends StateNotifier<AsyncValue<Couple?>> {
  CoupleNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  /// 초대 코드 생성
  Future<Couple?> createInvite() async {
    state = const AsyncValue.loading();
    try {
      final coupleService = ref.read(coupleServiceProvider);
      final authState = ref.read(authProvider);

      if (authState.userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final couple = await coupleService.createInvite(authState.userId!);
      state = AsyncValue.data(couple);
      return couple;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// 초대 코드로 합류
  Future<Couple?> joinByCode(String inviteCode) async {
    state = const AsyncValue.loading();
    try {
      final coupleService = ref.read(coupleServiceProvider);
      final authState = ref.read(authProvider);

      if (authState.userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      final couple = await coupleService.joinByCode(
        authState.userId!,
        inviteCode,
      );
      state = AsyncValue.data(couple);
      return couple;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // UI에서 에러 메시지 보여주기 위해
    }
  }

  /// 커플 연결 해제
  Future<void> disconnect(Couple couple) async {
    state = const AsyncValue.loading();
    try {
      final coupleService = ref.read(coupleServiceProvider);
      await coupleService.disconnect(couple.id, couple.members);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final coupleNotifierProvider =
    StateNotifierProvider<CoupleNotifier, AsyncValue<Couple?>>((ref) {
      return CoupleNotifier(ref);
    });
