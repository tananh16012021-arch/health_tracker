import 'package:flutter/material.dart';

import '../models/workout.dart';
import '../widgets/section_title.dart';
import 'challenges_screen.dart';
import 'nutrition_screen.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'Workout & Diet Plans',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Gợi ý bài tập, meal plan, challenge và thói quen lành mạnh theo phong cách app health tracker mẫu.'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionTitle(
          title: 'Bài tập đề xuất',
          trailing: TextButton(
            onPressed: () {},
            child: const Text('Demo'),
          ),
        ),
        for (final workout in sampleWorkouts) _WorkoutCard(workout: workout),
        const SizedBox(height: 12),
        const SectionTitle(title: 'Mở rộng nhanh'),
        _NavigationCard(
          title: 'Nutrition & barcode lookup',
          subtitle: 'Xem món ăn, macro và tra cứu barcode demo.',
          icon: Icons.restaurant_menu,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NutritionScreen())),
        ),
        _NavigationCard(
          title: 'Daily / weekly challenges',
          subtitle: 'Theo dõi thử thách bước chân, nước, ngủ và tập luyện.',
          icon: Icons.emoji_events_outlined,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChallengesScreen())),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout});

  final WorkoutPlan workout;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${workout.durationMinutes}')),
        title: Text(workout.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${workout.level} • ${workout.focus} • ~${workout.calories} kcal'),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          for (final exercise in workout.exercises)
            ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline),
              title: Text(exercise),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã chọn plan: ${workout.title}. Bạn có thể ghi phút tập vào nhật ký.')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Bắt đầu workout'),
          ),
        ],
      ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
