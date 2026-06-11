import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/blood_pressure_entry.dart';
import '../models/health_entry.dart';
import '../models/water_reminder_settings.dart';
import '../services/auth_service.dart';
import '../services/health_service.dart';
import '../services/water_reminder_service.dart';
import '../utils/health_calculations.dart';
import '../widgets/entry_tile.dart';
import '../widgets/metric_ring.dart';
import '../widgets/blood_pressure_line_chart.dart';
import '../widgets/mini_bar_chart.dart';
import '../widgets/section_title.dart';
import '../widgets/stat_card.dart';
import 'add_blood_pressure_screen.dart';
import 'add_entry_screen.dart';
import 'analytics_screen.dart';
import 'blood_pressure_screen.dart';
import 'challenges_screen.dart';
import 'export_data_screen.dart';
import 'community_feed/community_screen.dart';  
import 'nutrition_screen.dart';
import 'plans_screen.dart';
import 'profile_screen.dart';
import 'water_reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    JournalPage(),
    BloodPressurePage(),
    PlansScreen(),
     CommunityScreen(),
    ProfileScreen(),
  ];

  final _titles = const [
    'Tổng quan',
    'Nhật ký',
    'Huyết áp',
    'Kế hoạch',
    'Newfeed',
    'Hồ sơ',
  ];

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget? _buildFloatingActionButton() {
    if (_index <= 1) {
      return FloatingActionButton.extended(
        onPressed: () => _open(const AddEntryScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      );
    }

    if (_index == 2) {
      return FloatingActionButton.extended(
        onPressed: () => _open(const AddBloodPressureScreen()),
        icon: const Icon(Icons.monitor_heart_outlined),
        label: const Text('Thêm đo'),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Analytics',
            onPressed: () => _open(const AnalyticsScreen()),
            icon: const Icon(Icons.analytics_outlined),
          ),
          IconButton(
            tooltip: 'Nhắc uống nước',
            onPressed: () => _open(const WaterReminderScreen()),
            icon: const Icon(Icons.water_drop_outlined),
          ),
          IconButton(
            tooltip: 'Export dữ liệu',
            onPressed: () => _open(const ExportDataScreen()),
            icon: const Icon(Icons.ios_share_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'nutrition':
                  _open(const NutritionScreen());
                  break;
                case 'challenge':
                  _open(const ChallengesScreen());
                  break;
                case 'water':
                  _open(const WaterReminderScreen());
                  break;
                case 'export':
                  _open(const ExportDataScreen());
                  break;
                case 'logout':
                  AuthService.signOut();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'nutrition', child: Text('Nutrition & barcode')),
              PopupMenuItem(value: 'challenge', child: Text('Challenges')),
              PopupMenuItem(value: 'water', child: Text('Nhắc uống nước')),
              PopupMenuItem(value: 'export', child: Text('Export / gửi bác sĩ')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
            ],
          ),
        ],
      ),
      body: _pages[_index],
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: 'BP'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<List<HealthEntry>>(
      stream: HealthService.watchRecentEntries(days: 7),
      builder: (context, weekSnapshot) {
        final entries = weekSnapshot.data ?? [];
        final today = _todayFrom(entries);
        final steps = today?.steps ?? 0;
        final water = today?.waterMl ?? 0;
        final sleep = today?.sleepHours ?? 0;
        final calories = today?.calories ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroCard(
              name: user?.displayName?.trim().isNotEmpty == true ? user!.displayName! : 'Bạn',
              insight: insightForToday(today),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MetricRing(
                    progress: progressRatio(steps, 10000),
                    label: 'Bước chân',
                    value: '$steps',
                    icon: Icons.directions_walk,
                  ),
                ),
                Expanded(
                  child: MetricRing(
                    progress: progressRatio(water, 2000),
                    label: 'Nước',
                    value: '${water}ml',
                    icon: Icons.water_drop_outlined,
                  ),
                ),
                Expanded(
                  child: MetricRing(
                    progress: progressRatio(sleep, 8),
                    label: 'Ngủ',
                    value: '${sleep.toStringAsFixed(1)}h',
                    icon: Icons.bedtime_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _WaterReminderSummary(today: today),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 640;
                final cards = [
                  StatCard(title: 'Calories', value: '$calories kcal', icon: Icons.local_fire_department, progress: progressRatio(calories, 2200)),
                  StatCard(title: 'Tập luyện', value: '${today?.workoutMinutes ?? 0} phút', icon: Icons.fitness_center, progress: progressRatio(today?.workoutMinutes ?? 0, 45)),
                  StatCard(title: 'Protein', value: '${today?.proteinGrams ?? 0}g', icon: Icons.egg_alt_outlined, progress: progressRatio(today?.proteinGrams ?? 0, 100)),
                  StatCard(title: 'Nhịp tim', value: '${today?.heartRate ?? 0} bpm', icon: Icons.favorite_border, subtitle: 'Theo dõi thủ công'),
                ];
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 4 : 2,
                  childAspectRatio: isWide ? 1.15 : 1.05,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: cards,
                );
              },
            ),
            const SizedBox(height: 20),
            SectionTitle(
              title: 'Bước chân 7 ngày',
              subtitle: 'Theo dõi xu hướng giống màn analytics trong app mẫu',
              trailing: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
                child: const Text('Xem thêm'),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MiniBarChart(
                  entries: entries,
                  valueOf: (entry) => entry.steps,
                  emptyText: 'Chưa có dữ liệu tuần này',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _BloodPressureSummaryCard(),
            const SizedBox(height: 20),
            const _QuickActions(),
          ],
        );
      },
    );
  }

  HealthEntry? _todayFrom(List<HealthEntry> entries) {
    final now = DateTime.now();
    for (final entry in entries) {
      if (entry.date.year == now.year && entry.date.month == now.month && entry.date.day == now.day) {
        return entry;
      }
    }
    return null;
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.name, required this.insight});

  final String name;
  final String insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.18),
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const Text('Health Tracker Pro', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Xin chào, $name 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(insight, style: const TextStyle(color: Colors.white, height: 1.35)),
        ],
      ),
    );
  }
}



class _WaterReminderSummary extends StatelessWidget {
  const _WaterReminderSummary({required this.today});

  final HealthEntry? today;

  Future<void> _addWater(BuildContext context, int amount) async {
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
        : today!.copyWith(waterMl: today!.waterMl + amount);

    await HealthService.upsertEntry(entry);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cộng $amount ml nước.')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WaterReminderSettings>(
      future: WaterReminderService.loadSettings(),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? WaterReminderSettings.defaults;
        final water = today?.waterMl ?? 0;
        final target = settings.goalMl;
        final progress = progressRatio(water, target);
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.12),
                    foregroundColor: colorScheme.primary,
                    child: const Icon(Icons.water_drop_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nhắc uống nước', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          settings.enabled
                              ? 'Đang nhắc mỗi ${settings.intervalMinutes} phút'
                              : 'Chưa bật lịch nhắc hằng ngày',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WaterReminderScreen())),
                    child: const Text('Cài đặt'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$water/$target ml', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addWater(context, 250),
                      icon: const Icon(Icons.add),
                      label: const Text('+250 ml'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WaterReminderScreen())),
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Mở nhắc'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BloodPressureSummaryCard extends StatelessWidget {
  const _BloodPressureSummaryCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BloodPressureEntry>>(
      stream: HealthService.watchRecentBloodPressureEntries(days: 14),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];
        final latest = entries.isEmpty ? null : entries.last;
        final highCount = entries.where((entry) => entry.isHigh).length;
        final statusColor = latest?.isHigh == true
            ? Colors.red.shade700
            : latest?.isElevated == true
                ? Colors.orange.shade800
                : Theme.of(context).colorScheme.primary;

        return Card(
          color: latest?.isHigh == true ? const Color(0xFFFFF5F5) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.12),
                      foregroundColor: statusColor,
                      child: const Icon(Icons.monitor_heart_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Huyết áp', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            latest == null
                                ? 'Chưa có dữ liệu đo'
                                : '${latest.systolic}/${latest.diastolic} mmHg • ${latest.pulse} bpm • ${latest.statusLabel}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BloodPressureScreen())),
                      child: const Text('Mở'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                BloodPressureLineChart(entries: entries, compact: true),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        highCount > 0
                            ? '$highCount lần vượt mốc 140/90 trong dữ liệu gần đây.'
                            : 'Ngưỡng cảnh báo: ≥ 140/90 mmHg.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddBloodPressureScreen())),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm đo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Chức năng nâng cấp'),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _ActionCard(title: 'Analytics', icon: Icons.analytics_outlined, onTap: () => _push(context, const AnalyticsScreen())),
            _ActionCard(title: 'Nhắc nước', icon: Icons.water_drop_outlined, onTap: () => _push(context, const WaterReminderScreen())),
            _ActionCard(title: 'Export dữ liệu', icon: Icons.ios_share_outlined, onTap: () => _push(context, const ExportDataScreen())),
            _ActionCard(title: 'Huyết áp', icon: Icons.monitor_heart_outlined, onTap: () => _push(context, const BloodPressureScreen())),
            _ActionCard(title: 'Nutrition', icon: Icons.restaurant_menu, onTap: () => _push(context, const NutritionScreen())),
            _ActionCard(title: 'Challenges', icon: Icons.emoji_events_outlined, onTap: () => _push(context, const ChallengesScreen())),
            _ActionCard(title: 'Community', icon: Icons.forum_outlined, onTap: () => _push(context, const CommunityScreen())),
          ],
        ),
      ],
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.title, required this.icon, required this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HealthEntry>>(
      stream: HealthService.watchEntries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data ?? [];
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Chưa có nhật ký', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Bấm nút Thêm để ghi lại bước chân, nước, ngủ, calories và tập luyện.'),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return EntryTile(
              entry: entry,
              onEdit: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEntryScreen(entry: entry))),
              onDelete: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa nhật ký?'),
                    content: const Text('Dữ liệu này sẽ bị xóa khỏi Firestore.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
                      FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xóa')),
                    ],
                  ),
                );
                if (shouldDelete == true && entry.id != null) {
                  await HealthService.deleteEntry(entry.id!);
                }
              },
            );
          },
        );
      },
    );
  }
}
