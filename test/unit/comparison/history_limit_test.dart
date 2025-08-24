import 'package:flutter_test/flutter_test.dart';
import 'package:unitprice/core/constants/app_constants.dart';

// Simple test to verify the history limit constant
void main() {
  group('History Limit Configuration', () {
    test('should have maximum comparison sessions limit of 3', () {
      expect(AppConstants.maxComparisonSessions, equals(3));
    });
    
    test('should be a positive integer', () {
      expect(AppConstants.maxComparisonSessions, greaterThan(0));
      expect(AppConstants.maxComparisonSessions, isA<int>());
    });
  });
}