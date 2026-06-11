# QUICK RUN WINDOWS

Mở terminal tại thư mục có `pubspec.yaml` rồi chạy:

```bash
flutter create .
flutter pub get
flutterfire configure
flutter run -d chrome
```

Nếu chạy Android emulator:

```bash
flutter devices
flutter run -d emulator-5554
```

Nếu bị lỗi Firebase options, chạy lại:

```bash
flutterfire configure
```

Nếu bị permission denied ở Firestore/Storage, cập nhật rules từ file:

- `firestore.rules`
- `storage.rules`
