import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/health_entry.dart';

class EntryTile extends StatelessWidget {
  const EntryTile({
    super.key,
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  final HealthEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(entry.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Tâm trạng: ${entry.mood}'),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Sửa',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Xóa',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(icon: Icons.directions_walk, text: '${entry.steps} bước'),
                  _Chip(icon: Icons.local_fire_department, text: '${entry.calories} kcal'),
                  _Chip(icon: Icons.water_drop_outlined, text: '${entry.waterMl} ml'),
                  _Chip(icon: Icons.monitor_weight_outlined, text: '${entry.weightKg.toStringAsFixed(1)} kg'),
                  _Chip(icon: Icons.favorite_border, text: '${entry.heartRate} bpm'),
                  _Chip(icon: Icons.bedtime_outlined, text: '${entry.sleepHours.toStringAsFixed(1)}h ngủ'),
                  _Chip(icon: Icons.fitness_center, text: '${entry.workoutMinutes} phút tập'),
                  _Chip(icon: Icons.egg_alt_outlined, text: '${entry.proteinGrams}g protein'),
                ],
              ),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Ghi chú: ${entry.note}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17),
      label: Text(text),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
