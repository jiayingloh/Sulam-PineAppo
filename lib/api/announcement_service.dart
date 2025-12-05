import 'dart:convert';
import 'dart:io'; // for File
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'package:mime/mime.dart'; // for lookupMimeType
import '../services/config.dart';

class AnnouncementService {
  final String baseUrl = AppConfig.baseUrl; // your local server IP

  /// Create a new announcement with optional photo
  Future<bool> createAnnouncement({
  required int accID,
  required String title,
  required String description,
  File? photo,
}) async {
  try { // <-- ADDED TRY BLOCK
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/new_announcement.php'),
    );

    request.fields['accID'] = accID.toString();
    request.fields['title'] = title;
    request.fields['description'] = description;

    if (photo != null) {
      final mimeType = lookupMimeType(photo.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ));
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final data = json.decode(resBody);
    
    // Check HTTP status code explicitly for better error handling
    if (response.statusCode != 200) {
        print('Server responded with status: ${response.statusCode} and body: $resBody');
        return false;
    }

    return data['success'] == true;

  } catch (e) { // <-- ADDED CATCH BLOCK
    // Print the error to the console for debugging
    print('Error creating announcement: $e'); 
    return false;
  }
}

  /// Fetch all announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await http.get(Uri.parse('$baseUrl/announcement.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['announcements'] != null) {
        return List<Map<String, dynamic>>.from(data['announcements']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch announcements');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Send a comment to an announcement.
  /// Returns the decoded server response as a map. Expected keys: `success`, `commentID`, `commentsCount`.
  Future<Map<String, dynamic>> sendComment({
    required int anounID,
    required int accID,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_comment.php'),
      body: {
        'anounID': anounID.toString(),
        'accID': accID.toString(),
        'description': comment,
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) return data;
        return {'success': false, 'message': 'Invalid response format'};
      } catch (e) {
        throw Exception('Invalid JSON response: $e\nBody: ${response.body}');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  /// Like an announcement. Returns decoded server response (expects `success` and `likesCount`).
  Future<Map<String, dynamic>> likeAnnouncement({
    required int anounID,
    required int accID,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/like.php'),
      body: {
        'anounID': anounID.toString(),
        'accID': accID.toString(),
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) return data;
        return {'success': false, 'message': 'Invalid response format'};
      } catch (e) {
        throw Exception('Invalid JSON response: $e\nBody: ${response.body}');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
