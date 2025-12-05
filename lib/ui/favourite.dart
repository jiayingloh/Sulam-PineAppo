import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../services/session.dart'; 
import '../services/config.dart';

// --- 1. Model for Profile Data ---
class FavoriteProfile {
  final int accID;
  final String fullName;
  final String businessName;
  final String ownType;
  final String location;
  final String? phoneNo;
  final String? photo;
  final String? fbLink;
  final String? igLink;

  FavoriteProfile({
    required this.accID,
    required this.fullName,
    required this.businessName,
    required this.ownType,
    required this.location,
    this.phoneNo,
    this.photo,
    this.fbLink,
    this.igLink,
  });

  factory FavoriteProfile.fromJson(Map<String, dynamic> json) {
    return FavoriteProfile(
      accID: (json['AccID'] is num) ? json['AccID'] : 0,
      fullName: json['FullName'] ?? 'N/A',
      businessName: json['BusinessName'] ?? 'No Business Name',
      ownType: json['Own'] ?? 'N/A',
      location: json['Location'] ?? 'N/A',
      phoneNo: json['PhoneNo'],
      photo: json['Photo'],
      fbLink: json['FbLink'],
      igLink: json['IgLink'],
    );
  }
}

// ----------------------------------

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final String baseUrl = AppConfig.baseUrl;
  List<FavoriteProfile> _favorites = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteList();
  }

  // --- API FETCH: Get List of Favorites ---
  Future<void> _fetchFavoriteList() async {
    final currentAccID = CurrentUser.accID;

    if (currentAccID == null || currentAccID <= 0) {
      setState(() {
        _errorMessage = 'User must be logged in.';
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.parse('$baseUrl/get_favourites_list.php?AccID=$currentAccID');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        String rawBody = response.body.trim();
        int jsonStart = rawBody.indexOf('{');
        if (jsonStart != -1) rawBody = rawBody.substring(jsonStart);

        final data = json.decode(rawBody);

        if (data['success'] == true && data['data'] is List) {
          setState(() {
            _favorites = (data['data'] as List)
                .map((jsonItem) => FavoriteProfile.fromJson(jsonItem))
                .toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Failed to load list.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'HTTP Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  // --- Launchers ---
  void _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make call.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _launchSocial(String link) async {
    if (link.isEmpty) return;
    final uri = Uri.parse(link);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open link: $link')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  // --- Widget Builders ---
  Widget _buildProfileCard(FavoriteProfile profile) {
    final imageUrl = profile.photo != null ? '$baseUrl/uploads/${profile.photo}' : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Photo, Business Name & Type
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green[100],
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? const Icon(Icons.person, color: Colors.green) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.businessName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Owner: ${profile.fullName}',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Seller Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    profile.ownType,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade600),
                  ),
                ),
              ],
            ),
            
            const Divider(height: 20),

            // Contact & Social Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Text(profile.location, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  children: [
                    if (profile.phoneNo != null && profile.phoneNo!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () => _launchPhone(profile.phoneNo!),
                      ),
                    if (profile.fbLink != null && profile.fbLink!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.facebook, color: Color(0xFF1877F2)),
                        onPressed: () => _launchSocial(profile.fbLink!),
                      ),
                    if (profile.igLink != null && profile.igLink!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.pink),
                        onPressed: () => _launchSocial(profile.igLink!),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      content = Center(child: Text('Error: $_errorMessage'));
    } else if (_favorites.isEmpty) {
      content = const Center(
        child: Text('You haven\'t favorited any businesses yet.', style: TextStyle(color: Colors.grey)),
      );
    } else {
      content = ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          return _buildProfileCard(_favorites[index]);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorite Sellers'),
        backgroundColor: Colors.green[700],
      ),
      body: content,
    );
  }
}
