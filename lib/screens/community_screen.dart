import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/community_post.dart';
import '../services/health_service.dart';
import '../widgets/section_title.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _controller = TextEditingController();
  String _mood = '💪';
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() => _posting = true);
    try {
      await HealthService.publishCommunityPost(content: content, mood: _mood);
      _controller.clear();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã đăng lên community feed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể đăng bài: $e')));
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navigator.canPop(context) ? AppBar(title: const Text('Community')) : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(
            title: 'Community feed',
            subtitle: 'Người dùng chia sẻ tiến độ, động lực và thói quen lành mạnh.',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: _mood,
                        items: const [
                          DropdownMenuItem(value: '💪', child: Text('💪')),
                          DropdownMenuItem(value: '🔥', child: Text('🔥')),
                          DropdownMenuItem(value: '🥗', child: Text('🥗')),
                          DropdownMenuItem(value: '😴', child: Text('😴')),
                        ],
                        onChanged: (value) => setState(() => _mood = value ?? '💪'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Chia sẻ hôm nay bạn đã làm được gì...',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _posting ? null : _post,
                    icon: const Icon(Icons.send),
                    label: Text(_posting ? 'Đang đăng...' : 'Đăng bài'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          StreamBuilder<List<CommunityPost>>(
            stream: HealthService.watchCommunityPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
              }
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Chưa có bài đăng. Hãy là người đầu tiên chia sẻ tiến độ.'),
                  ),
                );
              }
              return Column(
                children: [
                  for (final post in posts) _PostCard(post: post),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM HH:mm').format(post.createdAt);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(post.mood)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(date, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => HealthService.likeCommunityPost(post.id),
                  icon: const Icon(Icons.favorite_border),
                  label: Text('${post.likes}'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment_outlined),
                  label: const Text('Comment demo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
