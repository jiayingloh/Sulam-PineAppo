import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/session.dart';
import '../services/config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String email = '';
  String username = '';
  String password = ''; 
  final String baseUrl = AppConfig.baseUrl;


  @override
  void initState() {
    super.initState();
    // Initialize fields from session if available
    setState(() {
      username = CurrentUser.username ?? '';
      email = CurrentUser.email ?? '';
    });
  }

  // For email OTP flow
  String _tempEmail = "";
  String _otpSent = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEmailSetting(),
          const Divider(),
          _buildSettingItem(
            label: "Username",
            value: username,
            onEdit: () => _showEditDialog(
              title: "Change Username",
              currentValue: username,
              onSave: (val) {
                // The actual state update happens after server confirms the change
              },
            ),
          ),
          const Divider(),
          _buildSettingItem(
            label: "Password",
            value: "*****",
            onEdit: _showPasswordChangeDialog,
          ),
        ],
      ),
    );
  }

  /// Send updates to `edit_account.php`.
  /// The payload now only needs the specific field being updated.
  Future<bool> _updateAccount(Map<String, String> fields) async {
    final int? acc = CurrentUser.accID;
    if (acc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not logged in')));
      return false;
    }

    final uri = Uri.parse('$baseUrl/edit_account.php');
    // Add accID to the body
    final body = <String, String>{'accID': acc.toString()}; 
    body.addAll(fields);

    try {
      final headers = <String, String>{'Accept': 'application/json'};
      if (CurrentUser.sessionCookie != null) {
        headers['Cookie'] = CurrentUser.sessionCookie!;
      }
      final resp = await http.post(uri, headers: headers, body: body);
      if (resp.statusCode == 200) {
        // Check for success message based on the new PHP structure
        return resp.body.contains("updated successfully!");
      } else {
        debugPrint('edit_account.php returned ${resp.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error calling edit_account.php: $e');
      return false;
    }
  }

  Widget _buildEmailSetting() {
    return ListTile(
      title: const Text("Email"),
      subtitle: Text(email.isNotEmpty ? email : 'Not set'),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.green),
        onPressed: () => _showEmailEditDialog(),
      ),
    );
  }

  void _showEmailEditDialog() {
    final emailController = TextEditingController(text: email);
    final otpController = TextEditingController();
    bool otpSent = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Change Email"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!otpSent) ...[
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "New Email"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700]),
                    onPressed: () {
                      if (emailController.text.isNotEmpty) {
                        _tempEmail = emailController.text;
                        _otpSent = "123456"; // demo OTP - Replace with real call!
                        setStateDialog(() {
                          otpSent = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("OTP sent to your new email")),
                        );
                      }
                    },
                    child: const Text("Send OTP"),
                  ),
                ] else ...[
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(labelText: "Enter OTP"),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700]),
                    onPressed: () {
                      if (otpController.text == _otpSent) {
                        // 🔑 FIX 1: Only send 'email' now, as PHP handles it separately.
                        _updateAccount({'email': _tempEmail}).then((ok) {
                          if (ok) {
                            setState(() {
                              email = _tempEmail;
                              CurrentUser.email = _tempEmail; // Update Session
                            });
                            if (context.mounted) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Email updated successfully")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Failed to update email")),
                            );
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invalid OTP")),
                        );
                      }
                    },
                    child: const Text("Save"),
                  )
                ]
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSettingItem({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
      trailing: IconButton(
        icon: const Icon(Icons.edit, color: Colors.green),
        onPressed: onEdit,
      ),
    );
  }

  void _showEditDialog({
    required String title,
    required String currentValue,
    bool obscureText = false,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: title, // Simplified label
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                if (title.toLowerCase().contains('username')) {
                  // 🔑 FIX 2: Only send 'username', as PHP handles it separately.
                  final payload = {
                    'username': controller.text.trim(),
                  };

                  final ok = await _updateAccount(payload);
                  if (ok) {
                    setState(() => username = controller.text.trim());
                    CurrentUser.username = controller.text.trim();
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Username updated successfully"))
                    );
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to update username"))
                    );
                  }
                } 
                // Since this dialog is only called for Username, no else-logic needed.
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            onPressed: () async {
              // ⚠️ IMPORTANT: We must send the OLD password for server verification.
              // The PHP script you provided doesn't currently check it, but security requires it.
              // For now, we'll send it for the update attempt.
              
              if (newController.text.isNotEmpty) {
                  // 🔑 FIX 3: Only send 'password' and 'old_password' (if the server supported it)
                  // Since your PHP only accepts 'password', we send just that, 
                  // and we MUST ensure the local password check is replaced by a server check.
                  // For *this* specific fix based on your provided PHP, we send the new password:
                  
                  final payload = {
                    'password': newController.text,
                  };
                  
                  // NOTE: The local check (oldController.text == password) is now removed 
                  // because we can't securely store or compare the password locally.
                  // The server MUST handle old password validation!
                  
                  final ok = await _updateAccount(payload);
                  
                  if (ok) {
                    setState(() {
                      password = newController.text; // Locally store the new password (for next local comparison attempt - still insecure)
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Password updated successfully")),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to update password")),
                      );
                    }
                  }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New password cannot be empty")),
                );
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }
}