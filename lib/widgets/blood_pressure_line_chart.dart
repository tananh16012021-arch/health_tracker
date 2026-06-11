import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl; // <-- thêm prefix intl

import '../models/blood_pressure_entry.dart';

class BloodPressureLineChart extends StatelessWidget {
  const BloodPressureLineChart({
    super.key,
    required this.entries,
    this.compact = false,
  });

  final List<BloodPressureEntry> entries;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        height: compact ? 120 : 230,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('Chưa có dữ liệu huyết áp'),
      );
    }

    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: const [
              _LegendDot(label: 'Tâm thu', color: Color(0xFFE53935)),
              _LegendDot(label: 'Tâm trương', color: Color(0xFF1E88E5)),
              _LegendDot(label: 'Nhịp tim', color: Color(0xFF43A047)),
              _LegendDot(label: 'Ngưỡng 140/90', color: Color(0xFFFFA000), dashed: true),
            ],
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: compact ? 120 : 230,
          width: double.infinity,
          child: CustomPaint(
            painter: _BloodPressureChartPainter(
              entries: sorted,
              textColor: Theme.of(context).colorScheme.onSurfaceVariant,
              gridColor: Theme.of(context).dividerColor.withOpacity(0.65),
              compact: compact,
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color, this.dashed = false});

  final String label;
  final Color color;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dashed ? 18 : 10,
          height: dashed ? 2 : 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _BloodPressureChartPainter extends CustomPainter {
  _BloodPressureChartPainter({
    required this.entries,
    required this.textColor,
    required this.gridColor,
    required this.compact,
  });

  final List<BloodPressureEntry> entries;
  final Color textColor;
  final Color gridColor;
  final bool compact;

  static const _systolicColor = Color(0xFFE53935);
  static const _diastolicColor = Color(0xFF1E88E5);
  static const _pulseColor = Color(0xFF43A047);
  static const _thresholdColor = Color(0xFFFFA000);

  @override
  void paint(Canvas canvas, Size size) {
    final left = compact ? 4.0 : 34.0;
    final right = compact ? 4.0 : 34.0;
    final top = 10.0;
    final bottom = compact ? 18.0 : 30.0;
    final chart = Rect.fromLTWH(left, top, size.width - left - right, size.height - top - bottom);

    if (chart.width <= 0 || chart.height <= 0) return;

    final bpValues = <int>[
      ...entries.map((e) => e.systolic),
      ...entries.map((e) => e.diastolic),
      90,
      140,
    ];
    final pulseValues = entries.map((e) => e.pulse).where((v) => v > 0).toList();

    var minBp = math.max(40, bpValues.reduce(math.min) - 10).toDouble();
    var maxBp = math.min(220, bpValues.reduce(math.max) + 10).toDouble();
    if ((maxBp - minBp).abs() < 1) maxBp = minBp + 1;

    var minPulse = pulseValues.isEmpty ? 40.0 : math.max(35, pulseValues.reduce(math.min) - 10).toDouble();
    var maxPulse = pulseValues.isEmpty ? 130.0 : math.min(180, pulseValues.reduce(math.max) + 10).toDouble();
    if ((maxPulse - minPulse).abs() < 1) maxPulse = minPulse + 1;

    double xFor(int index) {
      if (entries.length == 1) return chart.center.dx;
      return chart.left + chart.width * index / (entries.length - 1);
    }

    double yForBp(num value) {
      return chart.bottom - ((value - minBp) / (maxBp - minBp)) * chart.height;
    }

    double yForPulse(num value) {
      return chart.bottom - ((value - minPulse) / (maxPulse - minPulse)) * chart.height;
    }

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = chart.top + chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }

    final axisPaint = Paint()
      ..color = gridColor.withOpacity(0.9)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(chart.left, chart.top), Offset(chart.left, chart.bottom), axisPaint);
    canvas.drawLine(Offset(chart.left, chart.bottom), Offset(chart.right, chart.bottom), axisPaint);

    _drawThreshold(canvas, chart, yForBp(140), '140', compact);
    _drawThreshold(canvas, chart, yForBp(90), '90', compact);

    _drawSeries(canvas, entries.asMap().entries.map((item) => Offset(xFor(item.key), yForBp(item.value.systolic))).toList(), _systolicColor);
    _drawSeries(canvas, entries.asMap().entries.map((item) => Offset(xFor(item.key), yForBp(item.value.diastolic))).toList(), _diastolicColor);
    if (pulseValues.isNotEmpty) {
      _drawSeries(canvas, entries.asMap().entries.map((item) => Offset(xFor(item.key), yForPulse(item.value.pulse))).toList(), _pulseColor, strokeWidth: 2);
    }

    if (!compact) {
      _drawAxisLabels(canvas, chart, minBp, maxBp, minPulse, maxPulse);
      _drawDateLabels(canvas, chart);
    } else if (entries.length > 1) {
      _drawSmallDate(canvas, intl.DateFormat('dd/MM').format(entries.first.date), Offset(chart.left, chart.bottom + 4));
      _drawSmallDate(canvas, intl.DateFormat('dd/MM').format(entries.last.date), Offset(chart.right - 38, chart.bottom + 4));
    }
  }

  void _drawSeries(Canvas canvas, List<Offset> points, Color color, {double strokeWidth = 3}) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length == 1) {
      canvas.drawCircle(points.first, 4, Paint()..color = color);
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, compact ? 2.5 : 3.5, dotPaint);
    }
  }

  void _drawThreshold(Canvas canvas, Rect chart, double y, String label, bool compact) {
    if (y < chart.top || y > chart.bottom) return;
    final paint = Paint()
      ..color = _thresholdColor.withOpacity(0.75)
      ..strokeWidth = 1.2;
    const dashWidth = 7.0;
    const gap = 5.0;
    var x = chart.left;
    while (x < chart.right) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dashWidth, chart.right), y), paint);
      x += dashWidth + gap;
    }
    if (!compact) {
      _drawText(canvas, label, Offset(chart.left - 28, y - 8), fontSize: 11);
    }
  }

  void _drawAxisLabels(Canvas canvas, Rect chart, double minBp, double maxBp, double minPulse, double maxPulse) {
    _drawText(canvas, maxBp.toStringAsFixed(0), Offset(chart.left - 30, chart.top - 3), fontSize: 10);
    _drawText(canvas, minBp.toStringAsFixed(0), Offset(chart.left - 30, chart.bottom - 10), fontSize: 10);
    _drawText(canvas, maxPulse.toStringAsFixed(0), Offset(chart.right + 7, chart.top - 3), fontSize: 10, color: _pulseColor);
    _drawText(canvas, minPulse.toStringAsFixed(0), Offset(chart.right + 7, chart.bottom - 10), fontSize: 10, color: _pulseColor);
  }

  void _drawDateLabels(Canvas canvas, Rect chart) {
    if (entries.isEmpty) return;
    final first = intl.DateFormat('dd/MM').format(entries.first.date);
    final last = intl.DateFormat('dd/MM').format(entries.last.date);
    _drawText(canvas, first, Offset(chart.left, chart.bottom + 8), fontSize: 10);
    _drawText(canvas, last, Offset(chart.right - 40, chart.bottom + 8), fontSize: 10);
  }

  void _drawSmallDate(Canvas canvas, String text, Offset offset) {
    _drawText(canvas, text, offset, fontSize: 9);
  }

  void _drawText(Canvas canvas, String text, Offset offset, {double fontSize = 12, Color? color}) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color ?? textColor, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr, // <-- Flutter TextDirection
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _BloodPressureChartPainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.compact != compact;
  }
}