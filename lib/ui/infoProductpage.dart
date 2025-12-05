import 'package:flutter/material.dart';
import 'product_detail_page.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  // Sample data – only using title + image
  final List<Map<String, String>> foodProducts = const [
    {
      "title": "Halwa Nanas",
      "image": "assets/images/halwa_nanas.jpg",
    },
    {
      "title": "Skuas Nanas",
      "image": "assets/images/skuas_nanas.jpg",
    },
    {
      "title": "Jeruk Nanas",
      "image": "assets/images/jeruk_nanas.jpg",
    },
    {
      "title": "Sos Nanas Manis",
      "image": "assets/images/sos_nanas_manis.jpg",
    },
    {
      "title": "Nanas Kering",
      "image": "assets/images/nanas_kering.jpeg",
    },
    {
      "title": "Sos Nanas Bercili",
      "image": "assets/images/sos_nanas_bercili.jpg",
    },
    {
      "title": "Jem Nanas",
      "image": "assets/images/jem_nanas.jpg",
    },
  ];

  final List<Map<String, String>> nonFoodProducts = const [
    {
      "title": "Bromelin",
      "image": "assets/images/bromelin.jpeg",
    },
    {
      "title": "Baja Bio-Organik (BOF)",
      "image": "assets/images/baja_bio_organik.jpeg",
    },
    {
      "title": "Silaj",
      "image": "assets/images/silaj.jpeg",
    },
    {
      "title": "Kertas Daun Nanas",
      "image": "assets/images/kertas_daun_nanas.jpg",
    },
    {
      "title": "Papan Gentian",
      "image": "assets/images/papan_gentian.jpeg",
    },

  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Info Produk Nanas"),
          backgroundColor: const Color.fromARGB(255, 101, 139, 96),
          bottom: const TabBar(tabs: [
            Tab(text: "Food Product"),
            Tab(text: "Non-Food Product"),
          ]),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ),
        body: TabBarView(
          children: [
            _buildProductList(context, foodProducts),
            _buildProductList(context, nonFoodProducts),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(context, List<Map<String, String>> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Image.asset(products[index]['image']!, width: 60, height: 60, fit: BoxFit.cover),
            title: Text(products[index]['title']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    title: products[index]['title']!,
                    imagePath: products[index]['image']!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
