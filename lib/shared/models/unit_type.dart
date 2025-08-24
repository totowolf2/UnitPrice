import '../../core/constants/unit_types.dart';

class UnitTypeModel {
  final UnitType type;
  final String displayName;
  final List<Unit> units;
  
  const UnitTypeModel({
    required this.type,
    required this.displayName,
    required this.units,
  });
  
  static List<UnitTypeModel> getAllUnitTypes() {
    return [
      UnitTypeModel(
        type: UnitType.weight,
        displayName: 'น้ำหนัก',
        units: [Unit.gram, Unit.kilogram],
      ),
      UnitTypeModel(
        type: UnitType.volume,
        displayName: 'ปริมาตร',
        units: [Unit.milliliter, Unit.liter],
      ),
      UnitTypeModel(
        type: UnitType.piece,
        displayName: 'ชิ้น',
        units: [Unit.piece],
      ),
    ];
  }
}