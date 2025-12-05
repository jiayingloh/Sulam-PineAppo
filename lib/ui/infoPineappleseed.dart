import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class InfoPineappleSeedPage extends StatelessWidget {
  const InfoPineappleSeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pineapple Seed Guide 🍍"),
        backgroundColor: const Color.fromARGB(255, 101, 139, 96),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SfPdfViewer.asset(
        'assets/pdfs/pineapple_seed_guide.pdf',
        pageSpacing: 0,                         // Remove extra space between pages
        scrollDirection: PdfScrollDirection.vertical, // Portrait scroll
        enableDoubleTapZooming: true,           // Allow double-tap zoom
        canShowScrollHead: true,                // Optional: scroll thumb
        canShowPaginationDialog: true,          // Optional: page jump dialog
        enableTextSelection: true,              // Optional: allow text selection
        enableHyperlinkNavigation: true,        // Optional: follow links
      ),
    );
  }
}
