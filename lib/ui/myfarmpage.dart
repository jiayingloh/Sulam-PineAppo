import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart'; // To get CurrentUser.accID
import 'addpineapplepage.dart';
import 'editpineapplepage.dart';
import '../services/config.dart';

class MyFarmPage extends StatefulWidget {
  const MyFarmPage({super.key});

  @override
  State<MyFarmPage> createState() => _MyFarmPageState();
}

class _MyFarmPageState extends State<MyFarmPage> {
  final String baseUrl = AppConfig.baseUrl;

  List<Map<String, dynamic>> pineapples = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyPineapples();
  }

  // GET PINEAPPLE LIST
  Future<void> _fetchMyPineapples() async {
    final int? accID = CurrentUser.accID;
    if (accID == null) {
      setState(() {
        _errorMessage = 'Error: User not logged in.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse('$baseUrl/showmypineapple.php');

    try {
      final response = await http.post(
        uri,
        body: {'accID': accID.toString()},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body.trim());

        if (jsonResponse['success'] == true) {
          final List<dynamic> fetchedList = jsonResponse['pineapples'];
          setState(() {
            pineapples = List<Map<String, dynamic>>.from(fetchedList);
          });
        } else {
          setState(() {
            _errorMessage = jsonResponse['message'] ?? 'Failed to retrieve list.';
            pineapples = [];
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'HTTP Error: ${response.statusCode}. Could not connect to server.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection Error: $e. Check IP or server status.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // ========================================================================
  // >>> IMAGE HANDLING HELPERS <<<
  // ========================================================================

  // Helper: Constructs the full image URL
  String _getImageUrl(String photoPath) {
    if (photoPath.isEmpty) {
      return ''; 
    }
    // Assuming the photo path from DB (e.g., 'images/xxx.jpg') needs to be combined with the base URL
    return '$baseUrl/$photoPath';
  }

  // Helper: Builds the image widget with network loading and fallback
  Widget _buildItemImage(String photoPath) {
    final imageUrl = _getImageUrl(photoPath);
    const double size = 80;
    
    // Fallback asset path (ensure this asset exists in your project)
    const String fallbackAsset = 'assets/images/PineWelcome.jpeg'; 

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            width: size,
            height: size,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Fallback to local asset on network error
          return Image.asset(
            fallbackAsset,
            width: size,
            height: size,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // Fallback if the photo path from DB is empty
      return Image.asset(
        fallbackAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }
  }

  // ========================================================================
  // >>> BUILD METHOD & WIDGETS <<<
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMyPineapples,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else if (pineapples.isEmpty) {
      content = const Center(
        child: Text(
          "No pineapple varieties listed.\nTap '+' to add your first one!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      content = ListView.builder(
        itemCount: pineapples.length,
        itemBuilder: (context, index) {
          final pineapple = pineapples[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // --- EDITED: Use the new dynamic image helper ---
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildItemImage(pineapple['photo']),
                      ),
                      // ------------------------------------------------
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pineapple['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "RM${double.parse(pineapple['price'].toString()).toStringAsFixed(2)} • ${pineapple['status']}",
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        onSelected: (value) async {
                          if (value == 'delete') {
                            // Temporary local delete
                            setState(() {
                              pineapples.removeAt(index);
                            });
                          } else if (value == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPineapplePage(
                                  pineapple: pineapple,
                                  onSave: (updated) {
                                    setState(() {
                                      pineapples[index] = updated;
                                    });
                                  },
                                ),
                              ),
                            );
                            _fetchMyPineapples(); // Refresh
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(pineapple['description']),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Farm (Pineapples)"),
        backgroundColor: Colors.green,
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final newPineapple = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPineapplePage(),
            ),
          );

          if (newPineapple != null) {
            _fetchMyPineapples();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}