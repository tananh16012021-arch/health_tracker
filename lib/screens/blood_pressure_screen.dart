import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/blood_pressure_entry.dart';
import '../services/health_service.dart';
import '../widgets/blood_pressure_line_chart.dart';
import '../widgets/section_title.dart';
import 'add_blood_pressure_screen.dart';

class BloodPressureScreen extends StatelessWidget {
  const BloodPressureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Huyết áp')),
      body: const BloodPressurePage(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddBloodPressureScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Thêm đo'),
      ),
    );
  }
}

class BloodPressurePage extends StatelessWidget {
  const BloodPressurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BloodPressureEntry>>(
      stream: HealthService.watchBloodPressureEntries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data ?? [];
        final recent = [...entries]
          ..sort((a, b) => a.date.compareTo(b.date));
        final last14 = recent.length > 14 ? recent.sublist(recent.length - 14) : recent;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const SectionTitle(
              title: 'Theo dõi huyết áp',
              subtitle: 'Lưu tâm thu, tâm trương, nhịp tim và ghi chú triệu chứng.',
            ),
            _SummaryHeader(entries: entries),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Biểu đồ 7-14 lần đo gần nhất', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Đường cam đứt đoạn là ngưỡng cảnh báo 140/90 mmHg.', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    BloodPressureLineChart(entries: last14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(
              title: 'Lịch sử đo',
              trailing: TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddBloodPressureScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
              ),
            ),
            if (entries.isEmpty)
              const _EmptyBloodPressure()
            else
              ...entries.map((entry) => _BloodPressureTile(entry: entry)),
          ],
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.entries});

  final List<BloodPressureEntry> entries;

  @override
  Widget build(BuildContext context) {
    final latest = entries.isEmpty ? null : entries.first;
    final highCount = entries.where((entry) => entry.isHigh).length;
    final avgSystolic = entries.isEmpty ? 0 : entries.map((e) => e.systolic).reduce((a, b) => a + b) / entries.length;
    final avgDiastolic = entries.isEmpty ? 0 : entries.map((e) => e.diastolic).reduce((a, b) => a + b) / entries.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 640;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: wide ? 4 : 2,
          childAspectRatio: wide ? 1.45 : 1.18,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _BpStatCard(
              title: 'Gần nhất',
              value: latest == null ? '-' : '${latest.systolic}/${latest.diastolic}',
              subtitle: latest == null ? 'mmHg' : '${latest.pulse} bpm • ${latest.statusLabel}',
              icon: Icons.monitor_heart_outlined,
              danger: latest?.isHigh == true,
            ),
            _BpStatCard(
              title: 'Trung bình',
              value: entries.isEmpty ? '-' : '${avgSystolic.toStringAsFixed(0)}/${avgDiastolic.toStringAsFixed(0)}',
              subtitle: 'trên ${entries.length} lần đo',
              icon: Icons.insights_outlined,
            ),
            _BpStatCard(
              title: 'Cảnh báo',
              value: '$highCount',
              subtitle: 'lần ≥ 140/90',
              icon: Icons.warning_amber_rounded,
              danger: highCount > 0,
            ),
            _BpStatCard(
              title: 'Collection',
              value: 'blood_pressure',
              subtitle: 'Firestore top-level',
              icon: Icons.cloud_done_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _BpStatCard extends StatelessWidget {
  const _BpStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.danger = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final foreground = danger ? Colors.red.shade700 : Theme.of(context).colorScheme.primary;
    return Card(
      color: danger ? const Color(0xFFFFEBEE) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: foreground),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: foreground)),
            ),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BloodPressureTile extends StatelessWidget {
  const _BloodPressureTile({required this.entry});

  final BloodPressureEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd/MM/yyyy HH:mm').format(entry.date);
    final statusColor = entry.isHigh ? Colors.red.shade700 : entry.isElevated ? Colors.orange.shade800 : Theme.of(context).colorScheme.primary;

    return Card(
      color: entry.isHigh ? const Color(0xFFFFF5F5) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.12),
          foregroundColor: statusColor,
          child: Icon(entry.isHigh ? Icons.warning_amber_rounded : Icons.favorite_border),
        ),
        title: Text('${entry.systolic}/${entry.diastolic} mmHg', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$dateText • ${entry.pulse} bpm • ${entry.mood}${entry.note.isEmpty ? '' : '\n${entry.note}'}'),
        isThreeLine: entry.note.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddBloodPressureScreen(entry: entry)));
              return;
            }
            if (value == 'delete' && entry.id != null) {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa lần đo?'),
                  content: const Text('Dữ liệu huyết áp này sẽ bị xóa khỏi Firestore.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
                    FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xóa')),
                  ],
                ),
              );
              if (shouldDelete == true) {
                await HealthService.deleteBloodPressureEntry(entry.id!);
              }
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Sửa')),
            PopupMenuItem(value: 'delete', child: Text('Xóa')),
          ],
        ),
      ),
    );
  }
}

class _EmptyBloodPressure extends StatelessWidget {
  const _EmptyBloodPressure();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.monitor_heart_outlined, size: 60, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text('Chưa có dữ liệu huyết áp', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Bấm Thêm để lưu tâm thu, tâm trương, nhịp tim và ghi chú.'),
          ],
        ),
      ),
    );
  }
}
