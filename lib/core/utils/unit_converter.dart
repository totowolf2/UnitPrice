import '../constants/unit_types.dart';

class UnitConverter {
  /// Convert amount to base unit (e.g., grams for weight, ml for volume)
  static double toBaseUnit(double amount, Unit unit) {
    return amount * unit.baseMultiplier;
  }
  
  /// Check if two units can be compared (same unit type)
  static bool canCompare(Unit unit1, Unit unit2) {
    return unit1.type == unit2.type;
  }
  
  /// Get all units for a specific unit type
  static List<Unit> getUnitsForType(UnitType type) {
    return Unit.values.where((unit) => unit.type == type).toList();
  }
  
  /// Convert from one unit to another within the same type
  static double convertBetweenUnits(
    double amount, 
    Unit fromUnit, 
    Unit toUnit
  ) {
    if (!canCompare(fromUnit, toUnit)) {
      throw ArgumentError('Cannot convert between different unit types');
    }
    
    // Convert to base unit first, then to target unit
    final baseAmount = toBaseUnit(amount, fromUnit);
    return baseAmount / toUnit.baseMultiplier;
  }
}