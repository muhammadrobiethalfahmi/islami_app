import 'package:flutter/material.dart';

class DoaPage extends StatelessWidget {
  const DoaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Jakarta, Indonesia', style: TextStyle(color: Color(0xFF006D44), fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.location_on_outlined, color: Color(0xFF006D44)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Doa Harian', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari doa untuk hari ini...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab(Icons.wb_sunny, 'Pagi & Petang', true),
                  _buildTab(Icons.bed_outlined, 'Tidur', false),
                  _buildTab(Icons.restaurant, 'Makan', false),
                ],
              ),
              const SizedBox(height: 30),
              _buildDoaCard(
                'Alhamdulillāhilladhī ahyānā ba\'da mā amātanā wa ilayhin-nushūr',
                'Segala puji bagi Allah yang menghidupkan kami kembali setelah mematikan kami dan kepada-Nya kami akan dibangkitkan.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: active ? const Color(0xFF006D44) : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(icon, color: active ? Colors.white : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDoaCard(String arabic, String trans) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Align(alignment: Alignment.topRight, child: Icon(Icons.location_on_outlined, color: Color(0xFF006D44))),
          Text(arabic, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.5)),
          const SizedBox(height: 16),
          Text('"$trans"', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}