enum UnitType { weight, volume, piece }

enum Unit {
  // Weight
  gram(UnitType.weight, 1.0, 'g'),
  kilogram(UnitType.weight, 1000.0, 'kg'),
  
  // Volume  
  milliliter(UnitType.volume, 1.0, 'ml'),
  liter(UnitType.volume, 1000.0, 'L'),
  
  // Piece
  piece(UnitType.piece, 1.0, 'piece');
  
  const Unit(this.type, this.baseMultiplier, this.displayName);
  final UnitType type;
  final double baseMultiplier;
  final String displayName;
}

extension UnitExtension on Unit {
  /// Get the base unit for this unit's type
  Unit get baseUnit {
    switch (type) {
      case UnitType.weight:
        return Unit.gram;
      case UnitType.volume:
        return Unit.milliliter;
      case UnitType.piece:
        return Unit.piece;
    }
  }
}