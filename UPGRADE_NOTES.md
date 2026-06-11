# Upgrade Notes

Project đã được nâng cấp theo hướng giống repo `AnisDhia/health_tracker` nhưng giữ cấu trúc gọn, dễ chạy với Flutter/Firebase hiện đại.

## Đã thêm

1. Dashboard mới với hero card, vòng tiến độ, stat cards và biểu đồ mini.
2. Nhật ký sức khỏe có thêm mood, workout minutes, protein grams, edit entry.
3. Analytics 14 ngày cho steps, water, sleep và summary stats.
4. Workout plans và quick plan hub.
5. Nutrition recipes + barcode lookup demo offline.
6. Challenges tính tiến độ tự động theo dữ liệu 7 ngày.
7. Community feed dùng Firestore `community_posts`.
8. Profile goals: steps, water, sleep, calories.
9. Firestore/Storage rules mới.
10. Module huyết áp đầy đủ: model, Firestore service, add/edit/delete, chart line, dashboard card và tab BP.
11. Module nhắc uống nước bằng local notification, có quick add +150/+250/+500 ml và lưu mục tiêu bằng SharedPreferences.
12. Module export/share dữ liệu CSV + email summary để gửi bác sĩ.
13. Nâng UI theme Material 3, dashboard thêm water reminder card và quick action mới.

## File quan trọng đã sửa/thêm

- `lib/main.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/add_entry_screen.dart`
- `lib/screens/analytics_screen.dart`
- `lib/screens/plans_screen.dart`
- `lib/screens/nutrition_screen.dart`
- `lib/screens/challenges_screen.dart`
- `lib/screens/community_screen.dart`
- `lib/screens/profile_screen.dart`
- `lib/screens/add_blood_pressure_screen.dart`
- `lib/screens/blood_pressure_screen.dart`
- `lib/screens/water_reminder_screen.dart`
- `lib/screens/export_data_screen.dart`
- `lib/models/*`
- `lib/models/blood_pressure_entry.dart`
- `lib/widgets/*`
- `lib/widgets/blood_pressure_line_chart.dart`
- `lib/utils/health_calculations.dart`
- `lib/services/health_service.dart`
- `lib/services/water_reminder_service.dart`
- `lib/services/export_service.dart`
- `firestore.rules`
- `storage.rules`

## Gợi ý phát triển tiếp

- Thêm Google Sign-In.
- Nối Open Food Facts/Spoonacular thật.
- Thêm camera barcode bằng `mobile_scanner`.
- Thêm pedometer để đếm bước chân tự động.
- Thêm comment thật trong community feed.


## Module huyết áp mới

Firestore collection: `blood_pressure`

```json
{
  "userId": "uid",
  "systolic": 120,
  "diastolic": 80,
  "pulse": 72,
  "date": "Timestamp",
  "mood": "Bình thường",
  "note": "Morning measurement"
}
```

Luồng sử dụng:

1. Đăng nhập Firebase Auth.
2. Vào tab `BP` ở bottom navigation.
3. Bấm `Thêm đo` để nhập tâm thu, tâm trương, pulse, ngày giờ và ghi chú.
4. Dữ liệu lưu vào Firestore collection `blood_pressure` kèm `userId`.
5. Dashboard và màn BP tự cập nhật chart 7-14 ngày.

Mốc cảnh báo UI: `systolic >= 140` hoặc `diastolic >= 90`.


## Module nhắc uống nước

- File chính: `lib/screens/water_reminder_screen.dart`, `lib/services/water_reminder_service.dart`, `lib/models/water_reminder_settings.dart`.
- Lưu setting local bằng `shared_preferences`.
- Đặt notification bằng `flutter_local_notifications`, lịch được refresh khi app khởi động hoặc khi người dùng lưu setting.
- Android đã thêm `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED` và receiver scheduled notification trong `AndroidManifest.xml`.

## Module export/share gửi bác sĩ

- File chính: `lib/screens/export_data_screen.dart`, `lib/services/export_service.dart`.
- `HealthService` có thêm `fetchEntries()` và `fetchBloodPressureEntries()` để lấy dữ liệu theo số ngày.
- CSV nằm trong thư mục temp rồi gọi `share_plus` để người dùng chọn Gmail/Email/Zalo.
- `url_launcher` mở `mailto:` để soạn email tóm tắt nhanh.
