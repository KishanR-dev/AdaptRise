// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SleepTargetsTable extends SleepTargets
    with TableInfo<$SleepTargetsTable, SleepTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWakeMinutesMeta = const VerificationMeta(
    'targetWakeMinutes',
  );
  @override
  late final GeneratedColumn<int> targetWakeMinutes = GeneratedColumn<int>(
    'target_wake_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalWakeMinutesMeta = const VerificationMeta(
    'goalWakeMinutes',
  );
  @override
  late final GeneratedColumn<int> goalWakeMinutes = GeneratedColumn<int>(
    'goal_wake_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetDate,
    targetWakeMinutes,
    goalWakeMinutes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('target_wake_minutes')) {
      context.handle(
        _targetWakeMinutesMeta,
        targetWakeMinutes.isAcceptableOrUnknown(
          data['target_wake_minutes']!,
          _targetWakeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWakeMinutesMeta);
    }
    if (data.containsKey('goal_wake_minutes')) {
      context.handle(
        _goalWakeMinutesMeta,
        goalWakeMinutes.isAcceptableOrUnknown(
          data['goal_wake_minutes']!,
          _goalWakeMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_goalWakeMinutesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepTarget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      )!,
      targetWakeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_wake_minutes'],
      )!,
      goalWakeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_wake_minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SleepTargetsTable createAlias(String alias) {
    return $SleepTargetsTable(attachedDatabase, alias);
  }
}

class SleepTarget extends DataClass implements Insertable<SleepTarget> {
  final int id;
  final DateTime targetDate;
  final int targetWakeMinutes;
  final int goalWakeMinutes;
  final DateTime createdAt;
  const SleepTarget({
    required this.id,
    required this.targetDate,
    required this.targetWakeMinutes,
    required this.goalWakeMinutes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_date'] = Variable<DateTime>(targetDate);
    map['target_wake_minutes'] = Variable<int>(targetWakeMinutes);
    map['goal_wake_minutes'] = Variable<int>(goalWakeMinutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SleepTargetsCompanion toCompanion(bool nullToAbsent) {
    return SleepTargetsCompanion(
      id: Value(id),
      targetDate: Value(targetDate),
      targetWakeMinutes: Value(targetWakeMinutes),
      goalWakeMinutes: Value(goalWakeMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory SleepTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepTarget(
      id: serializer.fromJson<int>(json['id']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      targetWakeMinutes: serializer.fromJson<int>(json['targetWakeMinutes']),
      goalWakeMinutes: serializer.fromJson<int>(json['goalWakeMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'targetWakeMinutes': serializer.toJson<int>(targetWakeMinutes),
      'goalWakeMinutes': serializer.toJson<int>(goalWakeMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SleepTarget copyWith({
    int? id,
    DateTime? targetDate,
    int? targetWakeMinutes,
    int? goalWakeMinutes,
    DateTime? createdAt,
  }) => SleepTarget(
    id: id ?? this.id,
    targetDate: targetDate ?? this.targetDate,
    targetWakeMinutes: targetWakeMinutes ?? this.targetWakeMinutes,
    goalWakeMinutes: goalWakeMinutes ?? this.goalWakeMinutes,
    createdAt: createdAt ?? this.createdAt,
  );
  SleepTarget copyWithCompanion(SleepTargetsCompanion data) {
    return SleepTarget(
      id: data.id.present ? data.id.value : this.id,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      targetWakeMinutes: data.targetWakeMinutes.present
          ? data.targetWakeMinutes.value
          : this.targetWakeMinutes,
      goalWakeMinutes: data.goalWakeMinutes.present
          ? data.goalWakeMinutes.value
          : this.goalWakeMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepTarget(')
          ..write('id: $id, ')
          ..write('targetDate: $targetDate, ')
          ..write('targetWakeMinutes: $targetWakeMinutes, ')
          ..write('goalWakeMinutes: $goalWakeMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetDate,
    targetWakeMinutes,
    goalWakeMinutes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepTarget &&
          other.id == this.id &&
          other.targetDate == this.targetDate &&
          other.targetWakeMinutes == this.targetWakeMinutes &&
          other.goalWakeMinutes == this.goalWakeMinutes &&
          other.createdAt == this.createdAt);
}

class SleepTargetsCompanion extends UpdateCompanion<SleepTarget> {
  final Value<int> id;
  final Value<DateTime> targetDate;
  final Value<int> targetWakeMinutes;
  final Value<int> goalWakeMinutes;
  final Value<DateTime> createdAt;
  const SleepTargetsCompanion({
    this.id = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.targetWakeMinutes = const Value.absent(),
    this.goalWakeMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SleepTargetsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime targetDate,
    required int targetWakeMinutes,
    required int goalWakeMinutes,
    this.createdAt = const Value.absent(),
  }) : targetDate = Value(targetDate),
       targetWakeMinutes = Value(targetWakeMinutes),
       goalWakeMinutes = Value(goalWakeMinutes);
  static Insertable<SleepTarget> custom({
    Expression<int>? id,
    Expression<DateTime>? targetDate,
    Expression<int>? targetWakeMinutes,
    Expression<int>? goalWakeMinutes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetDate != null) 'target_date': targetDate,
      if (targetWakeMinutes != null) 'target_wake_minutes': targetWakeMinutes,
      if (goalWakeMinutes != null) 'goal_wake_minutes': goalWakeMinutes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SleepTargetsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? targetDate,
    Value<int>? targetWakeMinutes,
    Value<int>? goalWakeMinutes,
    Value<DateTime>? createdAt,
  }) {
    return SleepTargetsCompanion(
      id: id ?? this.id,
      targetDate: targetDate ?? this.targetDate,
      targetWakeMinutes: targetWakeMinutes ?? this.targetWakeMinutes,
      goalWakeMinutes: goalWakeMinutes ?? this.goalWakeMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (targetWakeMinutes.present) {
      map['target_wake_minutes'] = Variable<int>(targetWakeMinutes.value);
    }
    if (goalWakeMinutes.present) {
      map['goal_wake_minutes'] = Variable<int>(goalWakeMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepTargetsCompanion(')
          ..write('id: $id, ')
          ..write('targetDate: $targetDate, ')
          ..write('targetWakeMinutes: $targetWakeMinutes, ')
          ..write('goalWakeMinutes: $goalWakeMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShiftNotesTable extends ShiftNotes
    with TableInfo<$ShiftNotesTable, ShiftNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleMeta = const VerificationMeta('rule');
  @override
  late final GeneratedColumn<String> rule = GeneratedColumn<String>(
    'rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shiftMinutesMeta = const VerificationMeta(
    'shiftMinutes',
  );
  @override
  late final GeneratedColumn<int> shiftMinutes = GeneratedColumn<int>(
    'shift_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deltaOversleepMinutesMeta =
      const VerificationMeta('deltaOversleepMinutes');
  @override
  late final GeneratedColumn<int> deltaOversleepMinutes = GeneratedColumn<int>(
    'delta_oversleep_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetDate,
    rule,
    shiftMinutes,
    deltaOversleepMinutes,
    note,
    tagsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shift_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_targetDateMeta);
    }
    if (data.containsKey('rule')) {
      context.handle(
        _ruleMeta,
        rule.isAcceptableOrUnknown(data['rule']!, _ruleMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleMeta);
    }
    if (data.containsKey('shift_minutes')) {
      context.handle(
        _shiftMinutesMeta,
        shiftMinutes.isAcceptableOrUnknown(
          data['shift_minutes']!,
          _shiftMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shiftMinutesMeta);
    }
    if (data.containsKey('delta_oversleep_minutes')) {
      context.handle(
        _deltaOversleepMinutesMeta,
        deltaOversleepMinutes.isAcceptableOrUnknown(
          data['delta_oversleep_minutes']!,
          _deltaOversleepMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deltaOversleepMinutesMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      )!,
      rule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule'],
      )!,
      shiftMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shift_minutes'],
      )!,
      deltaOversleepMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta_oversleep_minutes'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ShiftNotesTable createAlias(String alias) {
    return $ShiftNotesTable(attachedDatabase, alias);
  }
}

class ShiftNote extends DataClass implements Insertable<ShiftNote> {
  final int id;
  final DateTime targetDate;
  final String rule;
  final int shiftMinutes;
  final int deltaOversleepMinutes;
  final String note;
  final String tagsJson;
  final DateTime createdAt;
  const ShiftNote({
    required this.id,
    required this.targetDate,
    required this.rule,
    required this.shiftMinutes,
    required this.deltaOversleepMinutes,
    required this.note,
    required this.tagsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_date'] = Variable<DateTime>(targetDate);
    map['rule'] = Variable<String>(rule);
    map['shift_minutes'] = Variable<int>(shiftMinutes);
    map['delta_oversleep_minutes'] = Variable<int>(deltaOversleepMinutes);
    map['note'] = Variable<String>(note);
    map['tags_json'] = Variable<String>(tagsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ShiftNotesCompanion toCompanion(bool nullToAbsent) {
    return ShiftNotesCompanion(
      id: Value(id),
      targetDate: Value(targetDate),
      rule: Value(rule),
      shiftMinutes: Value(shiftMinutes),
      deltaOversleepMinutes: Value(deltaOversleepMinutes),
      note: Value(note),
      tagsJson: Value(tagsJson),
      createdAt: Value(createdAt),
    );
  }

  factory ShiftNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftNote(
      id: serializer.fromJson<int>(json['id']),
      targetDate: serializer.fromJson<DateTime>(json['targetDate']),
      rule: serializer.fromJson<String>(json['rule']),
      shiftMinutes: serializer.fromJson<int>(json['shiftMinutes']),
      deltaOversleepMinutes: serializer.fromJson<int>(
        json['deltaOversleepMinutes'],
      ),
      note: serializer.fromJson<String>(json['note']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetDate': serializer.toJson<DateTime>(targetDate),
      'rule': serializer.toJson<String>(rule),
      'shiftMinutes': serializer.toJson<int>(shiftMinutes),
      'deltaOversleepMinutes': serializer.toJson<int>(deltaOversleepMinutes),
      'note': serializer.toJson<String>(note),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ShiftNote copyWith({
    int? id,
    DateTime? targetDate,
    String? rule,
    int? shiftMinutes,
    int? deltaOversleepMinutes,
    String? note,
    String? tagsJson,
    DateTime? createdAt,
  }) => ShiftNote(
    id: id ?? this.id,
    targetDate: targetDate ?? this.targetDate,
    rule: rule ?? this.rule,
    shiftMinutes: shiftMinutes ?? this.shiftMinutes,
    deltaOversleepMinutes: deltaOversleepMinutes ?? this.deltaOversleepMinutes,
    note: note ?? this.note,
    tagsJson: tagsJson ?? this.tagsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  ShiftNote copyWithCompanion(ShiftNotesCompanion data) {
    return ShiftNote(
      id: data.id.present ? data.id.value : this.id,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      rule: data.rule.present ? data.rule.value : this.rule,
      shiftMinutes: data.shiftMinutes.present
          ? data.shiftMinutes.value
          : this.shiftMinutes,
      deltaOversleepMinutes: data.deltaOversleepMinutes.present
          ? data.deltaOversleepMinutes.value
          : this.deltaOversleepMinutes,
      note: data.note.present ? data.note.value : this.note,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftNote(')
          ..write('id: $id, ')
          ..write('targetDate: $targetDate, ')
          ..write('rule: $rule, ')
          ..write('shiftMinutes: $shiftMinutes, ')
          ..write('deltaOversleepMinutes: $deltaOversleepMinutes, ')
          ..write('note: $note, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetDate,
    rule,
    shiftMinutes,
    deltaOversleepMinutes,
    note,
    tagsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftNote &&
          other.id == this.id &&
          other.targetDate == this.targetDate &&
          other.rule == this.rule &&
          other.shiftMinutes == this.shiftMinutes &&
          other.deltaOversleepMinutes == this.deltaOversleepMinutes &&
          other.note == this.note &&
          other.tagsJson == this.tagsJson &&
          other.createdAt == this.createdAt);
}

class ShiftNotesCompanion extends UpdateCompanion<ShiftNote> {
  final Value<int> id;
  final Value<DateTime> targetDate;
  final Value<String> rule;
  final Value<int> shiftMinutes;
  final Value<int> deltaOversleepMinutes;
  final Value<String> note;
  final Value<String> tagsJson;
  final Value<DateTime> createdAt;
  const ShiftNotesCompanion({
    this.id = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.rule = const Value.absent(),
    this.shiftMinutes = const Value.absent(),
    this.deltaOversleepMinutes = const Value.absent(),
    this.note = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ShiftNotesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime targetDate,
    required String rule,
    required int shiftMinutes,
    required int deltaOversleepMinutes,
    required String note,
    required String tagsJson,
    this.createdAt = const Value.absent(),
  }) : targetDate = Value(targetDate),
       rule = Value(rule),
       shiftMinutes = Value(shiftMinutes),
       deltaOversleepMinutes = Value(deltaOversleepMinutes),
       note = Value(note),
       tagsJson = Value(tagsJson);
  static Insertable<ShiftNote> custom({
    Expression<int>? id,
    Expression<DateTime>? targetDate,
    Expression<String>? rule,
    Expression<int>? shiftMinutes,
    Expression<int>? deltaOversleepMinutes,
    Expression<String>? note,
    Expression<String>? tagsJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetDate != null) 'target_date': targetDate,
      if (rule != null) 'rule': rule,
      if (shiftMinutes != null) 'shift_minutes': shiftMinutes,
      if (deltaOversleepMinutes != null)
        'delta_oversleep_minutes': deltaOversleepMinutes,
      if (note != null) 'note': note,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ShiftNotesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? targetDate,
    Value<String>? rule,
    Value<int>? shiftMinutes,
    Value<int>? deltaOversleepMinutes,
    Value<String>? note,
    Value<String>? tagsJson,
    Value<DateTime>? createdAt,
  }) {
    return ShiftNotesCompanion(
      id: id ?? this.id,
      targetDate: targetDate ?? this.targetDate,
      rule: rule ?? this.rule,
      shiftMinutes: shiftMinutes ?? this.shiftMinutes,
      deltaOversleepMinutes:
          deltaOversleepMinutes ?? this.deltaOversleepMinutes,
      note: note ?? this.note,
      tagsJson: tagsJson ?? this.tagsJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (rule.present) {
      map['rule'] = Variable<String>(rule.value);
    }
    if (shiftMinutes.present) {
      map['shift_minutes'] = Variable<int>(shiftMinutes.value);
    }
    if (deltaOversleepMinutes.present) {
      map['delta_oversleep_minutes'] = Variable<int>(
        deltaOversleepMinutes.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftNotesCompanion(')
          ..write('id: $id, ')
          ..write('targetDate: $targetDate, ')
          ..write('rule: $rule, ')
          ..write('shiftMinutes: $shiftMinutes, ')
          ..write('deltaOversleepMinutes: $deltaOversleepMinutes, ')
          ..write('note: $note, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SleepHistorySessionsTable extends SleepHistorySessions
    with TableInfo<$SleepHistorySessionsTable, SleepHistorySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepHistorySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stagesJsonMeta = const VerificationMeta(
    'stagesJson',
  );
  @override
  late final GeneratedColumn<String> stagesJson = GeneratedColumn<String>(
    'stages_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    durationMinutes,
    stagesJson,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_history_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepHistorySession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('stages_json')) {
      context.handle(
        _stagesJsonMeta,
        stagesJson.isAcceptableOrUnknown(data['stages_json']!, _stagesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stagesJsonMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepHistorySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepHistorySession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      stagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stages_json'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $SleepHistorySessionsTable createAlias(String alias) {
    return $SleepHistorySessionsTable(attachedDatabase, alias);
  }
}

class SleepHistorySession extends DataClass
    implements Insertable<SleepHistorySession> {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String stagesJson;
  final DateTime syncedAt;
  const SleepHistorySession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.stagesJson,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['stages_json'] = Variable<String>(stagesJson);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  SleepHistorySessionsCompanion toCompanion(bool nullToAbsent) {
    return SleepHistorySessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: Value(endTime),
      durationMinutes: Value(durationMinutes),
      stagesJson: Value(stagesJson),
      syncedAt: Value(syncedAt),
    );
  }

  factory SleepHistorySession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepHistorySession(
      id: serializer.fromJson<String>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      stagesJson: serializer.fromJson<String>(json['stagesJson']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'stagesJson': serializer.toJson<String>(stagesJson),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  SleepHistorySession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? stagesJson,
    DateTime? syncedAt,
  }) => SleepHistorySession(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    stagesJson: stagesJson ?? this.stagesJson,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  SleepHistorySession copyWithCompanion(SleepHistorySessionsCompanion data) {
    return SleepHistorySession(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      stagesJson: data.stagesJson.present
          ? data.stagesJson.value
          : this.stagesJson,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepHistorySession(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    endTime,
    durationMinutes,
    stagesJson,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepHistorySession &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationMinutes == this.durationMinutes &&
          other.stagesJson == this.stagesJson &&
          other.syncedAt == this.syncedAt);
}

class SleepHistorySessionsCompanion
    extends UpdateCompanion<SleepHistorySession> {
  final Value<String> id;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<int> durationMinutes;
  final Value<String> stagesJson;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const SleepHistorySessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.stagesJson = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepHistorySessionsCompanion.insert({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required String stagesJson,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startTime = Value(startTime),
       endTime = Value(endTime),
       durationMinutes = Value(durationMinutes),
       stagesJson = Value(stagesJson);
  static Insertable<SleepHistorySession> custom({
    Expression<String>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationMinutes,
    Expression<String>? stagesJson,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (stagesJson != null) 'stages_json': stagesJson,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepHistorySessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
    Value<int>? durationMinutes,
    Value<String>? stagesJson,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return SleepHistorySessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      stagesJson: stagesJson ?? this.stagesJson,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (stagesJson.present) {
      map['stages_json'] = Variable<String>(stagesJson.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepHistorySessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetectorSettingsTable extends DetectorSettings
    with TableInfo<$DetectorSettingsTable, DetectorSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectorSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wakeWindowMinutesMeta = const VerificationMeta(
    'wakeWindowMinutes',
  );
  @override
  late final GeneratedColumn<int> wakeWindowMinutes = GeneratedColumn<int>(
    'wake_window_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _quarantineMinutesMeta = const VerificationMeta(
    'quarantineMinutes',
  );
  @override
  late final GeneratedColumn<int> quarantineMinutes = GeneratedColumn<int>(
    'quarantine_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _motionVarianceThresholdMeta =
      const VerificationMeta('motionVarianceThreshold');
  @override
  late final GeneratedColumn<double> motionVarianceThreshold =
      GeneratedColumn<double>(
        'motion_variance_threshold',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.15),
      );
  static const VerificationMeta _hrSpikeRatioThresholdMeta =
      const VerificationMeta('hrSpikeRatioThreshold');
  @override
  late final GeneratedColumn<double> hrSpikeRatioThreshold =
      GeneratedColumn<double>(
        'hr_spike_ratio_threshold',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.08),
      );
  static const VerificationMeta _consecutiveEpochsRequiredMeta =
      const VerificationMeta('consecutiveEpochsRequired');
  @override
  late final GeneratedColumn<int> consecutiveEpochsRequired =
      GeneratedColumn<int>(
        'consecutive_epochs_required',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(2),
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    wakeWindowMinutes,
    quarantineMinutes,
    motionVarianceThreshold,
    hrSpikeRatioThreshold,
    consecutiveEpochsRequired,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detector_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<DetectorSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wake_window_minutes')) {
      context.handle(
        _wakeWindowMinutesMeta,
        wakeWindowMinutes.isAcceptableOrUnknown(
          data['wake_window_minutes']!,
          _wakeWindowMinutesMeta,
        ),
      );
    }
    if (data.containsKey('quarantine_minutes')) {
      context.handle(
        _quarantineMinutesMeta,
        quarantineMinutes.isAcceptableOrUnknown(
          data['quarantine_minutes']!,
          _quarantineMinutesMeta,
        ),
      );
    }
    if (data.containsKey('motion_variance_threshold')) {
      context.handle(
        _motionVarianceThresholdMeta,
        motionVarianceThreshold.isAcceptableOrUnknown(
          data['motion_variance_threshold']!,
          _motionVarianceThresholdMeta,
        ),
      );
    }
    if (data.containsKey('hr_spike_ratio_threshold')) {
      context.handle(
        _hrSpikeRatioThresholdMeta,
        hrSpikeRatioThreshold.isAcceptableOrUnknown(
          data['hr_spike_ratio_threshold']!,
          _hrSpikeRatioThresholdMeta,
        ),
      );
    }
    if (data.containsKey('consecutive_epochs_required')) {
      context.handle(
        _consecutiveEpochsRequiredMeta,
        consecutiveEpochsRequired.isAcceptableOrUnknown(
          data['consecutive_epochs_required']!,
          _consecutiveEpochsRequiredMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DetectorSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DetectorSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wakeWindowMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wake_window_minutes'],
      )!,
      quarantineMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quarantine_minutes'],
      )!,
      motionVarianceThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}motion_variance_threshold'],
      )!,
      hrSpikeRatioThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hr_spike_ratio_threshold'],
      )!,
      consecutiveEpochsRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consecutive_epochs_required'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DetectorSettingsTable createAlias(String alias) {
    return $DetectorSettingsTable(attachedDatabase, alias);
  }
}

class DetectorSetting extends DataClass implements Insertable<DetectorSetting> {
  final int id;
  final int wakeWindowMinutes;
  final int quarantineMinutes;
  final double motionVarianceThreshold;
  final double hrSpikeRatioThreshold;
  final int consecutiveEpochsRequired;
  final DateTime updatedAt;
  const DetectorSetting({
    required this.id,
    required this.wakeWindowMinutes,
    required this.quarantineMinutes,
    required this.motionVarianceThreshold,
    required this.hrSpikeRatioThreshold,
    required this.consecutiveEpochsRequired,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wake_window_minutes'] = Variable<int>(wakeWindowMinutes);
    map['quarantine_minutes'] = Variable<int>(quarantineMinutes);
    map['motion_variance_threshold'] = Variable<double>(
      motionVarianceThreshold,
    );
    map['hr_spike_ratio_threshold'] = Variable<double>(hrSpikeRatioThreshold);
    map['consecutive_epochs_required'] = Variable<int>(
      consecutiveEpochsRequired,
    );
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DetectorSettingsCompanion toCompanion(bool nullToAbsent) {
    return DetectorSettingsCompanion(
      id: Value(id),
      wakeWindowMinutes: Value(wakeWindowMinutes),
      quarantineMinutes: Value(quarantineMinutes),
      motionVarianceThreshold: Value(motionVarianceThreshold),
      hrSpikeRatioThreshold: Value(hrSpikeRatioThreshold),
      consecutiveEpochsRequired: Value(consecutiveEpochsRequired),
      updatedAt: Value(updatedAt),
    );
  }

  factory DetectorSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DetectorSetting(
      id: serializer.fromJson<int>(json['id']),
      wakeWindowMinutes: serializer.fromJson<int>(json['wakeWindowMinutes']),
      quarantineMinutes: serializer.fromJson<int>(json['quarantineMinutes']),
      motionVarianceThreshold: serializer.fromJson<double>(
        json['motionVarianceThreshold'],
      ),
      hrSpikeRatioThreshold: serializer.fromJson<double>(
        json['hrSpikeRatioThreshold'],
      ),
      consecutiveEpochsRequired: serializer.fromJson<int>(
        json['consecutiveEpochsRequired'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wakeWindowMinutes': serializer.toJson<int>(wakeWindowMinutes),
      'quarantineMinutes': serializer.toJson<int>(quarantineMinutes),
      'motionVarianceThreshold': serializer.toJson<double>(
        motionVarianceThreshold,
      ),
      'hrSpikeRatioThreshold': serializer.toJson<double>(hrSpikeRatioThreshold),
      'consecutiveEpochsRequired': serializer.toJson<int>(
        consecutiveEpochsRequired,
      ),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DetectorSetting copyWith({
    int? id,
    int? wakeWindowMinutes,
    int? quarantineMinutes,
    double? motionVarianceThreshold,
    double? hrSpikeRatioThreshold,
    int? consecutiveEpochsRequired,
    DateTime? updatedAt,
  }) => DetectorSetting(
    id: id ?? this.id,
    wakeWindowMinutes: wakeWindowMinutes ?? this.wakeWindowMinutes,
    quarantineMinutes: quarantineMinutes ?? this.quarantineMinutes,
    motionVarianceThreshold:
        motionVarianceThreshold ?? this.motionVarianceThreshold,
    hrSpikeRatioThreshold: hrSpikeRatioThreshold ?? this.hrSpikeRatioThreshold,
    consecutiveEpochsRequired:
        consecutiveEpochsRequired ?? this.consecutiveEpochsRequired,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DetectorSetting copyWithCompanion(DetectorSettingsCompanion data) {
    return DetectorSetting(
      id: data.id.present ? data.id.value : this.id,
      wakeWindowMinutes: data.wakeWindowMinutes.present
          ? data.wakeWindowMinutes.value
          : this.wakeWindowMinutes,
      quarantineMinutes: data.quarantineMinutes.present
          ? data.quarantineMinutes.value
          : this.quarantineMinutes,
      motionVarianceThreshold: data.motionVarianceThreshold.present
          ? data.motionVarianceThreshold.value
          : this.motionVarianceThreshold,
      hrSpikeRatioThreshold: data.hrSpikeRatioThreshold.present
          ? data.hrSpikeRatioThreshold.value
          : this.hrSpikeRatioThreshold,
      consecutiveEpochsRequired: data.consecutiveEpochsRequired.present
          ? data.consecutiveEpochsRequired.value
          : this.consecutiveEpochsRequired,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DetectorSetting(')
          ..write('id: $id, ')
          ..write('wakeWindowMinutes: $wakeWindowMinutes, ')
          ..write('quarantineMinutes: $quarantineMinutes, ')
          ..write('motionVarianceThreshold: $motionVarianceThreshold, ')
          ..write('hrSpikeRatioThreshold: $hrSpikeRatioThreshold, ')
          ..write('consecutiveEpochsRequired: $consecutiveEpochsRequired, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wakeWindowMinutes,
    quarantineMinutes,
    motionVarianceThreshold,
    hrSpikeRatioThreshold,
    consecutiveEpochsRequired,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DetectorSetting &&
          other.id == this.id &&
          other.wakeWindowMinutes == this.wakeWindowMinutes &&
          other.quarantineMinutes == this.quarantineMinutes &&
          other.motionVarianceThreshold == this.motionVarianceThreshold &&
          other.hrSpikeRatioThreshold == this.hrSpikeRatioThreshold &&
          other.consecutiveEpochsRequired == this.consecutiveEpochsRequired &&
          other.updatedAt == this.updatedAt);
}

class DetectorSettingsCompanion extends UpdateCompanion<DetectorSetting> {
  final Value<int> id;
  final Value<int> wakeWindowMinutes;
  final Value<int> quarantineMinutes;
  final Value<double> motionVarianceThreshold;
  final Value<double> hrSpikeRatioThreshold;
  final Value<int> consecutiveEpochsRequired;
  final Value<DateTime> updatedAt;
  const DetectorSettingsCompanion({
    this.id = const Value.absent(),
    this.wakeWindowMinutes = const Value.absent(),
    this.quarantineMinutes = const Value.absent(),
    this.motionVarianceThreshold = const Value.absent(),
    this.hrSpikeRatioThreshold = const Value.absent(),
    this.consecutiveEpochsRequired = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DetectorSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.wakeWindowMinutes = const Value.absent(),
    this.quarantineMinutes = const Value.absent(),
    this.motionVarianceThreshold = const Value.absent(),
    this.hrSpikeRatioThreshold = const Value.absent(),
    this.consecutiveEpochsRequired = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<DetectorSetting> custom({
    Expression<int>? id,
    Expression<int>? wakeWindowMinutes,
    Expression<int>? quarantineMinutes,
    Expression<double>? motionVarianceThreshold,
    Expression<double>? hrSpikeRatioThreshold,
    Expression<int>? consecutiveEpochsRequired,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wakeWindowMinutes != null) 'wake_window_minutes': wakeWindowMinutes,
      if (quarantineMinutes != null) 'quarantine_minutes': quarantineMinutes,
      if (motionVarianceThreshold != null)
        'motion_variance_threshold': motionVarianceThreshold,
      if (hrSpikeRatioThreshold != null)
        'hr_spike_ratio_threshold': hrSpikeRatioThreshold,
      if (consecutiveEpochsRequired != null)
        'consecutive_epochs_required': consecutiveEpochsRequired,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DetectorSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? wakeWindowMinutes,
    Value<int>? quarantineMinutes,
    Value<double>? motionVarianceThreshold,
    Value<double>? hrSpikeRatioThreshold,
    Value<int>? consecutiveEpochsRequired,
    Value<DateTime>? updatedAt,
  }) {
    return DetectorSettingsCompanion(
      id: id ?? this.id,
      wakeWindowMinutes: wakeWindowMinutes ?? this.wakeWindowMinutes,
      quarantineMinutes: quarantineMinutes ?? this.quarantineMinutes,
      motionVarianceThreshold:
          motionVarianceThreshold ?? this.motionVarianceThreshold,
      hrSpikeRatioThreshold:
          hrSpikeRatioThreshold ?? this.hrSpikeRatioThreshold,
      consecutiveEpochsRequired:
          consecutiveEpochsRequired ?? this.consecutiveEpochsRequired,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wakeWindowMinutes.present) {
      map['wake_window_minutes'] = Variable<int>(wakeWindowMinutes.value);
    }
    if (quarantineMinutes.present) {
      map['quarantine_minutes'] = Variable<int>(quarantineMinutes.value);
    }
    if (motionVarianceThreshold.present) {
      map['motion_variance_threshold'] = Variable<double>(
        motionVarianceThreshold.value,
      );
    }
    if (hrSpikeRatioThreshold.present) {
      map['hr_spike_ratio_threshold'] = Variable<double>(
        hrSpikeRatioThreshold.value,
      );
    }
    if (consecutiveEpochsRequired.present) {
      map['consecutive_epochs_required'] = Variable<int>(
        consecutiveEpochsRequired.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectorSettingsCompanion(')
          ..write('id: $id, ')
          ..write('wakeWindowMinutes: $wakeWindowMinutes, ')
          ..write('quarantineMinutes: $quarantineMinutes, ')
          ..write('motionVarianceThreshold: $motionVarianceThreshold, ')
          ..write('hrSpikeRatioThreshold: $hrSpikeRatioThreshold, ')
          ..write('consecutiveEpochsRequired: $consecutiveEpochsRequired, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SleepTargetsTable sleepTargets = $SleepTargetsTable(this);
  late final $ShiftNotesTable shiftNotes = $ShiftNotesTable(this);
  late final $SleepHistorySessionsTable sleepHistorySessions =
      $SleepHistorySessionsTable(this);
  late final $DetectorSettingsTable detectorSettings = $DetectorSettingsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sleepTargets,
    shiftNotes,
    sleepHistorySessions,
    detectorSettings,
  ];
}

typedef $$SleepTargetsTableCreateCompanionBuilder =
    SleepTargetsCompanion Function({
      Value<int> id,
      required DateTime targetDate,
      required int targetWakeMinutes,
      required int goalWakeMinutes,
      Value<DateTime> createdAt,
    });
typedef $$SleepTargetsTableUpdateCompanionBuilder =
    SleepTargetsCompanion Function({
      Value<int> id,
      Value<DateTime> targetDate,
      Value<int> targetWakeMinutes,
      Value<int> goalWakeMinutes,
      Value<DateTime> createdAt,
    });

class $$SleepTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepTargetsTable> {
  $$SleepTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetWakeMinutes => $composableBuilder(
    column: $table.targetWakeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goalWakeMinutes => $composableBuilder(
    column: $table.goalWakeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepTargetsTable> {
  $$SleepTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetWakeMinutes => $composableBuilder(
    column: $table.targetWakeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goalWakeMinutes => $composableBuilder(
    column: $table.goalWakeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepTargetsTable> {
  $$SleepTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetWakeMinutes => $composableBuilder(
    column: $table.targetWakeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goalWakeMinutes => $composableBuilder(
    column: $table.goalWakeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SleepTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepTargetsTable,
          SleepTarget,
          $$SleepTargetsTableFilterComposer,
          $$SleepTargetsTableOrderingComposer,
          $$SleepTargetsTableAnnotationComposer,
          $$SleepTargetsTableCreateCompanionBuilder,
          $$SleepTargetsTableUpdateCompanionBuilder,
          (
            SleepTarget,
            BaseReferences<_$AppDatabase, $SleepTargetsTable, SleepTarget>,
          ),
          SleepTarget,
          PrefetchHooks Function()
        > {
  $$SleepTargetsTableTableManager(_$AppDatabase db, $SleepTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> targetDate = const Value.absent(),
                Value<int> targetWakeMinutes = const Value.absent(),
                Value<int> goalWakeMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SleepTargetsCompanion(
                id: id,
                targetDate: targetDate,
                targetWakeMinutes: targetWakeMinutes,
                goalWakeMinutes: goalWakeMinutes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime targetDate,
                required int targetWakeMinutes,
                required int goalWakeMinutes,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SleepTargetsCompanion.insert(
                id: id,
                targetDate: targetDate,
                targetWakeMinutes: targetWakeMinutes,
                goalWakeMinutes: goalWakeMinutes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepTargetsTable, SleepTarget>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SleepTargetsTable,
                    SleepTarget
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepTargetsTable,
      SleepTarget,
      $$SleepTargetsTableFilterComposer,
      $$SleepTargetsTableOrderingComposer,
      $$SleepTargetsTableAnnotationComposer,
      $$SleepTargetsTableCreateCompanionBuilder,
      $$SleepTargetsTableUpdateCompanionBuilder,
      (
        SleepTarget,
        BaseReferences<_$AppDatabase, $SleepTargetsTable, SleepTarget>,
      ),
      SleepTarget,
      PrefetchHooks Function()
    >;
typedef $$ShiftNotesTableCreateCompanionBuilder = ShiftNotesCompanion Function({
  Value<int> id,
  required DateTime targetDate,
  required String rule,
  required int shiftMinutes,
  required int deltaOversleepMinutes,
  required String note,
  required String tagsJson,
  Value<DateTime> createdAt,
});
typedef $$ShiftNotesTableUpdateCompanionBuilder = ShiftNotesCompanion Function({
  Value<int> id,
  Value<DateTime> targetDate,
  Value<String> rule,
  Value<int> shiftMinutes,
  Value<int> deltaOversleepMinutes,
  Value<String> note,
  Value<String> tagsJson,
  Value<DateTime> createdAt,
});

class $$ShiftNotesTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftNotesTable> {
  $$ShiftNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shiftMinutes => $composableBuilder(
    column: $table.shiftMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deltaOversleepMinutes => $composableBuilder(
    column: $table.deltaOversleepMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShiftNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftNotesTable> {
  $$ShiftNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rule => $composableBuilder(
    column: $table.rule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shiftMinutes => $composableBuilder(
    column: $table.shiftMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deltaOversleepMinutes => $composableBuilder(
    column: $table.deltaOversleepMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShiftNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftNotesTable> {
  $$ShiftNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rule =>
      $composableBuilder(column: $table.rule, builder: (column) => column);

  GeneratedColumn<int> get shiftMinutes => $composableBuilder(
    column: $table.shiftMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deltaOversleepMinutes => $composableBuilder(
    column: $table.deltaOversleepMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ShiftNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftNotesTable,
          ShiftNote,
          $$ShiftNotesTableFilterComposer,
          $$ShiftNotesTableOrderingComposer,
          $$ShiftNotesTableAnnotationComposer,
          $$ShiftNotesTableCreateCompanionBuilder,
          $$ShiftNotesTableUpdateCompanionBuilder,
          (
            ShiftNote,
            BaseReferences<_$AppDatabase, $ShiftNotesTable, ShiftNote>,
          ),
          ShiftNote,
          PrefetchHooks Function()
        > {
  $$ShiftNotesTableTableManager(_$AppDatabase db, $ShiftNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> targetDate = const Value.absent(),
                Value<String> rule = const Value.absent(),
                Value<int> shiftMinutes = const Value.absent(),
                Value<int> deltaOversleepMinutes = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShiftNotesCompanion(
                id: id,
                targetDate: targetDate,
                rule: rule,
                shiftMinutes: shiftMinutes,
                deltaOversleepMinutes: deltaOversleepMinutes,
                note: note,
                tagsJson: tagsJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime targetDate,
                required String rule,
                required int shiftMinutes,
                required int deltaOversleepMinutes,
                required String note,
                required String tagsJson,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ShiftNotesCompanion.insert(
                id: id,
                targetDate: targetDate,
                rule: rule,
                shiftMinutes: shiftMinutes,
                deltaOversleepMinutes: deltaOversleepMinutes,
                note: note,
                tagsJson: tagsJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShiftNotesTable, ShiftNote>(table),
                  BaseReferences<_$AppDatabase, $ShiftNotesTable, ShiftNote>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShiftNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftNotesTable,
      ShiftNote,
      $$ShiftNotesTableFilterComposer,
      $$ShiftNotesTableOrderingComposer,
      $$ShiftNotesTableAnnotationComposer,
      $$ShiftNotesTableCreateCompanionBuilder,
      $$ShiftNotesTableUpdateCompanionBuilder,
      (ShiftNote, BaseReferences<_$AppDatabase, $ShiftNotesTable, ShiftNote>),
      ShiftNote,
      PrefetchHooks Function()
    >;
typedef $$SleepHistorySessionsTableCreateCompanionBuilder =
    SleepHistorySessionsCompanion Function({
      required String id,
      required DateTime startTime,
      required DateTime endTime,
      required int durationMinutes,
      required String stagesJson,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });
typedef $$SleepHistorySessionsTableUpdateCompanionBuilder =
    SleepHistorySessionsCompanion Function({
      Value<String> id,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
      Value<int> durationMinutes,
      Value<String> stagesJson,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$SleepHistorySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepHistorySessionsTable> {
  $$SleepHistorySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepHistorySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepHistorySessionsTable> {
  $$SleepHistorySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepHistorySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepHistorySessionsTable> {
  $$SleepHistorySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stagesJson => $composableBuilder(
    column: $table.stagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SleepHistorySessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepHistorySessionsTable,
          SleepHistorySession,
          $$SleepHistorySessionsTableFilterComposer,
          $$SleepHistorySessionsTableOrderingComposer,
          $$SleepHistorySessionsTableAnnotationComposer,
          $$SleepHistorySessionsTableCreateCompanionBuilder,
          $$SleepHistorySessionsTableUpdateCompanionBuilder,
          (
            SleepHistorySession,
            BaseReferences<
              _$AppDatabase,
              $SleepHistorySessionsTable,
              SleepHistorySession
            >,
          ),
          SleepHistorySession,
          PrefetchHooks Function()
        > {
  $$SleepHistorySessionsTableTableManager(
    _$AppDatabase db,
    $SleepHistorySessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepHistorySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepHistorySessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SleepHistorySessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<String> stagesJson = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SleepHistorySessionsCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
                stagesJson: stagesJson,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startTime,
                required DateTime endTime,
                required int durationMinutes,
                required String stagesJson,
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SleepHistorySessionsCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                durationMinutes: durationMinutes,
                stagesJson: stagesJson,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepHistorySessionsTable, SleepHistorySession>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $SleepHistorySessionsTable,
                    SleepHistorySession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepHistorySessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepHistorySessionsTable,
      SleepHistorySession,
      $$SleepHistorySessionsTableFilterComposer,
      $$SleepHistorySessionsTableOrderingComposer,
      $$SleepHistorySessionsTableAnnotationComposer,
      $$SleepHistorySessionsTableCreateCompanionBuilder,
      $$SleepHistorySessionsTableUpdateCompanionBuilder,
      (
        SleepHistorySession,
        BaseReferences<
          _$AppDatabase,
          $SleepHistorySessionsTable,
          SleepHistorySession
        >,
      ),
      SleepHistorySession,
      PrefetchHooks Function()
    >;
typedef $$DetectorSettingsTableCreateCompanionBuilder =
    DetectorSettingsCompanion Function({
      Value<int> id,
      Value<int> wakeWindowMinutes,
      Value<int> quarantineMinutes,
      Value<double> motionVarianceThreshold,
      Value<double> hrSpikeRatioThreshold,
      Value<int> consecutiveEpochsRequired,
      Value<DateTime> updatedAt,
    });
typedef $$DetectorSettingsTableUpdateCompanionBuilder =
    DetectorSettingsCompanion Function({
      Value<int> id,
      Value<int> wakeWindowMinutes,
      Value<int> quarantineMinutes,
      Value<double> motionVarianceThreshold,
      Value<double> hrSpikeRatioThreshold,
      Value<int> consecutiveEpochsRequired,
      Value<DateTime> updatedAt,
    });

class $$DetectorSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DetectorSettingsTable> {
  $$DetectorSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wakeWindowMinutes => $composableBuilder(
    column: $table.wakeWindowMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quarantineMinutes => $composableBuilder(
    column: $table.quarantineMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get motionVarianceThreshold => $composableBuilder(
    column: $table.motionVarianceThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrSpikeRatioThreshold => $composableBuilder(
    column: $table.hrSpikeRatioThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consecutiveEpochsRequired => $composableBuilder(
    column: $table.consecutiveEpochsRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DetectorSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectorSettingsTable> {
  $$DetectorSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wakeWindowMinutes => $composableBuilder(
    column: $table.wakeWindowMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quarantineMinutes => $composableBuilder(
    column: $table.quarantineMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get motionVarianceThreshold => $composableBuilder(
    column: $table.motionVarianceThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrSpikeRatioThreshold => $composableBuilder(
    column: $table.hrSpikeRatioThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consecutiveEpochsRequired => $composableBuilder(
    column: $table.consecutiveEpochsRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DetectorSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectorSettingsTable> {
  $$DetectorSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get wakeWindowMinutes => $composableBuilder(
    column: $table.wakeWindowMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quarantineMinutes => $composableBuilder(
    column: $table.quarantineMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get motionVarianceThreshold => $composableBuilder(
    column: $table.motionVarianceThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrSpikeRatioThreshold => $composableBuilder(
    column: $table.hrSpikeRatioThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consecutiveEpochsRequired => $composableBuilder(
    column: $table.consecutiveEpochsRequired,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DetectorSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetectorSettingsTable,
          DetectorSetting,
          $$DetectorSettingsTableFilterComposer,
          $$DetectorSettingsTableOrderingComposer,
          $$DetectorSettingsTableAnnotationComposer,
          $$DetectorSettingsTableCreateCompanionBuilder,
          $$DetectorSettingsTableUpdateCompanionBuilder,
          (
            DetectorSetting,
            BaseReferences<
              _$AppDatabase,
              $DetectorSettingsTable,
              DetectorSetting
            >,
          ),
          DetectorSetting,
          PrefetchHooks Function()
        > {
  $$DetectorSettingsTableTableManager(
    _$AppDatabase db,
    $DetectorSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectorSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectorSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectorSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wakeWindowMinutes = const Value.absent(),
                Value<int> quarantineMinutes = const Value.absent(),
                Value<double> motionVarianceThreshold = const Value.absent(),
                Value<double> hrSpikeRatioThreshold = const Value.absent(),
                Value<int> consecutiveEpochsRequired = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DetectorSettingsCompanion(
                id: id,
                wakeWindowMinutes: wakeWindowMinutes,
                quarantineMinutes: quarantineMinutes,
                motionVarianceThreshold: motionVarianceThreshold,
                hrSpikeRatioThreshold: hrSpikeRatioThreshold,
                consecutiveEpochsRequired: consecutiveEpochsRequired,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wakeWindowMinutes = const Value.absent(),
                Value<int> quarantineMinutes = const Value.absent(),
                Value<double> motionVarianceThreshold = const Value.absent(),
                Value<double> hrSpikeRatioThreshold = const Value.absent(),
                Value<int> consecutiveEpochsRequired = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DetectorSettingsCompanion.insert(
                id: id,
                wakeWindowMinutes: wakeWindowMinutes,
                quarantineMinutes: quarantineMinutes,
                motionVarianceThreshold: motionVarianceThreshold,
                hrSpikeRatioThreshold: hrSpikeRatioThreshold,
                consecutiveEpochsRequired: consecutiveEpochsRequired,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DetectorSettingsTable, DetectorSetting>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DetectorSettingsTable,
                    DetectorSetting
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DetectorSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetectorSettingsTable,
      DetectorSetting,
      $$DetectorSettingsTableFilterComposer,
      $$DetectorSettingsTableOrderingComposer,
      $$DetectorSettingsTableAnnotationComposer,
      $$DetectorSettingsTableCreateCompanionBuilder,
      $$DetectorSettingsTableUpdateCompanionBuilder,
      (
        DetectorSetting,
        BaseReferences<_$AppDatabase, $DetectorSettingsTable, DetectorSetting>,
      ),
      DetectorSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SleepTargetsTableTableManager get sleepTargets =>
      $$SleepTargetsTableTableManager(_db, _db.sleepTargets);
  $$ShiftNotesTableTableManager get shiftNotes =>
      $$ShiftNotesTableTableManager(_db, _db.shiftNotes);
  $$SleepHistorySessionsTableTableManager get sleepHistorySessions =>
      $$SleepHistorySessionsTableTableManager(_db, _db.sleepHistorySessions);
  $$DetectorSettingsTableTableManager get detectorSettings =>
      $$DetectorSettingsTableTableManager(_db, _db.detectorSettings);
}
