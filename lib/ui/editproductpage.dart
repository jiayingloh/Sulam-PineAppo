import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart'; 
import '../services/config.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onSave;

  const EditProductPage({
    super.key,
    required this.product,
    required this.onSave,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = AppConfig.baseUrl;

  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late String status;

  @override
  void initState() {
    super.initState();
    descriptionController =
        TextEditingController(text: widget.product['description']);
    priceController =
        TextEditingController(text: widget.product['price'].toString());
    status = widget.product['status'] ?? 'Available';
  }

  @override
  void dispose() {
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  // --- API POST: Update Existing Product ---
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Please correct the errors in the form.');
      return;
    }

    final int? accID = CurrentUser.accID;
    if (accID == null) {
      _showSnackbar('Error: User not logged in.');
      return;
    }

    final double newPrice = double.tryParse(priceController.text) ?? 0;
    final String newDescription = descriptionController.text;

    final uri = Uri.parse('$baseUrl/editmyproduct.php');

    final Map<String, String> body = {
      'proID': widget.product['proID'].toString(), // Primary Key 1
      'accID': accID.toString(),                   // Primary Key 2
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
          final updatedProduct = Map<String, dynamic>.from(widget.product)
            ..['description'] = newDescription
            ..['price'] = newPrice
            ..['status'] = status;

          widget.onSave(updatedProduct);

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Display product photo and name
              Image.asset(widget.product['photo'], height: 120, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text(
                widget.product['name'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                  if (double.tryParse(value ?? '') == null ||
                      double.parse(value!) <= 0) {
                    return 'Please enter a valid price.';
                  }
                  return null;
                },
              ),

              // Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                // value: ['Available', 'Unavailable'].contains(status) ? status : 'Available',
                items: const [
                  DropdownMenuItem(value: 'Available', child: Text('In Stock')),
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
                onPressed: _saveChanges,
                child: const Text('Save Changes', style: TextStyle(fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
