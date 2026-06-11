import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/blood_pressure_entry.dart';
import '../models/community_post.dart';
import '../models/health_entry.dart';

class HealthService {
  HealthService._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User is not logged in');
    }
    return user.uid;
  }

  static String get currentUserId => _uid;

  static User get _user {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User is not logged in');
    }
    return user;
  }

  static CollectionReference<Map<String, dynamic>> get _entriesRef {
    return _db.collection('users').doc(_uid).collection('health_entries');
  }

  static DocumentReference<Map<String, dynamic>> get _profileRef {
    return _db.collection('users').doc(_uid).collection('profile').doc('main');
  }

  static CollectionReference<Map<String, dynamic>> get _communityRef {
    return _db.collection('community_posts');
  }

  static CollectionReference<Map<String, dynamic>> get _bloodPressureRef {
    return _db.collection('blood_pressure');
  }

  static Stream<List<HealthEntry>> watchEntries() {
    return _entriesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(HealthEntry.fromDocument).toList());
  }

  static Stream<List<HealthEntry>> watchRecentEntries({int days = 14}) {
    final start = DateTime.now().subtract(Duration(days: days - 1));
    final startOfDay = DateTime(start.year, start.month, start.day);
    return _entriesRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(HealthEntry.fromDocument).toList());
  }

  static Stream<HealthEntry?> watchTodayEntry() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return _entriesRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return HealthEntry.fromDocument(snapshot.docs.first);
    });
  }

  static Future<void> addEntry(HealthEntry entry) async {
    await _entriesRef.add(entry.toMap());
  }

  static Future<void> updateEntry(HealthEntry entry) async {
    if (entry.id == null) {
      throw ArgumentError('Entry id is required for update');
    }
    await _entriesRef.doc(entry.id).update(entry.toMap());
  }

  static Future<void> upsertEntry(HealthEntry entry) async {
    if (entry.id == null) {
      await addEntry(entry);
    } else {
      await updateEntry(entry);
    }
  }

  static Future<void> deleteEntry(String id) async {
    await _entriesRef.doc(id).delete();
  }

  static Future<List<HealthEntry>> fetchEntries({int days = 90}) async {
    final start = DateTime.now().subtract(Duration(days: days - 1));
    final startOfDay = DateTime(start.year, start.month, start.day);
    final snapshot = await _entriesRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('date', descending: false)
        .get();
    return snapshot.docs.map(HealthEntry.fromDocument).toList();
  }

  static Stream<List<BloodPressureEntry>> watchBloodPressureEntries() {
    return _bloodPressureRef
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs.map(BloodPressureEntry.fromDocument).toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    });
  }

  static Stream<List<BloodPressureEntry>> watchRecentBloodPressureEntries({int days = 14}) {
    final start = DateTime.now().subtract(Duration(days: days - 1));
    final startOfDay = DateTime(start.year, start.month, start.day);
    return _bloodPressureRef
        .where('userId', isEqualTo: _uid)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .map(BloodPressureEntry.fromDocument)
          .where((entry) => !entry.date.isBefore(startOfDay))
          .toList();
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    });
  }

  static Future<void> addBloodPressureEntry(BloodPressureEntry entry) async {
    await _bloodPressureRef.add(entry.toMap());
  }

  static Future<void> updateBloodPressureEntry(BloodPressureEntry entry) async {
    if (entry.id == null) {
      throw ArgumentError('Blood pressure entry id is required for update');
    }
    await _bloodPressureRef.doc(entry.id).update(entry.toUpdateMap());
  }

  static Future<void> upsertBloodPressureEntry(BloodPressureEntry entry) async {
    if (entry.id == null) {
      await addBloodPressureEntry(entry);
    } else {
      await updateBloodPressureEntry(entry);
    }
  }

  static Future<void> deleteBloodPressureEntry(String id) async {
    await _bloodPressureRef.doc(id).delete();
  }

  static Future<List<BloodPressureEntry>> fetchBloodPressureEntries({int days = 90}) async {
    final start = DateTime.now().subtract(Duration(days: days - 1));
    final startOfDay = DateTime(start.year, start.month, start.day);
    final snapshot = await _bloodPressureRef.where('userId', isEqualTo: _uid).get();
    final entries = snapshot.docs
        .map(BloodPressureEntry.fromDocument)
        .where((entry) => !entry.date.isBefore(startOfDay))
        .toList();
    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  static Future<void> saveProfile({
    required String name,
    required int age,
    required double heightCm,
    required String goal,
    required int goalSteps,
    required int goalWaterMl,
    required double goalSleepHours,
    required int goalCalories,
    String? avatarUrl,
  }) async {
    await _profileRef.set({
      'name': name,
      'age': age,
      'heightCm': heightCm,
      'goal': goal,
      'goalSteps': goalSteps,
      'goalWaterMl': goalWaterMl,
      'goalSleepHours': goalSleepHours,
      'goalCalories': goalCalories,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchProfile() {
    return _profileRef.snapshots();
  }

  static Future<void> publishCommunityPost({
    required String content,
    required String mood,
  }) async {
    final user = _user;
    await _communityRef.add({
      'userId': user.uid,
      'displayName': user.displayName?.trim().isNotEmpty == true ? user.displayName : 'Health member',
      'email': user.email ?? '',
      'content': content,
      'mood': mood,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<CommunityPost>> watchCommunityPosts() {
    return _communityRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(CommunityPost.fromDocument).toList());
  }

  static Future<void> likeCommunityPost(String postId) async {
    await _communityRef.doc(postId).update({'likes': FieldValue.increment(1)});
  }
}
