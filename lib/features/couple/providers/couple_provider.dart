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

  final coupleId = ref.watch(
    userProfileProvider.select((async) => async.valueOrNull?.coupleId),
  );

  if (coupleId == null) {
    return Stream.value(null);
  }

  return coupleService.getCoupleStream(coupleId).map((couple) {
    // couples 문서가 없어졌으면 (상대가 해제) 자동 정리
    if (couple == null) {
      // microtask로 미뤄서 dispose 타이밍 충돌 방지
      Future.microtask(() {
        try {
          final userId = ref.read(authProvider).userId;
          if (userId != null) {
            coupleService.clearMyCoupleId(userId);
          }
        } catch (_) {
          // provider가 이미 dispose된 경우 무시
        }
      });
    }
    return couple;
  });
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
    // 이미 로딩 중이면 무시 (중복 호출 방지)
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    try {
      final coupleService = ref.read(coupleServiceProvider);
      final authState = ref.read(authProvider);

      if (authState.userId == null) {
        throw Exception('로그인이 필요합니다');
      }

      await coupleService.disconnect(couple.id, authState.userId!);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // rethrow 제거 - 에러를 조용히 처리 (이미 해제된 경우 등)
    }
  }
}

final coupleNotifierProvider =
    StateNotifierProvider<CoupleNotifier, AsyncValue<Couple?>>((ref) {
      return CoupleNotifier(ref);
    });
