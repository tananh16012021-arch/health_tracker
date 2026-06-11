# Health Tracker Pro - Flutter Firebase

Bản này đã được nâng cấp từ project `health_tracker_rebuild_flutter344` theo hướng giống repo mẫu `AnisDhia/health_tracker`: app theo dõi sức khỏe, gamification, workout/diet plan, community feed, Firebase Auth/Firestore/Storage và phần nutrition/barcode demo.

## Điểm nâng cấp chính

- Dashboard mới đẹp hơn: hero card, vòng tiến độ, stat cards, insight, quick actions.
- Nhật ký sức khỏe nâng cấp: thêm/sửa/xóa entry, có mood, phút tập luyện, protein.
- Analytics 14 ngày: biểu đồ bước chân, nước uống, giấc ngủ và thống kê tổng quan.
- Workout plans: danh sách bài tập mẫu, level, calories, danh sách động tác.
- Nutrition: recipes có macro P/C/F, barcode lookup demo offline.
- Challenges: tự tính tiến độ theo dữ liệu 7 ngày gần nhất.
- Community feed: đăng bài, like bài viết, đọc feed từ Firestore.
- Profile nâng cấp: avatar Firebase Storage, thông tin cá nhân, daily goals.
- Rules Firestore/Storage đã cập nhật thêm collection `community_posts`.
- Module huyết áp mới: nhập tâm thu/tâm trương/nhịp tim, ghi chú triệu chứng, biểu đồ line 7-14 ngày và cảnh báo mốc 140/90 mmHg.
- Firestore top-level collection `blood_pressure` theo cấu trúc `userId`, `systolic`, `diastolic`, `pulse`, `date`, `note`, `mood`.

- Nhắc uống nước: cài mục tiêu ml/ngày, khoảng nhắc 30–180 phút, khung giờ bắt đầu/kết thúc, gửi thử notification và cập nhật nhanh +150/+250/+500 ml.
- Export/share dữ liệu cho bác sĩ: xuất CSV gồm nhật ký sức khỏe + huyết áp, chia sẻ qua Gmail/Email/Zalo và mở mẫu email tóm tắt gửi bác sĩ.
- UI polish mới: theme Material 3 mềm hơn, dashboard có card nhắc nước, quick actions mở nhanh Water Reminder và Export.

## Cấu trúc chính

```text
lib/
  main.dart
  firebase_options.dart
  models/
    health_entry.dart
    recipe.dart
    workout.dart
    food_product.dart
    community_post.dart
    blood_pressure_entry.dart
    water_reminder_settings.dart
  services/
    auth_service.dart
    health_service.dart
    storage_service.dart
    export_service.dart
    water_reminder_service.dart
  screens/
    auth_gate.dart
    login_screen.dart
    register_screen.dart
    home_screen.dart
    add_entry_screen.dart
    add_blood_pressure_screen.dart
    blood_pressure_screen.dart
    water_reminder_screen.dart
    export_data_screen.dart
    analytics_screen.dart
    plans_screen.dart
    nutrition_screen.dart
    challenges_screen.dart
    community_screen.dart
    profile_screen.dart
  widgets/
    stat_card.dart
    entry_tile.dart
    metric_ring.dart
    mini_bar_chart.dart
    blood_pressure_line_chart.dart
    section_title.dart
  utils/
    health_calculations.dart
```

## Cách chạy trên Windows

### 1. Giải nén project

Mở đúng thư mục chứa `pubspec.yaml` bằng VS Code hoặc Android Studio.

### 2. Tạo thư mục platform nếu project chưa có `android/`, `web/`

```bash
flutter create .
```

### 3. Cài dependencies

```bash
flutter pub get
```

### 4. Cấu hình Firebase

Bật các dịch vụ trong Firebase Console:

1. Authentication → Email/Password → Enable.
2. Firestore Database → Create database.
3. Storage → Get started/Create bucket.

Cài FlutterFire CLI nếu chưa có:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Lệnh `flutterfire configure` sẽ thay file placeholder `lib/firebase_options.dart` bằng file thật.

### 5. Cập nhật rules

Copy nội dung trong `firestore.rules` và `storage.rules` lên Firebase Console, hoặc deploy bằng Firebase CLI nếu bạn dùng CLI.

### 6. Chạy app

Chrome:

```bash
flutter run -d chrome
```

Android emulator:

```bash
flutter devices
flutter run -d emulator-5554
```

Nếu device id khác, thay `emulator-5554` bằng id hiện trên máy bạn.

## Dữ liệu Firestore

```text
users/{uid}/health_entries/{entryId}
users/{uid}/profile/main
blood_pressure/{entryId}
community_posts/{postId}
```

Ví dụ `health_entries`:

```json
{
  "date": "Timestamp",
  "steps": 8000,
  "calories": 1800,
  "waterMl": 2000,
  "weightKg": 60,
  "heartRate": 75,
  "sleepHours": 7,
  "workoutMinutes": 30,
  "proteinGrams": 80,
  "mood": "Tốt",
  "note": "Hôm nay tập nhẹ"
}
```



Ví dụ `blood_pressure`:

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

Ghi chú module huyết áp:

- Màn `BP` nằm trực tiếp ở bottom navigation.
- Dashboard có widget huyết áp mini và nút `Thêm đo`.
- Màn huyết áp có thống kê gần nhất, trung bình, số lần vượt ngưỡng và lịch sử đo.
- Biểu đồ line được vẽ bằng `CustomPainter` để không phải thêm dependency ngoài; nếu muốn đổi sang `fl_chart`, có thể thay widget `lib/widgets/blood_pressure_line_chart.dart`.
- App đánh dấu cảnh báo khi `systolic >= 140` hoặc `diastolic >= 90`.

Ví dụ `community_posts`:

```json
{
  "userId": "uid",
  "displayName": "Health member",
  "email": "user@email.com",
  "content": "Hôm nay hoàn thành 10k bước!",
  "mood": "💪",
  "likes": 0,
  "createdAt": "Timestamp"
}
```


## Nhắc uống nước

- Mở icon giọt nước trên AppBar hoặc card `Nhắc nước` ở Dashboard.
- Bật/tắt local notification, đặt mục tiêu nước/ngày, chọn khoảng nhắc và khung giờ.
- Có nút `Gửi thử thông báo` để kiểm tra quyền notification trên Android/iOS.
- Lượng nước vẫn lưu vào `users/{uid}/health_entries` qua trường `waterMl`, không tạo collection mới.

## Export/share gửi bác sĩ

- Mở icon share trên AppBar hoặc card `Export dữ liệu`.
- Chọn 7/14/30/90/180 ngày gần nhất.
- Bấm `Tạo file CSV & chia sẻ`, sau đó chọn Gmail/Email để gửi file cho bác sĩ.
- Nút `Soạn email tóm tắt` mở app email với nội dung tóm tắt; file CSV nên gửi bằng nút share CSV vì `mailto` không hỗ trợ attachment ổn định trên mọi thiết bị.

Các package đã thêm cho phần này:

```yaml
shared_preferences
path_provider
share_plus
url_launcher
flutter_local_notifications
timezone
```

## Lưu ý

- Barcode hiện là demo offline để dễ chạy bài nộp. Muốn dùng camera thật có thể thêm package `mobile_scanner` sau.
- Recipe/API hiện dùng dữ liệu mẫu để không cần API key. Có thể nối Open Food Facts hoặc Spoonacular sau.
- Nếu Firestore báo lỗi index ở `watchRecentEntries`, bấm link Firebase gợi ý để tạo index hoặc đổi query về orderBy đơn giản.
- Module huyết áp đang query theo `where('userId')` rồi sort/filter trong app để dễ chạy, hạn chế lỗi thiếu composite index khi mới test Firebase.
