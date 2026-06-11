import '../models/health_entry.dart';

double progressRatio(num value, num target) {
  if (target <= 0) return 0;
  return (value / target).clamp(0.0, 1.0).toDouble();
}

int sumSteps(List<HealthEntry> entries) {
  return entries.fold<int>(0, (sum, entry) => sum + entry.steps);
}

int sumWater(List<HealthEntry> entries) {
  return entries.fold<int>(0, (sum, entry) => sum + entry.waterMl);
}

int sumWorkoutMinutes(List<HealthEntry> entries) {
  return entries.fold<int>(0, (sum, entry) => sum + entry.workoutMinutes);
}

double averageWeight(List<HealthEntry> entries) {
  if (entries.isEmpty) return 0;
  return entries.fold<double>(0, (sum, entry) => sum + entry.weightKg) / entries.length;
}

double averageSleep(List<HealthEntry> entries) {
  if (entries.isEmpty) return 0;
  return entries.fold<double>(0, (sum, entry) => sum + entry.sleepHours) / entries.length;
}

double averageHeartRate(List<HealthEntry> entries) {
  if (entries.isEmpty) return 0;
  return entries.fold<double>(0, (sum, entry) => sum + entry.heartRate) / entries.length;
}

String insightForToday(HealthEntry? entry) {
  if (entry == null) {
    return 'Bạn chưa nhập dữ liệu hôm nay. Hãy thêm nhật ký để dashboard cập nhật mục tiêu.';
  }
  final messages = <String>[];
  if (entry.steps >= 10000) messages.add('Bước chân đã đạt chuẩn 10.000.');
  if (entry.waterMl >= 2000) messages.add('Lượng nước hôm nay rất ổn.');
  if (entry.sleepHours >= 7) messages.add('Giấc ngủ đạt mục tiêu phục hồi.');
  if (entry.proteinGrams >= 80) messages.add('Protein hôm nay khá tốt cho duy trì cơ.');
  if (messages.isEmpty) return 'Bạn đang có dữ liệu rồi. Cố thêm một mục tiêu nhỏ nữa trong hôm nay nhé.';
  return messages.join(' ');
}
