import 'package:flutter/material.dart';
import 'announcementpage.dart';
import '../api/announcement_service.dart';
import '../services/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AnnouncementService announcementService = AnnouncementService();
  late Future<List<Map<String, dynamic>>> _futureAnnouncements;

  @override
  void initState() {
    super.initState();
    _futureAnnouncements = announcementService.getAnnouncements();
  }

  // --- Base URL for relative images ---
  final String baseUrl = AppConfig.baseUrl;// Android emulator localhost
  String _getImageUrl(String photoPath) {
    if (photoPath.isEmpty) return '';
    if (photoPath.startsWith("http")) return photoPath; // already absolute
    return "$baseUrl/$photoPath";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            height: 180,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[300],
              image: const DecorationImage(
                image: AssetImage('assets/images/PineWelcome.jpeg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Welcome to PineAppo!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "New Announcement",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureAnnouncements,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No announcements found.'));
              }

              final announcements = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final item = announcements[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnnouncementPage(announcement: item),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha((0.3 * 255).round()),
                            blurRadius: 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: item['profilePhoto'] != ''
                                    ? NetworkImage(_getImageUrl(item['profilePhoto']))
                                    : null,
                                backgroundColor: Colors.grey[300],
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item['username'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(item['title'] ?? '',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(item['description'] ?? '', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          if ((item['photo'] ?? '').isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _getImageUrl(item['photo']),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
