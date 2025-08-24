import 'package:isar/isar.dart';

import '../../domain/entities/comparison_session.dart';

part 'comparison_session_model.g.dart';

@collection
class ComparisonSessionModel extends ComparisonSession {
  @override
  Id id = Isar.autoIncrement;
  
  // Default constructor for Isar
  ComparisonSessionModel();
  
  @override
  late DateTime createdAt;
  
  @override
  late List<String> productSnapshots; // JSON strings of product data at comparison time
  
  // Ensure only 3 sessions are kept (circular buffer)
  static const int maxSessions = 3;
  
  // Convert from domain entity
  factory ComparisonSessionModel.fromEntity(ComparisonSession session) {
    return ComparisonSessionModel()
      ..createdAt = session.createdAt
      ..productSnapshots = List.from(session.productSnapshots);
  }
  
  // Create new instance
  ComparisonSessionModel.create({
    required this.productSnapshots,
  }) {
    createdAt = DateTime.now();
  }
  
  // Create from product snapshots
  factory ComparisonSessionModel.fromProductSnapshots(
    List<String> snapshots,
  ) {
    return ComparisonSessionModel.create(
      productSnapshots: snapshots,
    );
  }
}