import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/account_model.dart';
import '../services/session.dart';
import '../services/config.dart';

class AuthService {
  final String baseUrl = AppConfig.baseUrl;

  /// LOGIN
  /// Return an Account object if successful, else null
  Future<Account?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        // Store server session cookie if present (so subsequent requests that rely on PHP session work)
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          // Keep only the cookie name=value pair (strip attributes like Path/HttpOnly)
          final cookiePair = setCookie.split(';').first.trim();
          CurrentUser.setSessionCookie(cookiePair);
        }

        // Convert the returned account map into an Account model
        return Account.fromJson(Map<String, dynamic>.from(data['account']));
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  /// REGISTER 
  Future<bool> register(String email, String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to connect to server');
    }
  }

  Future<bool> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot_password.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to connect to server');
    }
  }
}
