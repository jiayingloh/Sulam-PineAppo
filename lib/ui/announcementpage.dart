import 'package:flutter/material.dart';
import '../api/announcement_service.dart';
import '../services/session.dart';
import '../services/config.dart';

class AnnouncementPage extends StatefulWidget {
  final Map<String, dynamic> announcement;
  const AnnouncementPage({super.key, required this.announcement});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final AnnouncementService announcementService = AnnouncementService();
  final TextEditingController commentController = TextEditingController();
  late Map<String, dynamic> announcement;
  bool isLiked = false;
  bool _likeInProgress = false;

  @override
  void initState() {
    super.initState();
    announcement = widget.announcement;
  }

  // --- Base URL for relative images ---
  final String baseUrl = AppConfig.baseUrl; // Android emulator localhost
  String _getImageUrl(String photoPath) {
    if (photoPath.isEmpty) return '';
    if (photoPath.startsWith("http")) return photoPath;  
    return "$baseUrl/$photoPath";
  }

  void sendComment() async {
    final commentText = commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final int anounId = int.parse(announcement['anounID'].toString());
      final int? currentAcc = CurrentUser.accID;
      if (currentAcc == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to comment')),
          );
        }
        return;
      }

      debugPrint('Sending comment; anounId=$anounId, accID=$currentAcc, text=${commentText.length} chars');

      Map<String, dynamic> resp;
      try {
        resp = await announcementService.sendComment(
          anounID: anounId,
          accID: currentAcc,
          comment: commentText,
        );
      } catch (e) {
        debugPrint('sendComment failed: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send comment: $e')),
          );
        }
        return;
      }

      if (!mounted) return;

      final bool success = resp['success'] == true;
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Comment sent')));

        setState(() {
          if (announcement['comments'] == null) {
            announcement['comments'] = [];
          }
          (announcement['comments'] as List).add({
            'username': 'You',
            'text': commentText,
            'commentID': resp['commentID'],
          });

          final dynamic rawCount = resp['commentsCount'];
          final int? serverCount = rawCount is int
              ? rawCount
              : int.tryParse(rawCount?.toString() ?? '');

          if (serverCount != null) {
            announcement['commentsCount'] = serverCount;
          } else {
            final int currentCount = int.tryParse(announcement['commentsCount']?.toString() ?? '') ?? 0;
            announcement['commentsCount'] = currentCount + 1;
          }
        });

        commentController.clear();
      } else {
        final msg = resp['message'] ?? 'Failed to send comment';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = List<Map<String, dynamic>>.from(announcement['comments'] ?? []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Announcement'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: announcement['profilePhoto'] != ''
                            ? NetworkImage(_getImageUrl(announcement['profilePhoto']))
                            : null,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Text(announcement['username'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(announcement['title'] ?? '',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(announcement['description'] ?? '',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  if ((announcement['photo'] ?? '').isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _getImageUrl(announcement['photo']),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: _likeInProgress
                            ? null
                            : () async {
                                final int? currentAcc = CurrentUser.accID;
                                if (currentAcc == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('You must be logged in to like')),
                                    );
                                  }
                                  return;
                                }

                                final int anounId = int.parse(announcement['anounID'].toString());

                                setState(() => _likeInProgress = true);
                                try {
                                  final resp = await announcementService.likeAnnouncement(
                                    anounID: anounId,
                                    accID: currentAcc,
                                  );

                                  if (!mounted) return;

                                  if (resp['success'] == true) {
                                    final dynamic rawCount = resp['likesCount'];
                                    final int? likesCount = rawCount is int
                                        ? rawCount
                                        : int.tryParse(rawCount?.toString() ?? '');

                                    setState(() {
                                      if (likesCount != null) {
                                        announcement['likesCount'] = likesCount;
                                      } else {
                                        final int current = int.tryParse(announcement['likesCount']?.toString() ?? '') ?? 0;
                                        announcement['likesCount'] = current + 1;
                                      }
                                      isLiked = true;
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Liked')),
                                      );
                                    }
                                  } else {
                                    final msg = resp['message'] ?? 'Failed to like';
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                    }
                                    if (resp['message'] != null && resp['message'].toString().toLowerCase().contains('already')) {
                                      setState(() => isLiked = true);
                                    }
                                  }
                                } catch (e) {
                                  debugPrint('like failed: $e');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to like: $e')));
                                  }
                                } finally {
                                  if (mounted) setState(() => _likeInProgress = false);
                                }
                              },
                      ),
                      Text('${announcement['likesCount']} Likes'),
                      const SizedBox(width: 24),
                      Icon(Icons.comment, color: Colors.grey[700]),
                      Text(' ${announcement['commentsCount']} Comments'),
                    ],
                  ),
                  const Divider(),
                  const Text("Comments",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...comments.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['username'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(c['text'] ?? ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: const Border(top: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                        hintText: "Write a comment...", border: InputBorder.none),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
