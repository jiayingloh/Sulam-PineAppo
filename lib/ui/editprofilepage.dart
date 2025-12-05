import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../services/session.dart';
import '../services/config.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? selectedType;
  String? selectedLocation;
  File? _profileImage;
  String? profilePhotoUrl;

  final List<String> businessTypes = ["Farm", "Industry", "Shop"];
  final List<String> malaysiaRegions = [
    "Johor", "Kedah", "Kelantan", "Melaka", "Negeri Sembilan",
    "Pahang", "Perak", "Perlis", "Pulau Pinang", "Sabah",
    "Sarawak", "Selangor", "Terengganu", "Kuala Lumpur",
    "Labuan", "Putrajaya"
  ];

  final String baseUrl = AppConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    final int? acc = CurrentUser.accID;
    if (acc != null) _fetchProfile(acc);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        profilePhotoUrl = pickedFile.path;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _fetchProfile(int accID) async {
    try {
      final uri = Uri.parse('$baseUrl/profile.php?accID=$accID');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(resp.body);
        if (data['success'] == true && data['profile'] != null) {
          final profile = Map<String, dynamic>.from(data['profile']);
          setState(() {
            fullNameController.text = profile['FullName'] ?? '';
            selectedType = profile['Own'] ?? selectedType;
            businessNameController.text = profile['BusinessName'] ?? '';
            addressController.text = profile['Address'] ?? '';
            selectedLocation = profile['Location'] ?? selectedLocation;
            phoneController.text = profile['PhoneNo'] ?? '';
            profilePhotoUrl = profile['Photo'] ?? '';
          });
          if (profilePhotoUrl?.isNotEmpty ?? false) {
            CurrentUser.setProfilePhoto(profilePhotoUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch profile: $e');
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) _postProfile();
  }

  Future<void> _postProfile() async {
    final int? acc = CurrentUser.accID;
    if (acc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to update profile'))
      );
      return;
    }

    final uri = Uri.parse('$baseUrl/profile.php');

    var request = http.MultipartRequest('POST', uri);

    // normal fields
    request.fields['accID'] = acc.toString();
    request.fields['FullName'] = fullNameController.text.trim();
    request.fields['Own'] = selectedType ?? '';
    request.fields['BusinessName'] = businessNameController.text.trim();
    request.fields['Address'] = addressController.text.trim();
    request.fields['Location'] = selectedLocation ?? '';
    request.fields['PhoneNo'] = phoneController.text.trim();
    request.fields['FbLink'] = '';
    request.fields['IgLink'] = '';

    // file upload (IMPORTANT)
    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_photo',
          _profileImage!.path,
        ),
      );
    }

    // send request
    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    var data = json.decode(respStr);

    bool ok = data['success'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Profile Updated Successfully!' : data['message']))
    );

    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? const Icon(Icons.camera_alt, size: 32) : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(fullNameController, "Full Name", "Enter your full name"),
              const SizedBox(height: 15),
              _buildDropdownField(
                value: selectedType,
                label: "Own (Farm / Industry / Shop)",
                items: businessTypes,
                onChanged: (val) => setState(() => selectedType = val.toString()),
                validatorMsg: "Select one type",
              ),
              const SizedBox(height: 15),
              _buildTextField(businessNameController, "Business Name", "Enter business name"),
              const SizedBox(height: 15),
              _buildTextField(addressController, "Address (Street, City, Postcode)", "Enter address"),
              const SizedBox(height: 15),
              _buildDropdownField(
                value: selectedLocation,
                label: "Location (Negeri Malaysia)",
                items: malaysiaRegions,
                onChanged: (val) => setState(() => selectedLocation = val.toString()),
                validatorMsg: "Select location",
              ),
              const SizedBox(height: 15),
              _buildTextField(phoneController, "Phone Number", "Enter phone number", keyboard: TextInputType.phone),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialButton("Connect FB", Colors.blue, Icons.facebook, "https://m.facebook.com/"),
                  _socialButton("Connect IG", Colors.pink, Icons.camera_alt, "https://www.instagram.com/"),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validatorMsg, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) => value!.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required Function(dynamic) onChanged,
    required String validatorMsg,
  }) {
    return DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? validatorMsg : null,
    );
  }

  Widget _socialButton(String label, Color color, IconData icon, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
