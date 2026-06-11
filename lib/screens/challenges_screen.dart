import 'package:flutter/material.dart';

import '../models/health_entry.dart';
import '../services/health_service.dart';
import '../utils/health_calculations.dart';
import '../widgets/section_title.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navigator.canPop(context) ? AppBar(title: const Text('Challenges')) : null,
      body: StreamBuilder<List<HealthEntry>>(
        stream: HealthService.watchRecentEntries(days: 7),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? [];
          final latest = entries.isEmpty ? null : entries.last;
          final totalSteps = sumSteps(entries);
          final totalWorkout = sumWorkoutMinutes(entries);
          final avgSleepValue = averageSleep(entries);
          final waterLiters = sumWater(entries) / 1000;

          final challenges = [
            _Challenge(title: '70.000 bước / tuần', description: 'Tích lũy bước chân trong 7 ngày gần nhất.', icon: Icons.directions_walk, progress: progressRatio(totalSteps, 70000), value: '$totalSteps / 70000'),
            _Challenge(title: '14 lít nước / tuần', description: 'Uống trung bình 2 lít nước mỗi ngày.', icon: Icons.water_drop_outlined, progress: progressRatio(waterLiters, 14), value: '${waterLiters.toStringAsFixed(1)}L / 14L'),
            _Challenge(title: '150 phút vận động', description: 'Tổng thời gian tập trong tuần.', icon: Icons.fitness_center, progress: progressRatio(totalWorkout, 150), value: '$totalWorkout / 150 phút'),
            _Challenge(title: 'Ngủ đủ', description: 'Mục tiêu trung bình từ 7 giờ/ngày.', icon: Icons.bedtime_outlined, progress: progressRatio(avgSleepValue, 7), value: '${avgSleepValue.toStringAsFixed(1)}h / 7h'),
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.emoji_events_outlined)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Gamification',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(latest == null ? 'Thêm nhật ký để thử thách tự cập nhật.' : 'Dữ liệu mới nhất: ${latest.steps} bước, ${latest.waterMl}ml nước, ${latest.sleepHours.toStringAsFixed(1)}h ngủ.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SectionTitle(title: 'Daily / weekly challenges'),
              for (final challenge in challenges) _ChallengeCard(challenge: challenge),
            ],
          );
        },
      ),
    );
  }
}

class _Challenge {
  const _Challenge({required this.title, required this.description, required this.icon, required this.progress, required this.value});

  final String title;
  final String description;
  final IconData icon;
  final double progress;
  final String value;
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final _Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final done = challenge.progress >= 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(done ? Icons.check : challenge.icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(challenge.value),
                    ],
                  ),
                ),
                Text('${(challenge.progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 10),
            Text(challenge.description),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: challenge.progress, minHeight: 9, borderRadius: BorderRadius.circular(20)),
          ],
        ),
      ),
    );
  }
}
