import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/session.dart';
import '../services/config.dart';

// Define a model for the fetched varieties
class Variety {
  final int id;
  final String name;

  Variety({required this.id, required this.name});
}

class AddPineapplePage extends StatefulWidget {
  const AddPineapplePage({super.key});

  @override
  State<AddPineapplePage> createState() => _AddPineapplePageState();
}

class _AddPineapplePageState extends State<AddPineapplePage> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = AppConfig.baseUrl;

  // Variety data
  List<Variety> availableVarieties = [];
  int? selectedVarietyId; // Changed to hold the ID (int)
  String selectedVarietyName = ''; // To store the name for display/saving back
  
  bool isLoadingVarieties = true;
  String? varietyFetchError; // New state for error messages

  // Form fields
  String description = '';
  String status = 'Available';
  double price = 0;

  @override
  void initState() {
    super.initState();
    _fetchPineappleVarieties();
  }

  // --- API FETCH: Get Variety List (ID 1-9) ---
  Future<void> _fetchPineappleVarieties() async {
    final uri = Uri.parse('$baseUrl/get_varieties.php');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> varietiesJson = jsonResponse['varieties'];
          availableVarieties = varietiesJson
              .map((json) => Variety(id: json['id'], name: json['name']))
              .toList();
        } else {
          // Handle error from PHP script
          varietyFetchError = 'Server Message: ${jsonResponse['message']}';
        }
      } else {
        varietyFetchError = 'HTTP Error: ${response.statusCode}. Check server logs.';
      }
    } catch (e) {
      varietyFetchError = 'Connection Error: $e. Is the server running?';
    } finally {
      if (mounted) {
        setState(() {
          isLoadingVarieties = false;
        });
      }
    }
  }

  // --- API POST: Save New Pineapple ---
  Future<void> _savePineapple() async {
    if (!_formKey.currentState!.validate() || selectedVarietyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a variety and fill all fields correctly.')));
      return;
    }

    final int? accID = CurrentUser.accID;
    if (accID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')));
      return;
    }

    final uri = Uri.parse('$baseUrl/add_pineapple.php');

    // Data to be sent to PHP
    final Map<String, String> body = {
      'varietyID': selectedVarietyId.toString(),
      'accID': accID.toString(),
      'price': price.toString(),
      'status': status,
      'description': description,
    };

    try {
      final response = await http.post(uri, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])));

        if (jsonResponse['success'] == true) {
          // Pass the data back to MyFarmPage to update the list
          Navigator.pop(context, {
            'name': selectedVarietyName, // Use the stored name for display
            'photo': 'assets/images/default_pineapple.jpeg', 
            'description': description,
            'price': price,
            'status': status
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server Error: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection Error: $e')));
    }
  }


  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isLoadingVarieties) {
      content = const Center(child: CircularProgressIndicator());
    } else if (varietyFetchError != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Failed to load varieties: $varietyFetchError', style: const TextStyle(color: Colors.red)),
        ),
      );
    } else if (availableVarieties.isEmpty) {
      content = const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No pineapple varieties found (ID 1-9). Check your Variety table.', style: TextStyle(color: Colors.orange)),
        ),
      );
    } else {
      // Form content when varieties are successfully loaded
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Variety Dropdown (Using ID as value) ---
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Pineapple Variety'),
                value: selectedVarietyId,
                items: availableVarieties
                    .map((variety) => DropdownMenuItem<int>(
                        value: variety.id, child: Text(variety.name)))
                    .toList(),
                onChanged: (int? id) {
                  setState(() {
                    selectedVarietyId = id;
                    // Find and store the name based on the selected ID
                    selectedVarietyName = availableVarieties.firstWhere((v) => v.id == id).name;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a variety';
                  }
                  return null;
                },
              ),

              // --- Description Field ---
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (value) => description = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              // --- Price Field ---
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price per kilogram (RM/kg)'),
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
              ),

              const SizedBox(height: 30),

              // --- Save Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: _savePineapple,
                child: const Text('Save', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Pineapple Variety"),
        backgroundColor: Colors.green[700],
      ),
      body: content,
    );
  }
}