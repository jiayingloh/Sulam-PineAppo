import 'package:flutter/material.dart';

// Import your sub-pages here. You will need to create these files.
// Example placeholders:
import 'infoProductpage.dart';
import 'infoPineapplepage.dart';
import 'infopineappleseed.dart';

class InfoMainPage extends StatelessWidget {
  const InfoMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Information Hub 📚"),
        backgroundColor: const Color.fromARGB(255, 101, 139, 96),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Explore detailed information about our products and pineapple varieties.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          
          // --- Info Product Card ---
          _buildInfoCard(
            context,
            title: "Info Product",
            subtitle: "General information regarding non-fruit pineapple products.",
            icon: Icons.inventory_2,
            targetPage: const InfoPage(), // Placeholder page
          ),

          const SizedBox(height: 16),

          // --- Info Pineapple Card ---
          _buildInfoCard(
            context,
            title: "Info Pineapple",
            subtitle: "General facts, cultivation, and uses of pineapples.",
            icon: Icons.nature_people,
            targetPage: InfoPineapplePage(), // Placeholder page
          ),
          
          const SizedBox(height: 16),

          // --- Info Pineapple Sweet Card ---
          _buildInfoCard(
            context,
            title: "Info Pineapple Seed",
            subtitle: "Detailed pineapple seeds supplier depends on varieties (e.g., MD2, Nanas Manis).",
            icon: Icons.local_florist,
            targetPage: const InfoPineappleSeedPage(), // Placeholder page
          ),
        ],
      ),
    );
  }

  // Helper widget to build consistent list cards
  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget targetPage,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetPage),
          );
        },
      ),
    );
  }
}