import 'package:flutter/material.dart';

class KiblatPage extends StatelessWidget {
  const KiblatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF006D44)), onPressed: () => Navigator.pop(context)),
        title: const Text('Kiblat', style: TextStyle(color: Color(0xFF006D44), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [Icon(Icons.location_on_outlined, color: Color(0xFF006D44)), SizedBox(width: 20)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.2), width: 2),
                  ),
                ),
                const Icon(Icons.navigation, size: 100), // Ganti dengan aset kompas kamu
                const Icon(Icons.circle, color: Color(0xFF1C1C1C), size: 40),
              ],
            ),
            const SizedBox(height: 40),
            const Text('295° NW', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFDCEFE5), borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF006D44), size: 16),
                  SizedBox(width: 8),
                  Text('Kalibrasi Selesai', style: TextStyle(color: Color(0xFF006D44), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pegang ponsel Anda secara\nhorizontal.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}