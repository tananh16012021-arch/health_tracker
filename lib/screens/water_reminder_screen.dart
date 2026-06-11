import 'package:flutter/material.dart';

import '../models/health_entry.dart';
import '../models/water_reminder_settings.dart';
import '../services/health_service.dart';
import '../services/water_reminder_service.dart';
import '../utils/health_calculations.dart';
import '../widgets/section_title.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen> {
  final _goalController = TextEditingController();
  WaterReminderSettings _settings = WaterReminderSettings.defaults;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await WaterReminderService.loadSettings();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _goalController.text = '${settings.goalMl}';
      _loading = false;
    });
  }

  Future<void> _save() async {
    final goal = int.tryParse(_goalController.text.trim()) ?? _settings.goalMl;
    final fixed = _settings.copyWith(goalMl: goal.clamp(500, 6000).toInt());
    setState(() => _saving = true);
    try {
      await WaterReminderService.saveSettings(fixed);
      if (!mounted) return;
      setState(() => _settings = fixed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fixed.enabled ? 'Đã bật lịch nhắc uống nước.' : 'Đã tắt lịch nhắc uống nước.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể lưu nhắc nước: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addWater(int amount, HealthEntry? today) async {
    try {
      final now = DateTime.now();
      final entry = today == null
          ? HealthEntry(
              date: now,
              steps: 0,
              calories: 0,
              waterMl: amount,
              weightKg: 0,
              heartRate: 0,
              sleepHours: 0,
              note: 'Cập nhật nhanh lượng nước',
            )
          : today.copyWith(waterMl: today.waterMl + amount);
      await HealthService.upsertEntry(entry);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cộng $amount ml nước hôm nay.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể cập nhật nước: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nhắc uống nước')),
      body: StreamBuilder<HealthEntry?>(
        stream: HealthService.watchTodayEntry(),
        builder: (context, snapshot) {
          final today = snapshot.data;
          final water = today?.waterMl ?? 0;
          final target = _settings.goalMl;
          final progress = progressRatio(water, target);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _WaterHeroCard(
                water: water,
                target: target,
                progress: progress,
                enabled: _settings.enabled,
              ),
              const SizedBox(height: 16),
              const SectionTitle(
                title: 'Cập nhật nhanh',
                subtitle: 'Bấm để cộng lượng nước vào nhật ký hôm nay.',
              ),
              Row(
                children: [
                  Expanded(child: FilledButton.tonal(onPressed: () => _addWater(150, today), child: const Text('+150 ml'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.tonal(onPressed: () => _addWater(250, today), child: const Text('+250 ml'))),
                  const SizedBox(width: 10),
                  Expanded(child: FilledButton.tonal(onPressed: () => _addWater(500, today), child: const Text('+500 ml'))),
                ],
              ),
              const SizedBox(height: 20),
              const SectionTitle(
                title: 'Lịch nhắc',
                subtitle: 'App sẽ đặt local notification trên thiết bị theo khung giờ bạn chọn.',
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _settings.enabled,
                        title: const Text('Bật nhắc uống nước'),
                        subtitle: Text(_settings.enabled ? 'Đang bật thông báo local' : 'Đang tắt thông báo'),
                        onChanged: (value) => setState(() => _settings = _settings.copyWith(enabled: value)),
                      ),
                      const Divider(),
                      TextFormField(
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Mục tiêu nước/ngày (ml)',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _settings.intervalMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Nhắc lại mỗi',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 30, child: Text('30 phút')),
                          DropdownMenuItem(value: 60, child: Text('1 giờ')),
                          DropdownMenuItem(value: 90, child: Text('1 giờ 30 phút')),
                          DropdownMenuItem(value: 120, child: Text('2 giờ')),
                          DropdownMenuItem(value: 180, child: Text('3 giờ')),
                        ],
                        onChanged: (value) => setState(() => _settings = _settings.copyWith(intervalMinutes: value ?? 120)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _settings.startHour,
                              decoration: const InputDecoration(labelText: 'Bắt đầu'),
                              items: _hourItems(0, 22),
                              onChanged: (value) => setState(() => _settings = _settings.copyWith(startHour: value ?? 8)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _settings.endHour,
                              decoration: const InputDecoration(labelText: 'Kết thúc'),
                              items: _hourItems(1, 23),
                              onChanged: (value) => setState(() => _settings = _settings.copyWith(endHour: value ?? 22)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ước tính ${_settings.estimatedRemindersPerDay} lần nhắc/ngày từ ${_formatHour(_settings.startHour)} đến ${_formatHour(_settings.endHour)}.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_saving ? 'Đang lưu...' : 'Lưu lịch nhắc'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await WaterReminderService.showTestReminder();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi thử thông báo nhắc nước.')));
                        },
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('Gửi thử thông báo'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<DropdownMenuItem<int>> _hourItems(int start, int end) {
    return [
      for (var hour = start; hour <= end; hour++) DropdownMenuItem(value: hour, child: Text(_formatHour(hour))),
    ];
  }

  String _formatHour(int hour) => '${hour.toString().padLeft(2, '0')}:00';
}

class _WaterHeroCard extends StatelessWidget {
  const _WaterHeroCard({
    required this.water,
    required this.target,
    required this.progress,
    required this.enabled,
  });

  final int water;
  final int target;
  final double progress;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                child: Icon(Icons.water_drop_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Uống nước hôm nay',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Chip(
                label: Text(enabled ? 'Đang nhắc' : 'Chưa bật'),
                side: BorderSide.none,
                backgroundColor: Colors.white.withOpacity(0.18),
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$water / $target ml',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            progress >= 1 ? 'Đã đạt mục tiêu nước hôm nay 🎉' : 'Còn ${(target - water).clamp(0, target)} ml để đạt mục tiêu.',
            style: const TextStyle(color: Colors.white, height: 1.35),
          ),
        ],
      ),
    );
  }
}
