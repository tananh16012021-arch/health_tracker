import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'comment_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _posting = false;
  final user = FirebaseAuth.instance.currentUser;

  void _postContent() async {
    if (_controller.text.trim().isEmpty || user == null) return;

    setState(() => _posting = true);

    await FirebaseFirestore.instance.collection('posts').add({
      'content': _controller.text.trim(),
      'authorId': user!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    setState(() => _posting = false);
  }

  void _likePost(String postId) {
    if (user == null) return;

    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(user!.uid);

    likeRef.get().then((doc) {
      if (doc.exists) {
        likeRef.delete(); // unlike
      } else {
        likeRef.set({'liked': true}); // like
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cộng đồng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Chia sẻ hôm nay bạn đã làm được gì...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _posting
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _postContent,
                      ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;

                if (posts.isEmpty) {
                  return const Center(
                    child: Text('Chưa có bài đăng nào. Hãy là người đầu tiên!'),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final postId = post.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post['content'] ?? '',
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('By: ${post['authorId'] ?? ''}'),
                                Row(
                                  children: [
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(postId)
                                          .collection('likes')
                                          .snapshots(),
                                      builder: (context, likeSnapshot) {
                                        int likeCount = 0;
                                        bool isLiked = false;
                                        if (likeSnapshot.hasData) {
                                          likeCount = likeSnapshot.data!.docs.length;
                                          isLiked = likeSnapshot.data!.docs.any(
                                              (doc) => doc.id == user?.uid);
                                        }
                                        return Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => _likePost(postId),
                                            ),
                                            Text('$likeCount'),
                                          ],
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.comment, color: Colors.blue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CommentScreen(postId: postId),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(postId)
                                  .collection('comments')
                                  .snapshots(),
                              builder: (context, commentSnapshot) {
                                int commentCount = 0;
                                if (commentSnapshot.hasData) {
                                  commentCount = commentSnapshot.data!.docs.length;
                                }
                                return Text('$commentCount bình luận',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey));
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}