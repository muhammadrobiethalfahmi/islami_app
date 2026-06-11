import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerService {
  Future<Map<String, dynamic>> getJadwalShalat({String city = 'Jakarta'}) async {
    print('DEBUG: Sedang mencari jadwal untuk kota: $city');
    
    final url = Uri.parse('https://api.aladhan.com/v1/timingsByCity?city=$city&country=Indonesia&method=20');
    
    try {
      final response = await http.get(url);
      
      // FIX PRINT: Jangan print 'response', print 'response.body'
      print('DEBUG: Data body dari $city: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        
        // Pastikan key 'data' dan 'timings' benar-benar ada
        if (decoded.containsKey('data') && decoded['data'].containsKey('timings')) {
          return decoded['data']['timings'];
        } else {
          throw Exception('Format data tidak sesuai');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG ERROR: $e');
      throw Exception('Gagal mengambil data: $e');
    }
  }
}