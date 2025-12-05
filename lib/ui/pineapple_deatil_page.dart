import 'package:flutter/material.dart';

class PineappleDetailPage extends StatelessWidget {
  final String title;
  final List<String> imagePaths; // changed from String

  const PineappleDetailPage({
    super.key,
    required this.title,
    required this.imagePaths,
  });

   @override
  Widget build(BuildContext context) {
    String description = _getDescription();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
  height: 200, // or screenHeight * 0.5
  child: PageView(
    children: imagePaths.map((path) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          width: double.infinity,
          fit: BoxFit.cover, // fills the box proportionally
        ),
      );
    }).toList(),
  ),
),



            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }


// 📌 Description for all products
String _getDescription() {

if (title == "Spanish") {
  return """
✔Prickly at the ends of leaves
✔Has 2-12 basal slips at the base of the stalk
✔Suitable for canning
✔The color of the green fruit turns dark purple or reddish orange when ripe
✔Types of pineapples : Mas Merah pineapple (Singapore Spanish), Nanas hijau (Selangor Green),Gandul pineapple,Nanas nangka, Nanas betik pineapples
✔Large crown
✔Fruit lasts long
✔Cylindrical-shaped fruit
""";
}

if (title == "Smooth Cayenne") {
  return """
✔Large-sized fruit
✔Pineapple eyes are flat
✔Dark green-colored leaves
✔Taper-shaped fruit
""";
}

if (title == "Queen") {
  return """
✔Taper-shaped fruit
✔Suitable to be eaten fresh
✔Bluish green-colored leaves and purple in the centre
✔Prickly leaves
✔Example: Moris Pineapple (Mauritius),Yankee Pineapple (Selangor sweet), Moris Gajah Pineapple
""";
}


if (title == "Hybrid") {
  return """
✔Cylindrical-shaped fruit
✔Pineapple eyes are flat
✔Green-colored leaves
✔Slightly prickly leaves
✔Suitable to be eaten fresh
✔Types of pineapples : N36 Pineapple, Josapine Pineapple, Masapine Pineapple, MD2 Pineapple
""";
}



  return "Maklumat produk belum disediakan.";
}

}