// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comparison_session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetComparisonSessionModelCollection on Isar {
  IsarCollection<ComparisonSessionModel> get comparisonSessionModels =>
      this.collection();
}

const ComparisonSessionModelSchema = CollectionSchema(
  name: r'ComparisonSessionModel',
  id: 2305374934628685288,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'productSnapshots': PropertySchema(
      id: 1,
      name: r'productSnapshots',
      type: IsarType.stringList,
    )
  },
  estimateSize: _comparisonSessionModelEstimateSize,
  serialize: _comparisonSessionModelSerialize,
  deserialize: _comparisonSessionModelDeserialize,
  deserializeProp: _comparisonSessionModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _comparisonSessionModelGetId,
  getLinks: _comparisonSessionModelGetLinks,
  attach: _comparisonSessionModelAttach,
  version: '3.1.0+1',
);

int _comparisonSessionModelEstimateSize(
  ComparisonSessionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.productSnapshots.length * 3;
  {
    for (var i = 0; i < object.productSnapshots.length; i++) {
      final value = object.productSnapshots[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _comparisonSessionModelSerialize(
  ComparisonSessionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeStringList(offsets[1], object.productSnapshots);
}

ComparisonSessionModel _comparisonSessionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ComparisonSessionModel();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.productSnapshots = reader.readStringList(offsets[1]) ?? [];
  return object;
}

P _comparisonSessionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _comparisonSessionModelGetId(ComparisonSessionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _comparisonSessionModelGetLinks(
    ComparisonSessionModel object) {
  return [];
}

void _comparisonSessionModelAttach(
    IsarCollection<dynamic> col, Id id, ComparisonSessionModel object) {
  object.id = id;
}

extension ComparisonSessionModelQueryWhereSort
    on QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QWhere> {
  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ComparisonSessionModelQueryWhere on QueryBuilder<
    ComparisonSessionModel, ComparisonSessionModel, QWhereClause> {
  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ComparisonSessionModelQueryFilter on QueryBuilder<
    ComparisonSessionModel, ComparisonSessionModel, QFilterCondition> {
  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productSnapshots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productSnapshots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productSnapshots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productSnapshots',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productSnapshots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productSnapshots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
          QAfterFilterCondition>
      productSnapshotsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productSnapshots',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
          QAfterFilterCondition>
      productSnapshotsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productSnapshots',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productSnapshots',
        value: '',
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productSnapshots',
        value: '',
      ));
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productSnapshots',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productSnapshots',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productSnapshots',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productSnapshots',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productSnapshots',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel,
      QAfterFilterCondition> productSnapshotsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productSnapshots',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ComparisonSessionModelQueryObject on QueryBuilder<
    ComparisonSessionModel, ComparisonSessionModel, QFilterCondition> {}

extension ComparisonSessionModelQueryLinks on QueryBuilder<
    ComparisonSessionModel, ComparisonSessionModel, QFilterCondition> {}

extension ComparisonSessionModelQuerySortBy
    on QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QSortBy> {
  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }
}

extension ComparisonSessionModelQuerySortThenBy on QueryBuilder<
    ComparisonSessionModel, ComparisonSessionModel, QSortThenBy> {
  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension ComparisonSessionModelQueryWhereDistinct
    on QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QDistinct> {
  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ComparisonSessionModel, ComparisonSessionModel, QDistinct>
      distinctByProductSnapshots() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productSnapshots');
    });
  }
}

extension ComparisonSessionModelQueryProperty on QueryBuilder<
    ComparisonSessionModel, ComparisonSessionModel, QQueryProperty> {
  QueryBuilder<ComparisonSessionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ComparisonSessionModel, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ComparisonSessionModel, List<String>, QQueryOperations>
      productSnapshotsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productSnapshots');
    });
  }
}
