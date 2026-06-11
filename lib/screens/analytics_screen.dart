import 'package:flutter/material.dart';

import '../models/health_entry.dart';
import '../services/health_service.dart';
import '../utils/health_calculations.dart';
import '../widgets/mini_bar_chart.dart';
import '../widgets/section_title.dart';
import '../widgets/stat_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: StreamBuilder<List<HealthEntry>>(
        stream: HealthService.watchRecentEntries(days: 14),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];
          final steps = sumSteps(entries);
          final water = sumWater(entries);
          final avgWeight = averageWeight(entries);
          final avgSleep = averageSleep(entries);
          final avgHeart = averageHeartRate(entries);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle(
                title: 'Tổng quan 14 ngày',
                subtitle: 'Màn này mô phỏng phần analytics/progress nâng cao của health app.',
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 640;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: wide ? 4 : 2,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      StatCard(title: 'Tổng bước', value: '$steps', icon: Icons.directions_walk),
                      StatCard(title: 'Tổng nước', value: '${(water / 1000).toStringAsFixed(1)}L', icon: Icons.water_drop_outlined),
                      StatCard(title: 'Cân nặng TB', value: avgWeight == 0 ? '-' : '${avgWeight.toStringAsFixed(1)}kg', icon: Icons.monitor_weight_outlined),
                      StatCard(title: 'Nhịp tim TB', value: avgHeart == 0 ? '-' : '${avgHeart.toStringAsFixed(0)} bpm', icon: Icons.favorite_border),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _ChartCard(title: 'Bước chân', entries: entries, valueOf: (entry) => entry.steps, emptyText: 'Chưa có dữ liệu bước chân'),
              const SizedBox(height: 12),
              _ChartCard(title: 'Nước uống (ml)', entries: entries, valueOf: (entry) => entry.waterMl, emptyText: 'Chưa có dữ liệu nước'),
              const SizedBox(height: 12),
              _ChartCard(title: 'Giấc ngủ (giờ)', entries: entries, valueOf: (entry) => entry.sleepHours, emptyText: 'Chưa có dữ liệu ngủ'),
              const SizedBox(height: 12),
              _InsightCard(avgSleep: avgSleep, totalWorkout: sumWorkoutMinutes(entries), entries: entries.length),
            ],
          );
        },
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.entries, required this.valueOf, required this.emptyText});

  final String title;
  final List<HealthEntry> entries;
  final num Function(HealthEntry entry) valueOf;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            MiniBarChart(entries: entries, valueOf: valueOf, emptyText: emptyText),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.avgSleep, required this.totalWorkout, required this.entries});

  final double avgSleep;
  final int totalWorkout;
  final int entries;

  @override
  Widget build(BuildContext context) {
    final sleepText = avgSleep >= 7 ? 'Giấc ngủ trung bình đang ổn.' : 'Nên ưu tiên ngủ đủ hơn để hồi phục.';
    final workoutText = totalWorkout >= 150 ? 'Bạn đã đạt mức vận động tuần tốt.' : 'Có thể thêm 2-3 buổi tập nhẹ trong tuần.';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI-like insight', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(entries == 0 ? 'Hãy nhập nhật ký vài ngày để có nhận xét chính xác hơn.' : '$sleepText $workoutText'),
          ],
        ),
      ),
    );
  }
}
