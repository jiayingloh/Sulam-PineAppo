import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../api/announcement_service.dart';
import '../services/session.dart';

class NewAnnouncementPage extends StatefulWidget {
  final int? accountId;

  const NewAnnouncementPage({super.key, this.accountId});

  @override
  State<NewAnnouncementPage> createState() => _NewAnnouncementPageState();
}

class _NewAnnouncementPageState extends State<NewAnnouncementPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final AnnouncementService announcementService = AnnouncementService();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  void _publishAnnouncement() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    // Prefer explicit accountId passed from dashboard, otherwise fall back
    // to the globally stored current user id.
    final accIdToUse = widget.accountId ?? CurrentUser.accID;
    if (accIdToUse == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("You must be logged in to post.")));
      return;
    }

    bool success = await announcementService.createAnnouncement(
      accID: accIdToUse,
      title: title,
      description: description,
      photo: _selectedImage,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Announcement published")));
      Navigator.pop(context, true); // Return true to refresh HomePage
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to publish announcement")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Announcement"),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _titleController, decoration: const InputDecoration(
              hintText: "Enter title", border: OutlineInputBorder(),
            )),
            const SizedBox(height: 16),
            const Text("Photo", style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: _selectedImage == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey))
                    : Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                  hintText: "Enter description", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _publishAnnouncement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Publish", style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
