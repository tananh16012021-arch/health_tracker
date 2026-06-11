import 'package:cloud_firestore/cloud_firestore.dart';

class BloodPressureEntry {
  BloodPressureEntry({
    this.id,
    required this.userId,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.date,
    this.note = '',
    this.mood = 'Bình thường',
  });

  final String? id;
  final String userId;
  final int systolic;
  final int diastolic;
  final int pulse;
  final DateTime date;
  final String note;
  final String mood;

  bool get isHigh => systolic >= 140 || diastolic >= 90;
  bool get isElevated => !isHigh && (systolic >= 130 || diastolic >= 85);
  bool get isLow => systolic < 90 || diastolic < 60;

  String get statusLabel {
    if (isHigh) return 'Cảnh báo cao';
    if (isElevated) return 'Hơi cao';
    if (isLow) return 'Hơi thấp';
    return 'Bình thường';
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'date': Timestamp.fromDate(date),
      'note': note,
      'mood': mood,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'userId': userId,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'date': Timestamp.fromDate(date),
      'note': note,
      'mood': mood,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BloodPressureEntry copyWith({
    String? id,
    String? userId,
    int? systolic,
    int? diastolic,
    int? pulse,
    DateTime? date,
    String? note,
    String? mood,
  }) {
    return BloodPressureEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      date: date ?? this.date,
      note: note ?? this.note,
      mood: mood ?? this.mood,
    );
  }

  factory BloodPressureEntry.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawDate = data['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return BloodPressureEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      systolic: (data['systolic'] as num?)?.toInt() ?? 0,
      diastolic: (data['diastolic'] as num?)?.toInt() ?? 0,
      pulse: (data['pulse'] as num?)?.toInt() ?? 0,
      date: parsedDate,
      note: data['note'] as String? ?? '',
      mood: data['mood'] as String? ?? 'Bình thường',
    );
  }
}
