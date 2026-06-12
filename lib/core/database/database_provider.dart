import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'drift_database.dart';

/// Drift Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Provider가 dispose될 때 데이터베이스 연결 종료
  ref.onDispose(() {
    database.close();
  });

  return database;
});
