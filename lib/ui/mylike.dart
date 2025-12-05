import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart'; 
import '../services/config.dart';

// Define a structured model for the announcement data
class Announcement {
  final int anounID;
  final String title;
  final String description;
  final String photo;
  final String date;
  final String username;
  final String profilePhoto;

  Announcement({
    required this.anounID,
    required this.title,
    required this.description,
    required this.photo,
    required this.date,
    required this.username,
    required this.profilePhoto,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      anounID: int.parse(json['anounID'].toString()),
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      photo: json['photo'] ?? '',
      date: json['date'] ?? 'N/A',
      username: json['username'] ?? 'Unknown User',
      profilePhoto: json['profilePhoto'] ?? '', // Assuming this holds the URL/Path
    );
  }
}

class MyLikePage extends StatefulWidget {
  const MyLikePage({super.key});

  @override
  State<MyLikePage> createState() => _MyLikePageState();
}

class _MyLikePageState extends State<MyLikePage> {
  List<Announcement> likedAnnouncements = [];
  bool isLoading = true;
  String? error;

  // Configuration (Adjust as needed)
  final String baseUrl = AppConfig.baseUrl;
  final String myLikeUrl = 'mylike.php';
  final String unlikeUrl = 'unlike_announcement.php';
  final String imageBaseUrl = AppConfig.imageBaseUrl;

  @override
  void initState() {
    super.initState();
    fetchLikedAnnouncements();
  }

  // --- API CALLS ---

  Future<void> fetchLikedAnnouncements() async {
    if (!CurrentUser.isLoggedIn) {
      setState(() {
        isLoading = false;
        error = "Please log in to view your liked items.";
      });
      return;
    }
    
    setState(() {
      isLoading = true;
      error = null;
    });

    final uri = Uri.parse('$baseUrl/$myLikeUrl');
    
    // Use POST with accID as fallback, relying on session for security
    final body = {'accID': CurrentUser.accID.toString()}; 

    try {
      final response = await http.post(uri, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          List<Announcement> fetchedList = (jsonResponse['data'] as List)
              .map((data) => Announcement.fromJson(data))
              .toList();

          setState(() {
            likedAnnouncements = fetchedList;
            isLoading = false;
          });
        } else {
          setState(() {
            error = jsonResponse['message'] ?? 'Failed to load liked announcements.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Connection error: $e';
        isLoading = false;
      });
      debugPrint('Error fetching liked announcements: $e');
    }
  }

  Future<void> _unlikeAnnouncement(int anounID) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Like'),
        content: const Text('Are you sure you want to remove this announcement from your likes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final uri = Uri.parse('$baseUrl/$unlikeUrl');
    final body = {
      'accID': CurrentUser.accID.toString(),
      'anounID': anounID.toString(),
    };

    try {
      final response = await http.post(uri, body: body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            likedAnnouncements.removeWhere((a) => a.anounID == anounID);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from My Likes')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to remove like: ${jsonResponse['message']}')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server connection failed.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error unliking announcement: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error communicating with the server.')),
        );
      }
    }
  }

  // --- UI COMPONENTS ---

  void _showDetail(Announcement an) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        // Use NetworkImage for fetching profile photos
                        backgroundImage: an.profilePhoto.isNotEmpty
                            ? NetworkImage('$imageBaseUrl/${an.profilePhoto}')
                            : null,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          an.username,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Text(
                        an.date,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    an.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (an.photo.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network( // Use Image.network for announcement photo
                        '$imageBaseUrl/${an.photo}',
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Center(child: Icon(Icons.broken_image, size: 40)),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    an.description,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(Announcement an) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(an),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header: profile + username + date + menu
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    // Use NetworkImage for profile photo
                    backgroundImage: an.profilePhoto.isNotEmpty
                        ? NetworkImage('$imageBaseUrl/${an.profilePhoto}')
                        : null,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(an.username,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(an.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'unlike') _unlikeAnnouncement(an.anounID);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'unlike', child: Text('Remove like')),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Title & description (brief)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(an.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              Text(
                an.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 8),

              // Photo row
              if (an.photo.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network( // Use Image.network
                    '$imageBaseUrl/${an.photo}',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        const Center(child: Text('Image not available')),
                  ),
                ),

              // Footer: unlike button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () => _unlikeAnnouncement(an.anounID),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoading) {
      content = const Center(child: CircularProgressIndicator(color: Colors.green));
    } else if (error != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: fetchLikedAnnouncements,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    } else if (likedAnnouncements.isEmpty) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No liked announcements yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    } else {
      content = ListView.builder(
        itemCount: likedAnnouncements.length,
        itemBuilder: (context, idx) {
          final an = likedAnnouncements[idx];
          return _buildCard(an);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Likes'),
        backgroundColor: Colors.green[700],
      ),
      body: content,
    );
  }
}