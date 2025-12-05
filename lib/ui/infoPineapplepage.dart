import 'package:flutter/material.dart';
import 'pineapple_deatil_page.dart';

class InfoPineapplePage extends StatelessWidget {
  InfoPineapplePage({super.key});

  // Categories with varieties and their images
  final Map<String, Map<String, dynamic>> categorizedVarieties = {
    "Spanish": {
      "varieties": ["Gandul"],
      "images": [
        "assets/images/info_gandul.png",
      ],
    },
    "Hybrid": {
      "varieties": ["MD2", "N36", "Maspine", "Josapine"],
      "images": [
        "assets/images/info_md2.png",
        "assets/images/info_n36.png",
        "assets/images/info_maspine.png",
        "assets/images/info_josapine.png",
      ],
    },
    "Queen": {
      "varieties": ["Moris", "Moris Gajah", "Yankee"],
      "images": [
        "assets/images/info_moris.png",
        "assets/images/info_morisgajah.png",
        "assets/images/info_yankee.png",
      ],
    },
    "Smooth Cayenne": {
      "varieties": ["Sarawak"],
      "images": [
        "assets/images/info_sarawak.png",
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pineapple Varieties"),
        backgroundColor: const Color.fromARGB(255, 101, 139, 96),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: categorizedVarieties.entries.map((entry) {
          final categoryName = entry.key;
          final varieties = entry.value['varieties'] as List<String>;
          final images = entry.value['images'] as List<String>;

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Varieties: ${varieties.join(', ')}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                // Navigate to detail page with category + images
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PineappleDetailPage(
                      title: categoryName,
                      imagePaths: images, // Pass the list of images
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
