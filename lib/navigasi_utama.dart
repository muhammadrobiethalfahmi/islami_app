import 'package:flutter/material.dart';
import 'core/constants/warna.dart';
import 'pages/beranda_page.dart';
import 'pages/jadwal_page.dart';
import 'pages/notifikasi_page.dart';
import 'pages/pengaturan_page.dart';
import 'pages/kalender_page.dart';




class NavigasiUtama extends StatefulWidget {
  const NavigasiUtama({super.key});

  @override
  State<NavigasiUtama> createState() => _NavigasiUtamaState();
}

class _NavigasiUtamaState extends State<NavigasiUtama> {
  int _currentIndex = 0;

  final List<Widget> _halaman = [
    const BerandaPage(),
    const JadwalPage(initialCity: '',),
    const NotifikasiPage(),
    const KalenderPage(),
    const PengaturanPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _halaman,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: WarnaAplikasi.putihMurni,
          boxShadow: [
            BoxShadow(
              color: WarnaAplikasi.hitamArang.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: WarnaAplikasi.putihMurni,
          selectedItemColor: WarnaAplikasi.hijauSage,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.time_to_leave_rounded),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifikasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Kalender',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}