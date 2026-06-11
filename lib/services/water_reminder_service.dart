import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/water_reminder_settings.dart';

class WaterReminderService {
  WaterReminderService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const int _notificationBaseId = 4200;
  static const int _maxScheduledNotifications = 64;

  static const _enabledKey = 'water_reminder_enabled';
  static const _intervalKey = 'water_reminder_interval_minutes';
  static const _startHourKey = 'water_reminder_start_hour';
  static const _endHourKey = 'water_reminder_end_hour';
  static const _goalKey = 'water_reminder_goal_ml';

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));

    final settings = await loadSettings();
    if (settings.enabled) {
      await schedule(settings);
    }
  }

  static Future<WaterReminderSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = WaterReminderSettings.defaults;
    final startHour = prefs.getInt(_startHourKey) ?? defaults.startHour;
    final endHour = prefs.getInt(_endHourKey) ?? defaults.endHour;

    return WaterReminderSettings(
      enabled: prefs.getBool(_enabledKey) ?? defaults.enabled,
      intervalMinutes: prefs.getInt(_intervalKey) ?? defaults.intervalMinutes,
      startHour: startHour.clamp(0, 23).toInt(),
      endHour: endHour.clamp(1, 23).toInt(),
      goalMl: prefs.getInt(_goalKey) ?? defaults.goalMl,
    );
  }

  static Future<void> saveSettings(WaterReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final fixedEndHour = settings.endHour <= settings.startHour ? settings.startHour + 1 : settings.endHour;
    final normalized = settings.copyWith(endHour: fixedEndHour.clamp(1, 23).toInt());

    await prefs.setBool(_enabledKey, normalized.enabled);
    await prefs.setInt(_intervalKey, normalized.intervalMinutes);
    await prefs.setInt(_startHourKey, normalized.startHour.clamp(0, 22).toInt());
    await prefs.setInt(_endHourKey, normalized.endHour.clamp(1, 23).toInt());
    await prefs.setInt(_goalKey, normalized.goalMl.clamp(500, 6000).toInt());

    if (normalized.enabled) {
      await schedule(normalized);
    } else {
      await cancelAll();
    }
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission() ?? true;
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    return androidGranted && iosGranted;
  }

  static Future<void> schedule(WaterReminderSettings settings) async {
    await cancelAll();
    if (!settings.enabled) return;

    await requestPermission();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledCount = 0;

    for (var dayOffset = 0; dayOffset < 14; dayOffset++) {
      if (scheduledCount >= _maxScheduledNotifications) break;
      final day = now.add(Duration(days: dayOffset));
      var cursor = tz.TZDateTime(tz.local, day.year, day.month, day.day, settings.startHour);
      final end = tz.TZDateTime(tz.local, day.year, day.month, day.day, settings.endHour);

      while (!cursor.isAfter(end) && scheduledCount < _maxScheduledNotifications) {
        if (cursor.isAfter(now)) {
          await _plugin.zonedSchedule(
            _notificationBaseId + scheduledCount,
            'Đến giờ uống nước 💧',
            'Uống một ly nước và cập nhật lượng nước trong Health Tracker nhé.',
            cursor,
            _notificationDetails(),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          );
          scheduledCount++;
        }
        cursor = cursor.add(Duration(minutes: settings.intervalMinutes));
      }
    }
  }

  static Future<void> showTestReminder() async {
    await requestPermission();
    await _plugin.show(
      _notificationBaseId - 1,
      'Test nhắc uống nước 💧',
      'Thông báo hoạt động rồi. Bạn có thể bật lịch nhắc hằng ngày.',
      _notificationDetails(),
    );
  }

  static Future<void> cancelAll() async {
    for (var i = 0; i < _maxScheduledNotifications; i++) {
      await _plugin.cancel(_notificationBaseId + i);
    }
  }

  static NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      'water_reminders',
      'Nhắc uống nước',
      channelDescription: 'Thông báo nhắc uống nước theo lịch người dùng cài đặt.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'water reminder',
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }
}