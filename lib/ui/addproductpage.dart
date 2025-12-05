import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart'; 
import '../services/config.dart';

class Product {
  final int id;
  final String name;

  Product({required this.id, required this.name});
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = AppConfig.baseUrl;

  // Product data
  List<Product> availableProducts = [];
  int? selectedProductId;
  String selectedProductName = '';
  bool isLoadingProducts = true;
  String? productFetchError;

  // Form fields
  String description = '';
  String status = 'Available'; // Initialize with a valid DB value
  double price = 0;

  @override
  void initState() {
    super.initState();
    _fetchProductList();
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)));
    }
  }

  // --- API FETCH: Get Product List ---
  Future<void> _fetchProductList() async {
    final uri = Uri.parse('$baseUrl/get_product.php'); // PHP endpoint to return product list

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> productsJson = jsonResponse['products'];
          availableProducts = productsJson
              .map((json) => Product(id: json['id'], name: json['name']))
              .toList();
        } else {
          productFetchError = 'Server message: ${jsonResponse['message']}';
        }
      } else {
        productFetchError = 'HTTP Error: ${response.statusCode}';
      }
    } catch (e) {
      productFetchError = 'Connection Error: $e';
    } finally {
      if (mounted) {
        setState(() {
          isLoadingProducts = false;
        });
      }
    }
  }

  // --- API POST: Save New Product ---
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || selectedProductId == null) {
      _showSnackbar('Please select a product and fill all fields correctly.');
      return;
    }

    final int? accID = CurrentUser.accID;
    if (accID == null) {
      _showSnackbar('Error: User not logged in.');
      return;
    }

    // 1. Get the product name using the selected ID
    final String productName = availableProducts
        .firstWhere((p) => p.id == selectedProductId!)
        .name;

    final uri = Uri.parse('$baseUrl/add_product.php');

    // 2. Data to be sent to PHP (Fix: Added 'name' key)
    final Map<String, String> body = {
      'proID': selectedProductId.toString(), // Sent the existing ProID
      'accID': accID.toString(),
      'price': price.toString(),
      'status': status,
      'description': description,
      'name': productName, // CRITICAL: This is needed by add_product.php for lookup/insert
    };

    try {
      final response = await http.post(uri, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        _showSnackbar(jsonResponse['message']);

        if (jsonResponse['success'] == true) {
          // Pass the data back to the previous page
          if (mounted) {
            Navigator.pop(context, {
              // The PHP script may return the actual ProID if it was newly created/looked up
              'proID': jsonResponse['proID'] ?? selectedProductId, 
              'name': productName,
              'photo': 'assets/images/default_product.jpeg',
              'description': description,
              'price': price,
              'status': status
            });
          }
        }
      } else {
        _showSnackbar('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Connection Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoadingProducts) {
      content = const Center(child: CircularProgressIndicator());
    } else if (productFetchError != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Failed to load products: $productFetchError', style: const TextStyle(color: Colors.red)),
        ),
      );
    } else if (availableProducts.isEmpty) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No products found. Check your Product table.', style: TextStyle(color: Colors.orange)),
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Product Dropdown (Uses ProID as value) ---
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Product'),
                value: selectedProductId,
                items: availableProducts.map((product) =>
                  DropdownMenuItem<int>(value: product.id, child: Text(product.name))
                ).toList(),
                onChanged: (int? id) {
                  setState(() {
                    selectedProductId = id;
                    // Store the name based on the selected ID
                    selectedProductName = availableProducts.firstWhere((p) => p.id == id).name;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select a product';
                  return null;
                },
              ),

              // --- Description Field ---
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (value) => description = value,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a description';
                  return null;
                },
              ),

              // --- Price Field ---
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price (RM)'),
                keyboardType: TextInputType.number,
                onChanged: (value) => price = double.tryParse(value) ?? 0,
                validator: (value) {
                  if (double.tryParse(value ?? '') == null || double.parse(value!) <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),

              // --- Status Dropdown ---
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'Available', child: Text('In Stock')),
                  DropdownMenuItem(value: 'Unavailable', child: Text('Unavailable')),
                ],
                onChanged: (value) {
                  status = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Select status';
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // --- Save Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: const Size(double.infinity, 50)
                ),
                onPressed: _saveProduct,
                child: const Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.green[700],
      ),
      body: content,
    );
  }
}