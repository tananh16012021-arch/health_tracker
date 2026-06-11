class WaterReminderSettings {
  const WaterReminderSettings({
    required this.enabled,
    required this.intervalMinutes,
    required this.startHour,
    required this.endHour,
    required this.goalMl,
  });

  final bool enabled;
  final int intervalMinutes;
  final int startHour;
  final int endHour;
  final int goalMl;

  static const defaults = WaterReminderSettings(
    enabled: false,
    intervalMinutes: 120,
    startHour: 8,
    endHour: 22,
    goalMl: 2000,
  );

  int get estimatedRemindersPerDay {
    final minutes = (endHour - startHour).clamp(1, 24).toInt() * 60;
    return (minutes / intervalMinutes).floor() + 1;
  }

  WaterReminderSettings copyWith({
    bool? enabled,
    int? intervalMinutes,
    int? startHour,
    int? endHour,
    int? goalMl,
  }) {
    return WaterReminderSettings(
      enabled: enabled ?? this.enabled,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      goalMl: goalMl ?? this.goalMl,
    );
  }
}
