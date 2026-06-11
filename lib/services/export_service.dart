import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/blood_pressure_entry.dart';
import '../models/health_entry.dart';
import 'health_service.dart';

class ExportService {
  ExportService._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  static Future<File> buildHealthCsv({int days = 90}) async {
    final entries = await HealthService.fetchEntries(days: days);
    final bpEntries = await HealthService.fetchBloodPressureEntries(days: days);
    final directory = await getTemporaryDirectory();
    final fileName = 'health_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${directory.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln('Health Tracker Export');
    buffer.writeln('Generated At,${_csv(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()))}');
    buffer.writeln('Range Days,$days');
    buffer.writeln('');

    buffer.writeln('Daily Health Journal');
    buffer.writeln([
      'Date',
      'Steps',
      'Calories',
      'Water Ml',
      'Weight Kg',
      'Heart Rate',
      'Sleep Hours',
      'Workout Minutes',
      'Protein Grams',
      'Mood',
      'Note',
    ].map(_csv).join(','));
    for (final entry in entries) {
      buffer.writeln(_healthRow(entry));
    }

    buffer.writeln('');
    buffer.writeln('Blood Pressure');
    buffer.writeln([
      'Date',
      'Systolic',
      'Diastolic',
      'Pulse',
      'Status',
      'Mood',
      'Note',
    ].map(_csv).join(','));
    for (final entry in bpEntries) {
      buffer.writeln(_bloodPressureRow(entry));
    }

    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }

  static Future<void> shareHealthData({int days = 90}) async {
    final file = await buildHealthCsv(days: days);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Health Tracker data export',
      text: 'File CSV dữ liệu sức khỏe $days ngày gần nhất. Bạn có thể chọn Gmail/Email để gửi bác sĩ.',
    );
  }

  static Future<void> openDoctorEmail({
    required String doctorEmail,
    int days = 90,
  }) async {
    final summary = await buildDoctorSummary(days: days);
    final uri = Uri(
      scheme: 'mailto',
      path: doctorEmail.trim(),
      query: _encodeQueryParameters({
        'subject': 'Dữ liệu theo dõi sức khỏe $days ngày gần nhất',
        'body': summary,
      }),
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw StateError('Không mở được ứng dụng email trên thiết bị này.');
    }
  }

  static Future<String> buildDoctorSummary({int days = 90}) async {
    final entries = await HealthService.fetchEntries(days: days);
    final bpEntries = await HealthService.fetchBloodPressureEntries(days: days);

    final avgWater = entries.isEmpty ? 0 : entries.fold<int>(0, (sum, e) => sum + e.waterMl) / entries.length;
    final avgSteps = entries.isEmpty ? 0 : entries.fold<int>(0, (sum, e) => sum + e.steps) / entries.length;
    final avgSleep = entries.isEmpty ? 0 : entries.fold<double>(0, (sum, e) => sum + e.sleepHours) / entries.length;
    final avgHeart = entries.isEmpty ? 0 : entries.fold<int>(0, (sum, e) => sum + e.heartRate) / entries.length;
    final latestBp = bpEntries.isEmpty ? null : bpEntries.last;
    final latestBpText = latestBp == null
        ? 'Chưa có dữ liệu'
        : '${latestBp.systolic}/${latestBp.diastolic} mmHg, pulse ${latestBp.pulse} bpm, ${DateFormat('dd/MM/yyyy HH:mm').format(latestBp.date)}';
    final highBpCount = bpEntries.where((entry) => entry.isHigh).length;

    return '''Chào bác sĩ,

Em gửi tóm tắt dữ liệu sức khỏe trong $days ngày gần nhất từ app Health Tracker:

- Số ngày có nhật ký: ${entries.length}
- Bước chân trung bình: ${avgSteps.toStringAsFixed(0)} bước/ngày
- Nước uống trung bình: ${avgWater.toStringAsFixed(0)} ml/ngày
- Giấc ngủ trung bình: ${avgSleep.toStringAsFixed(1)} giờ/ngày
- Nhịp tim trung bình: ${avgHeart.toStringAsFixed(0)} bpm
- Số lần đo huyết áp: ${bpEntries.length}
- Huyết áp gần nhất: $latestBpText
- Số lần huyết áp vượt mốc 140/90: $highBpCount

Em có đính kèm file CSV xuất từ app để bác sĩ xem chi tiết.

Cảm ơn bác sĩ.''';
  }

  static String _healthRow(HealthEntry entry) {
    return [
      _dateFormat.format(entry.date),
      entry.steps,
      entry.calories,
      entry.waterMl,
      entry.weightKg,
      entry.heartRate,
      entry.sleepHours,
      entry.workoutMinutes,
      entry.proteinGrams,
      entry.mood,
      entry.note,
    ].map(_csv).join(',');
  }

  static String _bloodPressureRow(BloodPressureEntry entry) {
    return [
      _dateFormat.format(entry.date),
      entry.systolic,
      entry.diastolic,
      entry.pulse,
      entry.statusLabel,
      entry.mood,
      entry.note,
    ].map(_csv).join(',');
  }

  static String _csv(Object? value) {
    final text = '${value ?? ''}'.replaceAll('"', '""');
    return '"$text"';
  }

  static String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((entry) => '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}')
        .join('&');
  }
}
