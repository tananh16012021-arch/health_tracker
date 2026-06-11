import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.email,
    required this.content,
    required this.mood,
    required this.createdAt,
    required this.likes,
  });

  final String id;
  final String userId;
  final String displayName;
  final String email;
  final String content;
  final String mood;
  final DateTime createdAt;
  final int likes;

  factory CommunityPost.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CommunityPost(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Health member',
      email: data['email'] as String? ?? '',
      content: data['content'] as String? ?? '',
      mood: data['mood'] as String? ?? '💪',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
    );
  }
}
