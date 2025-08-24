import '../../domain/entities/comparison_session.dart';
import '../../domain/repositories/comparison_repository.dart';
import '../datasources/comparison_local_datasource.dart';
import '../models/comparison_session_model.dart';

class ComparisonRepositoryImpl implements ComparisonRepository {
  final ComparisonLocalDataSource _localDataSource;
  
  ComparisonRepositoryImpl(this._localDataSource);
  
  @override
  Future<void> saveComparisonSession(ComparisonSession session) async {
    final model = session is ComparisonSessionModel 
        ? session 
        : ComparisonSessionModel.fromEntity(session);
    await _localDataSource.saveComparisonSession(model);
  }
  
  @override
  Future<List<ComparisonSession>> getRecentSessions() async {
    final models = await _localDataSource.getRecentSessions();
    return models.cast<ComparisonSession>();
  }
  
  @override
  Future<ComparisonSession?> getSessionById(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return null;
    final model = await _localDataSource.getSessionById(intId);
    return model;
  }
  
  @override
  Future<void> deleteSession(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      await _localDataSource.deleteSession(intId);
    }
  }
  
  @override
  Future<void> clearOldSessions() async {
    await _localDataSource.clearOldSessions();
  }
}