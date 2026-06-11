import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/constants/kutipan_data.dart';
import '../../core/constants/warna.dart';
import '../pages/tasbih_page.dart';
import '../pages/doa_page.dart';
import '../pages/jadwal_page.dart';
import '../pages/kiblat_page.dart';
import '../services/prayer_service.dart';
import '../services/city_service.dart'; 

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  String _targetCity = 'Jakarta'; 
  late Future<Map<String, dynamic>> _prayerFuture;

  @override
  void initState() {
    super.initState();
    
    // Ambil kota terbaru dari Jembatan (CityService)
    _targetCity = CityService().currentCity;
    
    // Pasang "pendengar" agar Beranda otomatis update jika ada perubahan kota
    CityService().onCityChanged = () {
      if (mounted) {
        setState(() {
          _targetCity = CityService().currentCity;
        });
        _loadData();
      }
    };
    
    _loadData();
  }

  void _loadData() {
    setState(() {
      _prayerFuture = PrayerService().getJadwalShalat(city: _targetCity);
    });
  }

  // --- HELPER LOGIKAWAKTU & COUNTDOWN ---

  // Stream utama untuk memperbarui Jam, Countdown, dan Tanggal setiap detik
  Stream<DateTime> _clockStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  // Fungsi untuk memparsing string "HH:mm" dari API menjadi objek DateTime
  DateTime _parsePrayerTime(String timeStr, DateTime now) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return now;
    final hour = int.tryParse(parts[0].trim()) ?? 0;
    // Bersihkan jika ada teks tambahan seperti "WIB" di belakang menit
    final minute = int.tryParse(parts[1].trim().split(' ')[0]) ?? 0;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Fungsi untuk menentukan waktu sholat berikutnya dan sisa waktunya
  Map<String, String> _getNextPrayerInfo(Map<String, dynamic> data, DateTime now) {
    final fajrStr = data['Fajr'] ?? data['Subuh'] ?? '04:30';
    final dhuhrStr = data['Dhuhr'] ?? data['Dzuhur'] ?? '12:00';
    final asrStr = data['Asr'] ?? data['Ashar'] ?? '15:15';
    final maghribStr = data['Maghrib'] ?? '18:00';
    final ishaStr = data['Isha'] ?? data['Isya'] ?? '19:15';

    final list = [
      {'nama': 'Subuh', 'waktu': _parsePrayerTime(fajrStr, now), 'str': fajrStr},
      {'nama': 'Dzuhur', 'waktu': _parsePrayerTime(dhuhrStr, now), 'str': dhuhrStr},
      {'nama': 'Ashar', 'waktu': _parsePrayerTime(asrStr, now), 'str': asrStr},
      {'nama': 'Maghrib', 'waktu': _parsePrayerTime(maghribStr, now), 'str': maghribStr},
      {'nama': 'Isya', 'waktu': _parsePrayerTime(ishaStr, now), 'str': ishaStr},
    ];

    for (var prayer in list) {
      final pTime = prayer['waktu'] as DateTime;
      if (pTime.isAfter(now)) {
        final diff = pTime.difference(now);
        return {
          'nama': prayer['nama'] as String,
          'waktu': prayer['str'] as String,
          'countdown': _formatDuration(diff),
        };
      }
    }

    // Jika sudah melewati Isya, maka target berikutnya adalah Subuh esok hari
    final tomorrowFajr = _parsePrayerTime(fajrStr, now).add(const Duration(days: 1));
    final diff = tomorrowFajr.difference(now);
    return {
      'nama': 'Subuh',
      'waktu': fajrStr,
      'countdown': _formatDuration(diff),
    };
  }

  // Mengubah durasi menjadi format HH:mm:ss
  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // Mengambil format tanggal Indonesia: Hari, DD/MM/YYYY
  String _getFormattedDate(DateTime now) {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final dayName = days[now.weekday - 1];
    final day = now.day.toString().padLeft(2, '0');
    final months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthName = months[now.month - 1];
    final year = now.year;
    return "$dayName, $day $monthName $year";
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final kutipan = KutipanData.daftarKutipan[random.nextInt(KutipanData.daftarKutipan.length)];

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _prayerFuture,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. ERROR
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // 3. Data Kosong
          if (!snapshot.hasData || (snapshot.data as Map).isEmpty) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          // 4. Data Sukses
          final data = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // StreamBuilder disematkan di sini untuk mengontrol pembaruan real-time konten Header Card
                  StreamBuilder<DateTime>(
                    stream: _clockStream(),
                    builder: (context, clockSnapshot) {
                      final now = clockSnapshot.data ?? DateTime.now();
                      final jamDigital = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                      final infoSholat = _getNextPrayerInfo(data, now);
                      final tanggalHariIni = _getFormattedDate(now);

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [WarnaAplikasi.hijauSage, WarnaAplikasi.biruMuted],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Atas: Lokasi & Jam Digital aktif
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('LOKASI: $_targetCity', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text(
                                  jamDigital,
                                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Bagian Tengah: Nama Sholat, Waktu, & Countdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(infoSholat['nama']!, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                                    Text(infoSholat['waktu']!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 6),
                                    // Sisa waktu / Countdown menuju shalat berikutnya
                                    Text(
                                      'Sisa waktu: ${infoSholat['countdown']}', 
                                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                                Icon(Icons.wb_sunny_outlined, size: 64, color: Colors.white.withOpacity(0.4)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white24, thickness: 1),
                            const SizedBox(height: 12),
                            // Mengganti teks Maghrib lama menjadi Tanggal Hari Ini formal (Hari, DD/MM/YYYY)
                            Text(tanggalHariIni, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                  const Text('Pintasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WarnaAplikasi.hitamArang)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShortcutItem(
                        context, 
                        Icons.calendar_month, 
                        'Jadwal', 
                        const Color(0xFFE8F5E9), 
                        () async {
                          await Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => JadwalPage(initialCity: _targetCity))
                          );
                        }
                      ),
                      _buildShortcutItem(context, Icons.adjust, 'Tasbih', const Color(0xFFE3F2FD), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TasbihPage()))),
                      _buildShortcutItem(context, Icons.menu_book, 'Doa', const Color(0xFFF5F5F5), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoaPage()))),
                      _buildShortcutItem(context, Icons.explore_outlined, 'Kiblat', const Color(0xFFF5F5F5), () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KiblatPage()))),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildQuoteSection(kutipan),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShortcutItem(BuildContext context, IconData icon, String label, Color bgColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)), child: Icon(icon, color: WarnaAplikasi.hijauSage, size: 28)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: WarnaAplikasi.hitamArang)),
        ],
      ),
    );
  }

  Widget _buildQuoteSection(Map<String, dynamic> kutipan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.lightbulb_outline, color: WarnaAplikasi.hijauSage), SizedBox(width: 8), Text('KUTIPAN HARI INI', style: TextStyle(color: WarnaAplikasi.hijauSage, fontWeight: FontWeight.bold, fontSize: 12))]),
          const SizedBox(height: 16),
          Text('"${kutipan['teks']}"', style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Text('— ${kutipan['sumber']}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}