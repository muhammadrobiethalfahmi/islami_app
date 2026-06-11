import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Definisikan Model di sini agar bisa diakses oleh Service
class HolidayEvent {
  final DateTime date;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  HolidayEvent({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  // Factory untuk memproses data dari API/Gist
  factory HolidayEvent.fromJson(Map<String, dynamic> json) {
    return HolidayEvent(
      date: DateTime.parse(json['tanggal']),
      title: json['keterangan'],
      subtitle: json['subtitle'] ?? 'Hari Libur Nasional',
      color: const Color(0xFFD32F2F),
      icon: Icons.celebration_rounded,
    );
  }
}

class HolidayService {
  // Ganti URL ini dengan URL Gist RAW Anda
  static const String myGistUrl = "https://gist.githubusercontent.com/username/xxxxxx/raw/holidays.json";

  static Future<List<HolidayEvent>> getHolidays() async {
    try {
      final response = await http.get(Uri.parse(myGistUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => HolidayEvent.fromJson(item)).toList();
      } else {
        return _getEmergencyData();
      }
    } catch (e) {
      return _getEmergencyData();
    }
  }

  static List<HolidayEvent> _getEmergencyData() {
    return [
      HolidayEvent(
        date: DateTime(2026, 6, 12),
        title: 'Idul Adha',
        subtitle: '10 Dzulhijjah 1447 H',
        color: const Color(0xFFD32F2F),
        icon: Icons.celebration_rounded,
      ),
      HolidayEvent(
        date: DateTime(2026, 6, 1),
        title: 'Awal Bulan Hijriah',
        subtitle: '1 Dzulhijjah 1447 H',
        color: const Color(0xFF006D44),
        icon: Icons.nightlight_round_rounded,
      ),
    ];
  }
}