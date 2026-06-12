// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _firebaseIdMeta = const VerificationMeta(
    'firebaseId',
  );
  @override
  late final GeneratedColumn<String> firebaseId = GeneratedColumn<String>(
    'firebase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FF2196F3'),
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coupleIdMeta = const VerificationMeta(
    'coupleId',
  );
  @override
  late final GeneratedColumn<String> coupleId = GeneratedColumn<String>(
    'couple_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    firebaseId,
    title,
    date,
    description,
    color,
    isAllDay,
    startTime,
    endTime,
    userId,
    coupleId,
    createdBy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<Event> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('firebase_id')) {
      context.handle(
        _firebaseIdMeta,
        firebaseId.isAcceptableOrUnknown(data['firebase_id']!, _firebaseIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('couple_id')) {
      context.handle(
        _coupleIdMeta,
        coupleId.isAcceptableOrUnknown(data['couple_id']!, _coupleIdMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      firebaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firebase_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      coupleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}couple_id'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final int id;
  final String? firebaseId;
  final String title;
  final DateTime date;
  final String? description;
  final String color;
  final bool isAllDay;
  final DateTime? startTime;
  final DateTime? endTime;
  final String userId;
  final String? coupleId;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Event({
    required this.id,
    this.firebaseId,
    required this.title,
    required this.date,
    this.description,
    required this.color,
    required this.isAllDay,
    this.startTime,
    this.endTime,
    required this.userId,
    this.coupleId,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || firebaseId != null) {
      map['firebase_id'] = Variable<String>(firebaseId);
    }
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['color'] = Variable<String>(color);
    map['is_all_day'] = Variable<bool>(isAllDay);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || coupleId != null) {
      map['couple_id'] = Variable<String>(coupleId);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      firebaseId: firebaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(firebaseId),
      title: Value(title),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      color: Value(color),
      isAllDay: Value(isAllDay),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      userId: Value(userId),
      coupleId: coupleId == null && nullToAbsent
          ? const Value.absent()
          : Value(coupleId),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Event.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<int>(json['id']),
      firebaseId: serializer.fromJson<String?>(json['firebaseId']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
      color: serializer.fromJson<String>(json['color']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      userId: serializer.fromJson<String>(json['userId']),
      coupleId: serializer.fromJson<String?>(json['coupleId']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'firebaseId': serializer.toJson<String?>(firebaseId),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
      'color': serializer.toJson<String>(color),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'userId': serializer.toJson<String>(userId),
      'coupleId': serializer.toJson<String?>(coupleId),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Event copyWith({
    int? id,
    Value<String?> firebaseId = const Value.absent(),
    String? title,
    DateTime? date,
    Value<String?> description = const Value.absent(),
    String? color,
    bool? isAllDay,
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
    String? userId,
    Value<String?> coupleId = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Event(
    id: id ?? this.id,
    firebaseId: firebaseId.present ? firebaseId.value : this.firebaseId,
    title: title ?? this.title,
    date: date ?? this.date,
    description: description.present ? description.value : this.description,
    color: color ?? this.color,
    isAllDay: isAllDay ?? this.isAllDay,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    userId: userId ?? this.userId,
    coupleId: coupleId.present ? coupleId.value : this.coupleId,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      firebaseId: data.firebaseId.present
          ? data.firebaseId.value
          : this.firebaseId,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      color: data.color.present ? data.color.value : this.color,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      userId: data.userId.present ? data.userId.value : this.userId,
      coupleId: data.coupleId.present ? data.coupleId.value : this.coupleId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('firebaseId: $firebaseId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('userId: $userId, ')
          ..write('coupleId: $coupleId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firebaseId,
    title,
    date,
    description,
    color,
    isAllDay,
    startTime,
    endTime,
    userId,
    coupleId,
    createdBy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.firebaseId == this.firebaseId &&
          other.title == this.title &&
          other.date == this.date &&
          other.description == this.description &&
          other.color == this.color &&
          other.isAllDay == this.isAllDay &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.userId == this.userId &&
          other.coupleId == this.coupleId &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<int> id;
  final Value<String?> firebaseId;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<String?> description;
  final Value<String> color;
  final Value<bool> isAllDay;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<String> userId;
  final Value<String?> coupleId;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.firebaseId = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.userId = const Value.absent(),
    this.coupleId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    this.firebaseId = const Value.absent(),
    required String title,
    required DateTime date,
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    required String userId,
    this.coupleId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title),
       date = Value(date),
       userId = Value(userId);
  static Insertable<Event> custom({
    Expression<int>? id,
    Expression<String>? firebaseId,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? color,
    Expression<bool>? isAllDay,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? userId,
    Expression<String>? coupleId,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firebaseId != null) 'firebase_id': firebaseId,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (userId != null) 'user_id': userId,
      if (coupleId != null) 'couple_id': coupleId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EventsCompanion copyWith({
    Value<int>? id,
    Value<String?>? firebaseId,
    Value<String>? title,
    Value<DateTime>? date,
    Value<String?>? description,
    Value<String>? color,
    Value<bool>? isAllDay,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<String>? userId,
    Value<String?>? coupleId,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EventsCompanion(
      id: id ?? this.id,
      firebaseId: firebaseId ?? this.firebaseId,
      title: title ?? this.title,
      date: date ?? this.date,
      description: description ?? this.description,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userId: userId ?? this.userId,
      coupleId: coupleId ?? this.coupleId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (firebaseId.present) {
      map['firebase_id'] = Variable<String>(firebaseId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (coupleId.present) {
      map['couple_id'] = Variable<String>(coupleId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('firebaseId: $firebaseId, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('userId: $userId, ')
          ..write('coupleId: $coupleId, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CoupleInfoTable extends CoupleInfo
    with TableInfo<$CoupleInfoTable, CoupleInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoupleInfoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partnerNameMeta = const VerificationMeta(
    'partnerName',
  );
  @override
  late final GeneratedColumn<String> partnerName = GeneratedColumn<String>(
    'partner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeColorMeta = const VerificationMeta(
    'themeColor',
  );
  @override
  late final GeneratedColumn<String> themeColor = GeneratedColumn<String>(
    'theme_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FFE91E63'),
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
    userId,
    userName,
    partnerName,
    photoUrl,
    themeColor,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'couple_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoupleInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('partner_name')) {
      context.handle(
        _partnerNameMeta,
        partnerName.isAcceptableOrUnknown(
          data['partner_name']!,
          _partnerNameMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('theme_color')) {
      context.handle(
        _themeColorMeta,
        themeColor.isAcceptableOrUnknown(data['theme_color']!, _themeColorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  CoupleInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoupleInfoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      partnerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partner_name'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      themeColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CoupleInfoTable createAlias(String alias) {
    return $CoupleInfoTable(attachedDatabase, alias);
  }
}

class CoupleInfoData extends DataClass implements Insertable<CoupleInfoData> {
  final int id;
  final String userId;
  final String userName;
  final String? partnerName;
  final String? photoUrl;
  final String themeColor;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CoupleInfoData({
    required this.id,
    required this.userId,
    required this.userName,
    this.partnerName,
    this.photoUrl,
    required this.themeColor,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['user_name'] = Variable<String>(userName);
    if (!nullToAbsent || partnerName != null) {
      map['partner_name'] = Variable<String>(partnerName);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['theme_color'] = Variable<String>(themeColor);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CoupleInfoCompanion toCompanion(bool nullToAbsent) {
    return CoupleInfoCompanion(
      id: Value(id),
      userId: Value(userId),
      userName: Value(userName),
      partnerName: partnerName == null && nullToAbsent
          ? const Value.absent()
          : Value(partnerName),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      themeColor: Value(themeColor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CoupleInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoupleInfoData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      userName: serializer.fromJson<String>(json['userName']),
      partnerName: serializer.fromJson<String?>(json['partnerName']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      themeColor: serializer.fromJson<String>(json['themeColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'userName': serializer.toJson<String>(userName),
      'partnerName': serializer.toJson<String?>(partnerName),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'themeColor': serializer.toJson<String>(themeColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CoupleInfoData copyWith({
    int? id,
    String? userId,
    String? userName,
    Value<String?> partnerName = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    String? themeColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CoupleInfoData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    partnerName: partnerName.present ? partnerName.value : this.partnerName,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    themeColor: themeColor ?? this.themeColor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CoupleInfoData copyWithCompanion(CoupleInfoCompanion data) {
    return CoupleInfoData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userName: data.userName.present ? data.userName.value : this.userName,
      partnerName: data.partnerName.present
          ? data.partnerName.value
          : this.partnerName,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      themeColor: data.themeColor.present
          ? data.themeColor.value
          : this.themeColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoupleInfoData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('partnerName: $partnerName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('themeColor: $themeColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    userName,
    partnerName,
    photoUrl,
    themeColor,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoupleInfoData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userName == this.userName &&
          other.partnerName == this.partnerName &&
          other.photoUrl == this.photoUrl &&
          other.themeColor == this.themeColor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CoupleInfoCompanion extends UpdateCompanion<CoupleInfoData> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> userName;
  final Value<String?> partnerName;
  final Value<String?> photoUrl;
  final Value<String> themeColor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CoupleInfoCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.partnerName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.themeColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CoupleInfoCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String userName,
    this.partnerName = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.themeColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : userId = Value(userId),
       userName = Value(userName);
  static Insertable<CoupleInfoData> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? userName,
    Expression<String>? partnerName,
    Expression<String>? photoUrl,
    Expression<String>? themeColor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (partnerName != null) 'partner_name': partnerName,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (themeColor != null) 'theme_color': themeColor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CoupleInfoCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? userName,
    Value<String?>? partnerName,
    Value<String?>? photoUrl,
    Value<String>? themeColor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CoupleInfoCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      partnerName: partnerName ?? this.partnerName,
      photoUrl: photoUrl ?? this.photoUrl,
      themeColor: themeColor ?? this.themeColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (partnerName.present) {
      map['partner_name'] = Variable<String>(partnerName.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (themeColor.present) {
      map['theme_color'] = Variable<String>(themeColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoupleInfoCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('partnerName: $partnerName, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('themeColor: $themeColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EventsTable events = $EventsTable(this);
  late final $CoupleInfoTable coupleInfo = $CoupleInfoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [events, coupleInfo];
}

typedef $$EventsTableCreateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      Value<String?> firebaseId,
      required String title,
      required DateTime date,
      Value<String?> description,
      Value<String> color,
      Value<bool> isAllDay,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      required String userId,
      Value<String?> coupleId,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EventsTableUpdateCompanionBuilder =
    EventsCompanion Function({
      Value<int> id,
      Value<String?> firebaseId,
      Value<String> title,
      Value<DateTime> date,
      Value<String?> description,
      Value<String> color,
      Value<bool> isAllDay,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<String> userId,
      Value<String?> coupleId,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
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

  ColumnFilters<String> get firebaseId => $composableBuilder(
    column: $table.firebaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
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

  ColumnOrderings<String> get firebaseId => $composableBuilder(
    column: $table.firebaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coupleId => $composableBuilder(
    column: $table.coupleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firebaseId => $composableBuilder(
    column: $table.firebaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get coupleId =>
      $composableBuilder(column: $table.coupleId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTable,
          Event,
          $$EventsTableFilterComposer,
          $$EventsTableOrderingComposer,
          $$EventsTableAnnotationComposer,
          $$EventsTableCreateCompanionBuilder,
          $$EventsTableUpdateCompanionBuilder,
          (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
          Event,
          PrefetchHooks Function()
        > {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> firebaseId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> coupleId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EventsCompanion(
                id: id,
                firebaseId: firebaseId,
                title: title,
                date: date,
                description: description,
                color: color,
                isAllDay: isAllDay,
                startTime: startTime,
                endTime: endTime,
                userId: userId,
                coupleId: coupleId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> firebaseId = const Value.absent(),
                required String title,
                required DateTime date,
                Value<String?> description = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                required String userId,
                Value<String?> coupleId = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EventsCompanion.insert(
                id: id,
                firebaseId: firebaseId,
                title: title,
                date: date,
                description: description,
                color: color,
                isAllDay: isAllDay,
                startTime: startTime,
                endTime: endTime,
                userId: userId,
                coupleId: coupleId,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTable,
      Event,
      $$EventsTableFilterComposer,
      $$EventsTableOrderingComposer,
      $$EventsTableAnnotationComposer,
      $$EventsTableCreateCompanionBuilder,
      $$EventsTableUpdateCompanionBuilder,
      (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
      Event,
      PrefetchHooks Function()
    >;
typedef $$CoupleInfoTableCreateCompanionBuilder =
    CoupleInfoCompanion Function({
      Value<int> id,
      required String userId,
      required String userName,
      Value<String?> partnerName,
      Value<String?> photoUrl,
      Value<String> themeColor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CoupleInfoTableUpdateCompanionBuilder =
    CoupleInfoCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> userName,
      Value<String?> partnerName,
      Value<String?> photoUrl,
      Value<String> themeColor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CoupleInfoTableFilterComposer
    extends Composer<_$AppDatabase, $CoupleInfoTable> {
  $$CoupleInfoTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoupleInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $CoupleInfoTable> {
  $$CoupleInfoTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoupleInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoupleInfoTable> {
  $$CoupleInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get partnerName => $composableBuilder(
    column: $table.partnerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CoupleInfoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoupleInfoTable,
          CoupleInfoData,
          $$CoupleInfoTableFilterComposer,
          $$CoupleInfoTableOrderingComposer,
          $$CoupleInfoTableAnnotationComposer,
          $$CoupleInfoTableCreateCompanionBuilder,
          $$CoupleInfoTableUpdateCompanionBuilder,
          (
            CoupleInfoData,
            BaseReferences<_$AppDatabase, $CoupleInfoTable, CoupleInfoData>,
          ),
          CoupleInfoData,
          PrefetchHooks Function()
        > {
  $$CoupleInfoTableTableManager(_$AppDatabase db, $CoupleInfoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoupleInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoupleInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoupleInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<String?> partnerName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String> themeColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CoupleInfoCompanion(
                id: id,
                userId: userId,
                userName: userName,
                partnerName: partnerName,
                photoUrl: photoUrl,
                themeColor: themeColor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String userName,
                Value<String?> partnerName = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String> themeColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CoupleInfoCompanion.insert(
                id: id,
                userId: userId,
                userName: userName,
                partnerName: partnerName,
                photoUrl: photoUrl,
                themeColor: themeColor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoupleInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoupleInfoTable,
      CoupleInfoData,
      $$CoupleInfoTableFilterComposer,
      $$CoupleInfoTableOrderingComposer,
      $$CoupleInfoTableAnnotationComposer,
      $$CoupleInfoTableCreateCompanionBuilder,
      $$CoupleInfoTableUpdateCompanionBuilder,
      (
        CoupleInfoData,
        BaseReferences<_$AppDatabase, $CoupleInfoTable, CoupleInfoData>,
      ),
      CoupleInfoData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$CoupleInfoTableTableManager get coupleInfo =>
      $$CoupleInfoTableTableManager(_db, _db.coupleInfo);
}
