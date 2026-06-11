import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/health_entry.dart';

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({
    super.key,
    required this.entries,
    required this.valueOf,
    required this.emptyText,
    this.height = 170,
  });

  final List<HealthEntry> entries;
  final num Function(HealthEntry entry) valueOf;
  final String emptyText;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text(emptyText)),
      );
    }

    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));
    final values = sorted.map(valueOf).map((value) => value.toDouble()).toList();
    final maxValue = values.fold<double>(1, (max, value) => value > max ? value : max);
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < sorted.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: (values[i] / maxValue).clamp(0.06, 1).toDouble(),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.78),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const SizedBox(width: double.infinity),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd/MM').format(sorted[i].date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
