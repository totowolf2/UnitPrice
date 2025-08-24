import 'package:isar/isar.dart';

import '../models/comparison_session_model.dart';
import '../../../../core/constants/app_constants.dart';

class ComparisonLocalDataSource {
  final Isar _isar;
  
  ComparisonLocalDataSource(this._isar);
  
  Future<void> saveComparisonSession(ComparisonSessionModel session) async {
    await _isar.writeTxn(() async {
      // Get current sessions count
      final sessionsCount = await _isar.comparisonSessionModels.count();
      
      // If we have max sessions, delete the oldest one
      if (sessionsCount >= AppConstants.maxComparisonSessions) {
        final oldestSession = await _isar.comparisonSessionModels
            .where()
            .sortByCreatedAt()
            .findFirst();
        if (oldestSession != null) {
          await _isar.comparisonSessionModels.delete(oldestSession.id);
        }
      }
      
      // Save new session
      await _isar.comparisonSessionModels.put(session);
    });
  }
  
  Future<List<ComparisonSessionModel>> getRecentSessions() async {
    return await _isar.comparisonSessionModels
        .where()
        .sortByCreatedAtDesc()
        .limit(AppConstants.maxComparisonSessions)
        .findAll();
  }
  
  Future<ComparisonSessionModel?> getSessionById(int id) async {
    return await _isar.comparisonSessionModels.get(id);
  }
  
  Future<void> deleteSession(int id) async {
    await _isar.writeTxn(() async {
      await _isar.comparisonSessionModels.delete(id);
    });
  }
  
  Future<void> clearOldSessions() async {
    await _isar.writeTxn(() async {
      // Keep only the most recent sessions
      final allSessions = await _isar.comparisonSessionModels
          .where()
          .sortByCreatedAtDesc()
          .findAll();
      
      if (allSessions.length > AppConstants.maxComparisonSessions) {
        final sessionsToDelete = allSessions.skip(AppConstants.maxComparisonSessions);
        final idsToDelete = sessionsToDelete.map((s) => s.id).toList();
        await _isar.comparisonSessionModels.deleteAll(idsToDelete);
      }
    });
  }
}