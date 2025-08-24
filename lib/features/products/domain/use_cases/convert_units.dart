import '../../../../core/constants/unit_types.dart';
import '../../../../core/utils/unit_converter.dart';

class ConvertUnitsUseCase {
  double toBaseUnit(double amount, Unit unit) {
    return UnitConverter.toBaseUnit(amount, unit);
  }
  
  bool canCompare(Unit unit1, Unit unit2) {
    return UnitConverter.canCompare(unit1, unit2);
  }
  
  List<Unit> getUnitsForType(UnitType type) {
    return UnitConverter.getUnitsForType(type);
  }
  
  double convertBetweenUnits(
    double amount, 
    Unit fromUnit, 
    Unit toUnit
  ) {
    return UnitConverter.convertBetweenUnits(amount, fromUnit, toUnit);
  }
  
  String getDisplayName(Unit unit) {
    return unit.displayName;
  }
  
  UnitType getUnitType(Unit unit) {
    return unit.type;
  }
}