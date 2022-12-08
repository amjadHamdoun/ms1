import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  String pdfUrl;
  String pdfName;
  PdfViewer({
    key,
    required this.pdfUrl,
    required this.pdfName,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff3191f5),
        elevation: 0,
        title: Text(
          widget.pdfName,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      body: Container(
        child: SfPdfViewer.network(widget.pdfUrl),
      ),
    );
  }
}
