import 'dart:convert';
import 'session_snapshot.dart';

enum SessionStatus {
  completed,
  partial,
  cancelled;

  static SessionStatus fromString(String val) {
    return SessionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => SessionStatus.completed,
    );
  }
}

class MeditationSession {
  final String id;
  final String practiceId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int plannedDurationSeconds;
  final int actualDurationSeconds;
  final SessionStatus status;
  final String? mood; // e.g. 'peaceful', 'content', 'neutral', 'restless', 'difficult'
  final String? note;
  final SessionSnapshot snapshot;

  const MeditationSession({
    required this.id,
    required this.practiceId,
    required this.startedAt,
    required this.completedAt,
    required this.plannedDurationSeconds,
    required this.actualDurationSeconds,
    required this.status,
    this.mood,
    this.note,
    required this.snapshot,
  });

  bool get isCompleted => status == SessionStatus.completed;

  MeditationSession copyWith({
    String? id,
    String? practiceId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? plannedDurationSeconds,
    int? actualDurationSeconds,
    SessionStatus? status,
    String? mood,
    String? note,
    SessionSnapshot? snapshot,
  }) {
    return MeditationSession(
      id: id ?? this.id,
      practiceId: practiceId ?? this.practiceId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      plannedDurationSeconds:
          plannedDurationSeconds ?? this.plannedDurationSeconds,
      actualDurationSeconds:
          actualDurationSeconds ?? this.actualDurationSeconds,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      snapshot: snapshot ?? this.snapshot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'practiceId': practiceId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'plannedDurationSeconds': plannedDurationSeconds,
      'actualDurationSeconds': actualDurationSeconds,
      'status': status.name,
      'mood': mood,
      'note': note,
      'snapshot': snapshot.toJson(),
    };
  }

  factory MeditationSession.fromJson(Map<String, dynamic> json) {
    final snapshotJson = json['snapshot'] is Map<String, dynamic>
        ? json['snapshot'] as Map<String, dynamic>
        : (json['snapshot'] is String
            ? jsonDecode(json['snapshot'] as String) as Map<String, dynamic>
            : <String, dynamic>{});

    return MeditationSession(
      id: json['id'] as String,
      practiceId: json['practiceId'] as String? ?? '',
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      plannedDurationSeconds:
          (json['plannedDurationSeconds'] as num).toInt(),
      actualDurationSeconds: (json['actualDurationSeconds'] as num).toInt(),
      status: SessionStatus.fromString(json['status'] as String),
      mood: json['mood'] as String?,
      note: json['note'] as String?,
      snapshot: SessionSnapshot.fromJson(snapshotJson),
    );
  }
}
