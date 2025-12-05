import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart'; // For CurrentUser.accID
import 'addproductpage.dart';
import 'editproductpage.dart';
import '../services/config.dart';

class MyProductPage extends StatefulWidget {
  const MyProductPage({super.key});

  @override
  State<MyProductPage> createState() => _MyProductPageState();
}

class _MyProductPageState extends State<MyProductPage> {
  final String baseUrl = AppConfig.baseUrl;


  List<Map<String, dynamic>> products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  // --- GET: Fetch user's products ---
  Future<void> _fetchMyProducts() async {
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

    final uri = Uri.parse('$baseUrl/showproduct.php');

    try {
      final response = await http.post(uri, body: {'accID': accID.toString()});

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body.trim());

        if (jsonResponse['success'] == true) {
          final List<dynamic> fetchedList = jsonResponse['products'];
          setState(() {
            products = List<Map<String, dynamic>>.from(fetchedList);
          });
        } else {
          setState(() {
            _errorMessage = jsonResponse['message'] ?? 'Failed to retrieve products.';
            products = [];
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

  // --- DELETE: Optional local delete or implement server call later ---
  void _deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

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
                onPressed: _fetchMyProducts,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else if (products.isEmpty) {
      content = const Center(
        child: Text(
          "No products listed.\nTap '+' to add your first one!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    } else {
      content = ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        product['photo'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "RM${double.parse(product['price'].toString()).toStringAsFixed(2)} • ${product['status']}",
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
                            _deleteProduct(index);
                          } else if (value == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductPage(
                                  product: product,
                                  onSave: (updated) {
                                    setState(() {
                                      products[index] = updated;
                                    });
                                  },
                                ),
                              ),
                            );
                            _fetchMyProducts(); // Refresh list after edit
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(product['description']),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Products"),
        backgroundColor: Colors.green,
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          );

          if (newProduct != null) {
            _fetchMyProducts(); // Refresh after adding new product
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
