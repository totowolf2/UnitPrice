import '../entities/comparison_session.dart';

abstract class ComparisonRepository {
  Future<void> saveComparisonSession(ComparisonSession session);
  Future<List<ComparisonSession>> getRecentSessions();
  Future<ComparisonSession?> getSessionById(String id);
  Future<void> deleteSession(String id);
  Future<void> clearOldSessions();
}