import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart';
import 'editprofilepage.dart';
import 'myproductpage.dart';
import 'myfarmpage.dart'; 
import 'settingpage.dart';
import 'login.dart';
import 'favourite.dart'; 
import '../services/config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _ownerType; // 'Farm', 'Industry', 'Shop', or null
  bool _isLoading = true;

  // Base URL for relative images
  final String baseUrl = AppConfig.baseUrl;

  // Dummy URLs for social media
  final String fbUrl = "https://www.facebook.com/";
  final String igUrl = "https://www.instagram.com/";

  @override
  void initState() {
    super.initState();
    _fetchOwnerType();
  }

  // --- Convert relative DB photo path to absolute URL, with cache-busting ---
  String _getImageUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return '';
    if (photoPath.startsWith('http')) {
      return '$photoPath?t=${DateTime.now().millisecondsSinceEpoch}';
    }
    return '$baseUrl/$photoPath?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  // --- API CALL ---
  Future<void> _fetchOwnerType() async {
    final int? accID = CurrentUser.accID;

    if (accID == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final uri = Uri.parse('$baseUrl/fetch_profile_owner_type.php');
    final body = {'accID': accID.toString()};

    try {
      final response = await http.post(uri, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          if (mounted) {
            setState(() {
              _ownerType = jsonResponse['owner_type'];
              _isLoading = false;
            });
          }
        } else {
          debugPrint('Error fetching owner type: ${jsonResponse['message']}');
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        debugPrint('Server error: ${response.statusCode}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NAVIGATION & UTILITIES ---
  void _navigateToPage(BuildContext context, String title) async {
    if (title == 'Edit Profile') {
      final updated = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfilePage()),
      );

      // If profile was updated, refresh the page
      if (updated == true && mounted) {
        setState(() {});
      }
    } else if (title == 'My Favourite') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const FavouritePage()));
    } else if (title == 'My Product' || title == 'My Farm') {
      final page = (title == 'My Farm') ? const MyFarmPage() : const MyProductPage();
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else if (title == 'Settings') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
    } else if (title == 'Logout') {
      CurrentUser.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String username = CurrentUser.username ?? 'Your Name';
    final String? profilePhoto = CurrentUser.profilePhoto;

    final List<Map<String, dynamic>> baseActions = [
      {'icon': Icons.edit, 'title': 'Edit Profile'},
      {'icon': Icons.favorite, 'title': 'My Favourite'},
    ];

    Map<String, dynamic>? specializedAction;
    if (_ownerType == 'Farm') {
      specializedAction = {'icon': Icons.agriculture, 'title': 'My Farm'};
    } else if (_ownerType == 'Industry' || _ownerType == 'Shop') {
      specializedAction = {'icon': Icons.shopping_basket, 'title': 'My Product'};
    }

    final List<Map<String, dynamic>> finalActions = [
      ...baseActions,
      if (specializedAction != null) specializedAction,
      {'icon': Icons.settings, 'title': 'Settings'},
      {'icon': Icons.logout, 'title': 'Logout'},
    ];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profilePhoto != null && profilePhoto.isNotEmpty
                        ? NetworkImage(_getImageUrl(profilePhoto))
                        : null,
                    child: (profilePhoto == null || profilePhoto.isEmpty)
                        ? const Icon(Icons.person, size: 48, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: finalActions.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = finalActions[index];
                      return ListTile(
                        leading: Icon(item['icon'], color: Colors.green[700]),
                        title: Text(item['title']),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _navigateToPage(context, item['title']),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
    );
  }

}
