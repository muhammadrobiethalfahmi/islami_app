import 'package:flutter/material.dart';
import '../services/prayer_service.dart';
import '../services/city_service.dart';

class JadwalPage extends StatefulWidget {
  final String initialCity;
  const JadwalPage({super.key, required this.initialCity, });
  

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  late String _currentCity ;
  late Future<Map<String, dynamic>> _prayerFuture;

  @override
  void initState() {
    super.initState();
    _currentCity = widget.initialCity;
    _prayerFuture = PrayerService().getJadwalShalat(city: _currentCity);
  }

void _changeCity() {
  TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Ganti Kota'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Contoh: Bandung'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async { // Tambahkan async
            if (controller.text.isNotEmpty) {
              CityService().currentCity = controller.text; // Simpan ke jembatan
              if (CityService().onCityChanged != null) {
                 CityService().onCityChanged!(); // Beritahu Beranda
              }
              // 1. Update UI JadwalPage
              setState(() {
                _currentCity = controller.text;
                _prayerFuture = PrayerService().getJadwalShalat(city: _currentCity);
              });
              
              // 2. Tutup Dialog
              Navigator.pop(context);

              // 3. (OPSIONAL) Jika ingin otomatis kembali ke Beranda setelah search
              // Uncomment baris di bawah ini JIKA Anda ingin otomatis kembali
              Navigator.pop(context, _currentCity); 
            }
          },
          child: const Text('Cari'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final String dateString = "${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}";

    return Scaffold(
      appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, _currentCity), // Kirim kota saat balik
      ),
    ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _prayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF006D44)));
          }
          
          final data = snapshot.data ?? {}; 

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_currentCity, Indonesia', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF006D44))),
                      const Icon(Icons.location_on_outlined, color: Color(0xFF006D44), size: 24),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('Jadwal Sholat', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF1C1C1C))),
                  const SizedBox(height: 8),
                  Text(dateString, style: const TextStyle(fontSize: 14, color: Color(0xFF757575), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _changeCity, 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(30)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Titik Lokasi Saat Ini ', style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
                          Text('Ubah', style: TextStyle(color: Color(0xFF006D44), fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildCardSholat(nama: 'Subuh', waktu: data['Fajr'] ?? '--:--', status: 'Waktu Shalat', icon: Icons.wb_twilight, trailingWidget: const Icon(Icons.notifications_off_outlined, color: Color(0xFF888888), size: 22)),
                  _buildCardSholat(nama: 'Dzuhur', waktu: data['Dhuhr'] ?? '--:--', status: 'Waktu Shalat', icon: Icons.wb_sunny_outlined, trailingWidget: const Icon(Icons.notifications, color: Color(0xFF006D44), size: 22)),
                  _buildCardSholat(nama: 'Ashar', waktu: data['Asr'] ?? '--:--', status: 'Waktu Shalat', icon: Icons.wb_cloudy_outlined, trailingWidget: const Icon(Icons.notifications, color: Color(0xFF006D44), size: 22)),
                  _buildCardSholat(nama: 'Maghrib', waktu: data['Maghrib'] ?? '--:--', status: 'Waktu Shalat', icon: Icons.dark_mode_outlined, trailingWidget: const Icon(Icons.notifications, color: Color(0xFF006D44), size: 22)),
                  _buildCardSholat(nama: 'Isya', waktu: data['Isha'] ?? '--:--', status: 'Waktu Shalat', icon: Icons.dark_mode_outlined, trailingWidget: const Icon(Icons.notifications_none, color: Color(0xFF333333), size: 22)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardSholat({
    required String nama,
    required String waktu,
    required String status,
    required IconData icon,
    required Widget trailingWidget,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCEFE5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? Border.all(color: const Color(0xFFB5D7C5), width: 1.5)
            : Border.all(color: Colors.transparent, width: 0),
        boxShadow: isActive ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFC3DACF) : const Color(0xFFF3F3F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? const Color(0xFF006D44) : const Color(0xFF666666), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isActive ? const Color(0xFF006D44) : const Color(0xFF1C1C1C))),
                const SizedBox(height: 2),
                Text(status, style: TextStyle(fontSize: 13, color: isActive ? const Color(0xFF006D44) : const Color(0xFF888888))),
              ],
            ),
          ),
          Text(waktu, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1C))),
          const SizedBox(width: 16),
          trailingWidget,
        ],
      ),
    );
  }
}