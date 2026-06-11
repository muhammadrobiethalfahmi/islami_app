import 'package:flutter/material.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Background putih tulang
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Atas (Lokasi & Icon)
              

              // 2. Judul & Subtitle
              const Text(
                'Notifikasi',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pembaruan dan jadwal sholat Anda.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Tab Filter (Pill Buttons)
              Row(
                children: [
                  _buildFilterTab('Jadwal Sholat', isActive: true),
                  const SizedBox(width: 12),
                  _buildFilterTab('Sistem', isActive: false),
                ],
              ),
              const SizedBox(height: 32),

              // 4. Section: HARI INI
              const Text(
                'HARI INI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF757575),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Notifikasi 1
              _buildNotifCard(
                icon: Icons.mosque,
                iconBgColor: const Color(0xFFDCEFE5),
                iconColor: const Color(0xFF006D44),
                time: '15:30 WIB',
                title: 'Waktunya Shalat Ashar',
                content: 'Mari sejenak tinggalkan aktivitas dan dirikan shalat....',
                isUnread: true,
              ),

              // Notifikasi 2
              _buildNotifCard(
                icon: Icons.system_update_alt,
                iconBgColor: const Color(0xFFF3F3F3),
                iconColor: const Color(0xFF666666),
                time: '09:00 WIB',
                title: 'Pembaruan Tersedia',
                content: 'Versi terbaru 2.1.0 kini tersedia dengan peningkatan akurasi kompas kiblat dan perbaikan bug kecil.',
                isUnread: false,
              ),

              const SizedBox(height: 24),

              // 5. Section: KEMARIN
              const Text(
                'KEMARIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF757575),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Notifikasi 3
              _buildNotifCard(
                icon: Icons.mosque_outlined,
                iconBgColor: const Color(0xFFF3F3F3),
                iconColor: const Color(0xFF666666),
                time: '18:05 WIB',
                title: 'Waktunya Shalat Maghrib',
                content: 'Alhamdulillah, waktu berbuka dan shalat Maghrib telah tiba.',
                isUnread: false,
              ),

              // Notifikasi 4
              _buildNotifCard(
                icon: Icons.stars_rounded,
                iconBgColor: const Color(0xFFF3F3F3),
                iconColor: const Color(0xFF666666),
                time: '07:00 WIB',
                title: 'Keutamaan Dhuha',
                content: 'Awali harimu dengan semangat dan raih berkah melalui shalat...',
                isUnread: false,
              ),

              const SizedBox(height: 48),

              // 6. Footer: Checkmark
              Center(
                child: Column(
                  children: [
                    Icon(Icons.done_all, color: Colors.grey.shade400, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Anda telah melihat semua notifikasi',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget: Filter Tab
  Widget _buildFilterTab(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF006D44) : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF555555),
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper Widget: Notification Card
  Widget _buildNotifCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String time,
    required String title,
    required String content,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lingkaran Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),

          // Konten Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1C),
                        ),
                      ),
                    ),
                    if (isUnread)
                      const Icon(Icons.circle, color: Color(0xFFD32F2F), size: 10),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}