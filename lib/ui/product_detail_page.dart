import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String title;
  final String imagePath;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Content based on selected title
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath, height: 200, width: double.infinity, fit: BoxFit.cover),
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
if (title == "Halwa Nanas") {
  return """
Halwa Nanas adalah hasil nanas yang diawet dan dikeringkan menggunakan gula hingga mencapai kepekatan tinggi (60°Bx) untuk mencegah kerosakan. Selepas dikeringkan, ia disalut dengan gula halus.

📌 Cara Pembuatan Ringkas:
1. Celur isi nanas 1–2 minit.
2. Masak gula dengan air hingga larut.
3. Tambah bahan awet (asid sitrik dan natrium metabisulfat) ke dalam sirap.
4. Rendam nanas dan pastikan tenggelam.
5. Tambah kepekatan gula setiap hari hingga 60°Bx, tahan selama 3 hari.
6. Toskan dan keringkan dalam oven pada 40–45°C selama 7–9 jam.
7. Salut dengan gula halus selepas kering.

✔ Teknik pengawetan tradisional  
✔ Sesuai sebagai kudapan manis  
""";
}


if (title == "Skuas Nanas") {
  return """
Skuas Nanas ialah minuman ringan berasaskan jus/pulpa nanas dengan pH rendah (~2.9–3.0). Ia pekat, tinggi gula (40°Bx–50°Bx) dan menggunakan bahan awet untuk mengawal kulat, yis serta mengekalkan warna.

📌 Cara Pembuatan Ringkas:
1. Hancurkan isi nanas, masak pada 90–95°C dan tapis.
2. Tambah asid sitrik (0.4%) untuk stabilkan pH dan panaskan semula.
3. Campur xanthum-gum (0.15–0.25%) dengan gula, kemudian masukkan ke dalam jus.
4. Panaskan hingga 90–95°C selama 4–5 minit untuk basmi mikroorganisma.
5. Sejukkan sedikit sebelum tuang dalam botol.
6. Boleh tambah pewarna & perisa nanas jika mahu lebih menarik.

✔ Tinggi kandungan gula  
✔ Stabil & tahan lebih lama  
✔ Minuman pekat berperisa nanas  
""";
}


if (title == "Jeruk Nanas") {
  return """
Jeruk Nanas ialah buah nanas yang telah difermentasikan dan diawet menggunakan garam. Fermentasi menggunakan air garam terkawal untuk menyekat aktiviti enzim dan halang pertumbuhan mikroorganisma.

📌 Cara Pembuatan Ringkas:
1. Fermentasi (2 minggu):
   - Buang kulit nanas, potong mengikut kehendak.
   - Celur 1 minit dalam air mendidih, tos.
   - Rendam dalam air garam 10–12%, tambahkan garam setiap hari sehingga stabil.
   - Tindih dengan beg plastik berisi air untuk elak nanas timbul, tutup.
2. Kurangkan kemasinan & kerangupan:
   - Selepas 2 minggu, rendam nanas dalam larutan alum 0.4% (nisbah 1:4) selama 4 jam – semalaman.
   - Tos dan bilas bersih.
3. Penyediaan sirap:
   - Masak larutan gula hingga mendidih, campur asid sitrik & bahan awet, sejukkan.
   - Basuh botol panas, isi nanas & sirap (nisbah 1:1), tutup rapat.
   - Simpan 4–5 hari sebelum dipasarkan.

✔ Proses fermentasi terkawal  
✔ Rasanya masam manis & tahan lama  
✔ Sesuai untuk jualan atau penggunaan snek
""";
}


if (title == "Sos Nanas Manis") {
  return """
Sos Nanas Manis disediakan daripada puri nanas, garam, gula dan bahan pemekat, dimasak sehingga mendidih. Pemilihan nanas segar dan matang penting untuk mutu sos yang baik. Asid sitrik digunakan untuk menurunkan pH < 4.5 bagi kesan maksimum bahan awet (Natrium Benzoat). Sos dibotolkan semasa panas untuk mengurangkan pencemaran mikroorganisma.

📌 Kaedah Ringkas:
1. Pilih nanas matang, buang kulit & mata, jadikan puri.
2. Panaskan puri dalam periuk sambil dikacau.
3. Masukkan campuran gula, gam & garam, didihkan.
4. Masukkan bancuhan kanji, kacau & didihkan.
5. Tambah asid & bahan awet, terus didihkan hingga 40°Bx.
6. Angkat & botolkan semasa panas, tutup segera.

✔ Sos tahan lama & berwarna seragam  
✔ Rasanya seimbang, manis & pekat  
✔ Sesuai untuk kegunaan masakan atau jualan
""";
}


if (title == "Nanas Kering") {
  return """
Buah nanas kering diproses menggunakan alat pengering. Sedikit gula tambahan dan asid askorbik digunakan untuk mengelakkan browning. Penambahan gula halus bergantung pada citarasa. Produk ini rendah kalori dan tinggi serat.

📌 Kaedah Ringkas:
1. Buang kulit, empulur & mata nanas, cuci bersih.
2. Potong buah mengikut bentuk 'chunk' atau citarasa.
3. Rendam dalam asid askorbik selama 5 minit.
4. Tos & keringkan.
5. Masukkan ke dalam oven 50–52°C selama 10 jam.
6. Keluarkan, tabur sedikit gula halus & biar sejuk sebelum dibungkus.

✔ Snek sihat & semula jadi  
✔ Tinggi serat  
✔ Sesuai sebagai kudapan
""";
}


if (title == "Sos Nanas Bercili") {
  return """
Sos Nanas Bercili dibuat dari puri nanas, cili, bawang putih, gula, garam dan bahan pemekat. Sos dimasak untuk membasmi mikroorganisma, mengekalkan warna, kepekatan dan mutu yang seragam.

📌 Kaedah Ringkas:
1. Pilih nanas matang & tidak rosak, buang kulit, mata dan buat puri.
2. Cili & bawang putih dibersihkan & dikisar.
3. Masukkan puri nanas, cili & bawang putih ke periuk, panaskan sambil dikacau.
4. Masukkan campuran gula, gam & garam, didihkan.
5. Tambah bancuhan kanji & didihkan sambil kacau.
6. Masukkan bancuhan asid & bahan awet, didihkan hingga 40°Bx.
7. Angkat, botolkan semasa panas & tutup segera.

✔ Snek pedas & berperisa nanas  
✔ Selamat & berkualiti
""";
}


if (title == "Jem Nanas") {
  return """
Jem Nanas dibuat dari nanas matang, dimasak bersama gula dan bahan tambahan sehingga likat dan akan beku apabila disejukkan.

📌 Kaedah Ringkas:
1. Buah nanas matang dibuang kulit, mata & empulur, dibasuh & dihancurkan.
2. Panaskan isi nanas perlahan-lahan dalam kawah.
3. Gaul pektin dengan gula, masukkan sedikit demi sedikit supaya tidak berketul.
4. Kacau hingga hampir pekat (68°Bx).
5. Masukkan asid sitrik & kacau sebati (pH 2.8–3.4).
6. Botolkan semasa panas supaya jem tidak set sebelum ditutup.
7. Tutup rapat botol untuk mengekalkan separa vakum & elak pencemaran mikroorganisma.

✔ Jem manis & berperisa nanas  
✔ Selamat & berkualiti
""";
}

if (title == "Bromelin") {
  return """
📌 Pengenalan
Bromelin adalah saringan kepekatan enzim bromelain daripada pelbagai jenis nanas komersial di Malaysia. Nanas merupakan salah satu tanaman komoditi utama di Malaysia dan kaya dengan nutraseutikal.

📌 Metodologi
1. Buah nanas dituai dari ladang, dicuci, dikupas dan dipotong.
2. Isi dan empulur dipisahkan, kemudian dikisar berasingan untuk mendapatkan jus.
3. Jus ditapis dan pH direkodkan bagi setiap jenis nanas.
4. Kepekatan bromelain ditentukan menggunakan HPLC pada panjang gelombang 260nm dan 280nm.
5. Jenis nanas yang diuji: Crystal Honey, Gandul, Moris Gajah, Josapine, N36, Yankee.

✔ Potensi kesihatan sebagai nutraseutikal  
✔ Digunakan dalam pelbagai produk komersial
""";
}

if (title == "Baja Bio-Organik (BOF)") {
  return """
📌 Pengenalan
Produk terhasil daripada sisa nanas yang diolah menjadi baja Bio-Organik (BOF) menggunakan teknologi Effective Microorganisms (EM).  
Kelebihan penggunaan sisa nanas:
✔ Tiada pembakaran terbuka diperlukan  
✔ Nitrogen daripada sisa kembali ke tanah  
✔ Penggunaan racun kimia dikurangkan  
✔ Mesra alam

📌 Metodologi
Formula A (BOF asas nanas):
- Sisa Nanas: 75 kg
- Sekam Padi: 10 kg
- Tinja Puyuh: 10 kg
- Molases: 3L
- EM Solution: 3L
- Air: 18L

Formula B (penambah sekam padi untuk K):
- Sama seperti Formula A + 10 kg sekam padi terbakar

📌 Prosedur
Day 1: Campur semua bahan 15 minit, tutup dengan gunny sack  
Day 2: Buka, gaul lagi 15 minit, tutup semula (kontrol suhu 45–50°C)  
Day 3: Ulang Day 2  
Day 4: Pastikan campuran setinggi 10 cm, tutup, biar sehingga Day 7  
Day 5: Campuran menjadi BOF, boleh digunakan atau disimpan  

✔ Produk siap digunakan sebagai baja nanas berasaskan sisa organik
""";
}

if (title == "Silaj") {
  return """
📌 Pengenalan
Silaj daun nanas dihasilkan menggunakan Bio-Teknologi EM (Effective Microorganisms), iaitu campuran bakteria phototropik, asid laktik dan yis.  
EM bekerja secara sinergi untuk membantu fermentasi sisa nanas menjadi makanan ternakan yang selamat dan berkhasiat.

📌 Metodologi
Larutan EM disediakan untuk 10L kontena:
- Larutan EM: 300 ml
- Gula merah: 1 kg
- Garam: 0.5 kg
- Air tanpa klorin: secukupnya

Bancuh bahan sehingga sebati dan gunakan untuk proses penghasilan silaj.

📌 Keputusan Parameter (Moisture, Ash, Protein, Fat, Crude fiber, Carbohydrate)  
- Moisture meningkat dari 24.76% (Hari 1) ke 80.86% (Hari 70)  
- Protein meningkat dari 0.02% ke 0.26%  
- Carbohydrate menurun dari 56.68% ke 15.20%  

📌 Keselamatan
- Ujian Mycotoxin menunjukkan aflatoxin <5 ppb, ochratoxin <2 ppb sehingga 70 hari  
- Kajian ternakan ruminan menunjukkan tiada keracunan dan selamat dimakan  

✔ Sesuai digunakan sebagai silaj ternakan berasaskan sisa nanas
""";
}

if (title == "Kertas Daun Nanas") {
  return """
📌 Pengenalan
Serat daun nanas adalah serat semulajadi yang kukuh dan tinggi kandungan selulosanya, sesuai digunakan sebagai bahan asas penghasilan kertas.  
Penghasilan kertas daun nanas dilakukan melalui kaedah kimia dan mekanikal.

📌 Metodologi
- Mekanikal: Daun dikeringkan, dikisar, diluntur dan dilekat dengan kanji beras, ubi atau sagu.  
- Kimia: Rawatan dengan Sodium Hydroxide dan Acetone digunakan ke atas daun nanas.

📌 Keputusan Ujian
1. Tensile:  
   - Kanji beras (Mekanikal) = keras, kuat, kukuh  
   - Kanji sagu/ubi (Mekanikal) = lembut dan kukuh  
   - Kimia = mudah pecah dan rapuh  

2. Tear: nilai (Nm2/kg) berbeza mengikut kaedah dan kanji; mekanikal lebih baik untuk kekukuhan.  

3. Serapan Air: mekanikal lebih sesuai untuk ciri air rendah bagi kanji beras.

📌 Kesimpulan
- Proses mekanikal lebih sesuai untuk pembuatan kertas kraftangan.  
- Gabungan serat daun nanas dengan kanji beras menunjukkan ciri keras dan kukuh.  
- Daun nanas boleh dijadikan bahan mentah gantian dalam pembuatan kertas.
""";
}

if (title == "Papan Gentian") {
  return """
📌 Pengenalan
Sisa kulit nanas kaya dengan selulosa dan hemicellulose, sesuai dijadikan bahan komposit biodegradable.  
Kulit nanas digabungkan dengan polyethylene berkepadatan tinggi untuk membentuk bahan baru yang mesra alam dan selamat untuk alam sekitar.

📌 Kelebihan
✔ Tetulang yang baik, meningkatkan sifat mekanikal  
✔ Mesra alam dan boleh dikitar semula  
✔ Mengurangkan keretakan dan serpihan  
✔ Pengembangan haba rendah dan ketahanan tinggi  
✔ Penyelenggaraan rendah

📌 Aplikasi
- Bahan pembungkusan berfiber tinggi  
- Alternatif bahan asas kayu atau plastik konvensional
""";
}

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