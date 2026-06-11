import 'package:cloud_firestore/cloud_firestore.dart';

class HealthEntry {
  HealthEntry({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.waterMl,
    required this.weightKg,
    required this.heartRate,
    required this.sleepHours,
    required this.note,
    this.mood = 'Tốt',
    this.workoutMinutes = 0,
    this.proteinGrams = 0,
  });

  final String? id;
  final DateTime date;
  final int steps;
  final int calories;
  final int waterMl;
  final double weightKg;
  final int heartRate;
  final double sleepHours;
  final String note;
  final String mood;
  final int workoutMinutes;
  final int proteinGrams;

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'steps': steps,
      'calories': calories,
      'waterMl': waterMl,
      'weightKg': weightKg,
      'heartRate': heartRate,
      'sleepHours': sleepHours,
      'note': note,
      'mood': mood,
      'workoutMinutes': workoutMinutes,
      'proteinGrams': proteinGrams,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  HealthEntry copyWith({
    String? id,
    DateTime? date,
    int? steps,
    int? calories,
    int? waterMl,
    double? weightKg,
    int? heartRate,
    double? sleepHours,
    String? note,
    String? mood,
    int? workoutMinutes,
    int? proteinGrams,
  }) {
    return HealthEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      waterMl: waterMl ?? this.waterMl,
      weightKg: weightKg ?? this.weightKg,
      heartRate: heartRate ?? this.heartRate,
      sleepHours: sleepHours ?? this.sleepHours,
      note: note ?? this.note,
      mood: mood ?? this.mood,
      workoutMinutes: workoutMinutes ?? this.workoutMinutes,
      proteinGrams: proteinGrams ?? this.proteinGrams,
    );
  }

  factory HealthEntry.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return HealthEntry(
      id: doc.id,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      steps: (data['steps'] as num?)?.toInt() ?? 0,
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      waterMl: (data['waterMl'] as num?)?.toInt() ?? 0,
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      heartRate: (data['heartRate'] as num?)?.toInt() ?? 0,
      sleepHours: (data['sleepHours'] as num?)?.toDouble() ?? 0,
      note: data['note'] as String? ?? '',
      mood: data['mood'] as String? ?? 'Tốt',
      workoutMinutes: (data['workoutMinutes'] as num?)?.toInt() ?? 0,
      proteinGrams: (data['proteinGrams'] as num?)?.toInt() ?? 0,
    );
  }
}
