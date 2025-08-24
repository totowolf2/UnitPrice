import 'package:flutter_test/flutter_test.dart';
import 'package:unitprice/core/constants/unit_types.dart';
import 'package:unitprice/core/utils/unit_converter.dart';

void main() {
  group('UnitConverter', () {
    group('toBaseUnit conversions', () {
      test('should convert grams to base unit correctly', () {
        final result = UnitConverter.toBaseUnit(500.0, Unit.gram);
        expect(result, equals(500.0));
      });
      
      test('should convert kilograms to base unit correctly', () {
        final result = UnitConverter.toBaseUnit(2.5, Unit.kilogram);
        expect(result, equals(2500.0));
      });
      
      test('should convert milliliters to base unit correctly', () {
        final result = UnitConverter.toBaseUnit(750.0, Unit.milliliter);
        expect(result, equals(750.0));
      });
      
      test('should convert liters to base unit correctly', () {
        final result = UnitConverter.toBaseUnit(1.5, Unit.liter);
        expect(result, equals(1500.0));
      });
      
      test('should handle pieces correctly (1:1 ratio)', () {
        final result = UnitConverter.toBaseUnit(10.0, Unit.piece);
        expect(result, equals(10.0));
      });
    });
    
    group('canCompare method', () {
      test('should allow weight unit comparisons', () {
        expect(UnitConverter.canCompare(Unit.gram, Unit.kilogram), isTrue);
      });
      
      test('should allow volume unit comparisons', () {
        expect(UnitConverter.canCompare(Unit.milliliter, Unit.liter), isTrue);
      });
      
      test('should reject cross-type comparisons', () {
        expect(UnitConverter.canCompare(Unit.gram, Unit.milliliter), isFalse);
        expect(UnitConverter.canCompare(Unit.kilogram, Unit.piece), isFalse);
        expect(UnitConverter.canCompare(Unit.liter, Unit.piece), isFalse);
      });
      
      test('should allow same unit comparisons', () {
        expect(UnitConverter.canCompare(Unit.gram, Unit.gram), isTrue);
        expect(UnitConverter.canCompare(Unit.piece, Unit.piece), isTrue);
      });
    });
    
    group('convertBetweenUnits method', () {
      test('should convert kg to grams correctly', () {
        final result = UnitConverter.convertBetweenUnits(2.5, Unit.kilogram, Unit.gram);
        expect(result, equals(2500.0));
      });
      
      test('should convert grams to kg correctly', () {
        final result = UnitConverter.convertBetweenUnits(2500.0, Unit.gram, Unit.kilogram);
        expect(result, equals(2.5));
      });
      
      test('should convert liters to ml correctly', () {
        final result = UnitConverter.convertBetweenUnits(1.5, Unit.liter, Unit.milliliter);
        expect(result, equals(1500.0));
      });
      
      test('should convert ml to liters correctly', () {
        final result = UnitConverter.convertBetweenUnits(1500.0, Unit.milliliter, Unit.liter);
        expect(result, equals(1.5));
      });
      
      test('should handle same unit conversion', () {
        final result = UnitConverter.convertBetweenUnits(100.0, Unit.gram, Unit.gram);
        expect(result, equals(100.0));
      });
      
      test('should throw error for cross-type conversion', () {
        expect(
          () => UnitConverter.convertBetweenUnits(100.0, Unit.gram, Unit.milliliter),
          throwsArgumentError,
        );
      });
    });
    
    group('getUnitsForType method', () {
      test('should return weight units correctly', () {
        final weightUnits = UnitConverter.getUnitsForType(UnitType.weight);
        expect(weightUnits, contains(Unit.gram));
        expect(weightUnits, contains(Unit.kilogram));
        expect(weightUnits.length, equals(2));
      });
      
      test('should return volume units correctly', () {
        final volumeUnits = UnitConverter.getUnitsForType(UnitType.volume);
        expect(volumeUnits, contains(Unit.milliliter));
        expect(volumeUnits, contains(Unit.liter));
        expect(volumeUnits.length, equals(2));
      });
      
      test('should return piece units correctly', () {
        final pieceUnits = UnitConverter.getUnitsForType(UnitType.piece);
        expect(pieceUnits, contains(Unit.piece));
        expect(pieceUnits.length, equals(1));
      });
    });
    
    group('Edge cases', () {
      test('should handle zero values', () {
        expect(UnitConverter.toBaseUnit(0.0, Unit.kilogram), equals(0.0));
        expect(UnitConverter.convertBetweenUnits(0.0, Unit.liter, Unit.milliliter), equals(0.0));
      });
      
      test('should handle negative values', () {
        expect(UnitConverter.toBaseUnit(-5.0, Unit.kilogram), equals(-5000.0));
        expect(UnitConverter.convertBetweenUnits(-1.0, Unit.liter, Unit.milliliter), equals(-1000.0));
      });
      
      test('should handle very large numbers', () {
        final largeNumber = 999999.999;
        final result = UnitConverter.toBaseUnit(largeNumber, Unit.kilogram);
        expect(result, equals(largeNumber * 1000));
      });
      
      test('should handle very small decimal numbers', () {
        final smallNumber = 0.001;
        final result = UnitConverter.toBaseUnit(smallNumber, Unit.kilogram);
        expect(result, closeTo(1.0, 0.0001));
      });
    });
  });
}