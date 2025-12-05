import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart';
import '../services/config.dart';

class EditPineapplePage extends StatefulWidget {
  final Map<String, dynamic> pineapple;
  final Function(Map<String, dynamic>) onSave;

  const EditPineapplePage({
    super.key,
    required this.pineapple,
    required this.onSave
  });

  @override
  State<EditPineapplePage> createState() => _EditPineapplePageState();
}

class _EditPineapplePageState extends State<EditPineapplePage> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = AppConfig.baseUrl;

  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late String status;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from the passed pineapple map
    descriptionController =
        TextEditingController(text: widget.pineapple['description']);
    priceController =
        TextEditingController(text: widget.pineapple['price'].toString());
    
    // Set initial status, defaulting to 'Available' if not found
    status = widget.pineapple['status'] ?? 'Available';
  }

  @override
  void dispose() {
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // ========================================================================
  // >>> IMAGE HANDLING HELPERS <<< (Copied from MyFarmPage)
  // ========================================================================

  // Helper: Constructs the full image URL
  String _getImageUrl(String photoPath) {
    if (photoPath.isEmpty) {
      return ''; 
    }
    return '$baseUrl/$photoPath';
  }

  // Helper: Builds the image widget with network loading and fallback
  Widget _buildItemImage(String photoPath, {double size = 120}) {
    final imageUrl = _getImageUrl(photoPath);
    
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
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
  // >>> API & UTILITY <<<
  // ========================================================================

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct the errors in the form.')));
      return;
    }

    final int? accID = CurrentUser.accID;
    if (accID == null) {
      _showSnackbar('Error: User not logged in.');
      return;
    }

    // Capture the current values from controllers
    final double newPrice = double.tryParse(priceController.text) ?? 0;
    final String newDescription = descriptionController.text;

    final uri = Uri.parse('$baseUrl/editmypine.php');

    // Data to be sent to PHP (including primary keys)
    final Map<String, String> body = {
      'varietyID': widget.pineapple['varietyID'].toString(), // Primary Key 1
      'accID': accID.toString(), // Primary Key 2
      'price': newPrice.toString(),
      'status': status,
      'description': newDescription,
    };

    try {
      final response = await http.post(uri, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        _showSnackbar(jsonResponse['message']);

        if (jsonResponse['success'] == true) {
          // 1. Update the local map with new values
          final updatedPineapple = Map<String, dynamic>.from(widget.pineapple)
            ..['description'] = newDescription
            ..['price'] = newPrice
            ..['status'] = status;
            
          // 2. Pass the updated data back to MyFarmPage
          widget.onSave(updatedPineapple);

          // 3. Pop the page
          if (mounted) Navigator.pop(context);
        }
      } else {
        _showSnackbar('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Connection Error: $e');
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)));
    }
  }

  // ========================================================================
  // >>> UI BUILD <<<
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Pineapple Variety"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Use the form key
          child: Column(
            children: [
              // --- EDITED: Use the new dynamic image helper ---
              _buildItemImage(widget.pineapple['photo'], size: 120),
              // ------------------------------------------------
              const SizedBox(height: 12),
              Text(widget.pineapple['name'], // Variety name
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Description Field
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description cannot be empty.';
                  }
                  return null;
                },
              ),
              
              // Price Field
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (RM)'),
                validator: (value) {
                  if (double.tryParse(value ?? '') == null || double.parse(value!) <= 0) {
                    return 'Please enter a valid price.';
                  }
                  return null;
                },
              ),
              
              // Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: status, // Use current state status
                items: const [
                  DropdownMenuItem(value: 'Available', child: Text('Available')),
                  DropdownMenuItem(value: 'Unavailable', child: Text('Unavailable')),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value!;
                  });
                },
              ),
              const SizedBox(height: 30),
              
              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: _saveChanges, // Call the async function
                child: const Text('Save Changes', style: TextStyle(fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}