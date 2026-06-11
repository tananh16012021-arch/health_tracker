import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.progress,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: effectiveColor.withOpacity(0.14),
                  child: Icon(icon, color: effectiveColor),
                ),
                const Spacer(),
                if (progress != null)
                  Text('${((progress ?? 0) * 100).round()}%', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(99),
                minHeight: 8,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
