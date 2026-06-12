import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import 'firebase_service.dart';
import 'sync_service.dart';

/// FirebaseService Provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// SyncService Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final firebaseService = ref.watch(firebaseServiceProvider);
  return SyncService(database, firebaseService);
});

/// 동기화 실행 및 상태 관리
class SyncNotifier extends StateNotifier<AsyncValue<void>> {
  SyncNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  /// 이벤트 동기화 실행
  Future<void> syncEvents(String userId, {String? coupleId}) async {
    state = const AsyncValue.loading();
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.smartSyncEvents(userId, coupleId: coupleId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      print('동기화 실패: $e');
    }
  }
}

final syncNotifierProvider =
    StateNotifierProvider<SyncNotifier, AsyncValue<void>>((ref) {
      return SyncNotifier(ref);
    });
