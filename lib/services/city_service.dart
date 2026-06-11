// lib/services/city_service.dart
class CityService {
  // Membuat Singleton (agar satu-satunya instance di seluruh aplikasi)
  static final CityService _instance = CityService._internal();
  factory CityService() => _instance;
  CityService._internal();

  // Variabel Global
  String currentCity = 'Jakarta';
  
  // Callback untuk memberitahu halaman lain kalau kota berubah
  Function? onCityChanged; 
}