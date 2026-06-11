import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService._();

  static Future<String> uploadAvatar(XFile file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User is not logged in');
    }

    final extension = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final ref = FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child(user.uid)
        .child('avatar-${DateTime.now().millisecondsSinceEpoch}.$extension');

    final bytes = await file.readAsBytes();
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}
