import 'package:flutter/material.dart';
import '../constants/warna.dart';

class TemaAplikasi {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Plus Jakarta Sans',
      scaffoldBackgroundColor: WarnaAplikasi.putihIvory,
      primaryColor: WarnaAplikasi.hijauSage,
      colorScheme: const ColorScheme.light(
        primary: WarnaAplikasi.hijauSage,
        secondary: WarnaAplikasi.biruMuted,
        surface: WarnaAplikasi.putihMurni,
        onSurface: WarnaAplikasi.hitamArang,
      ),
    );
  }
  static ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Plus Jakarta Sans',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E), 
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF006D44),
      surface: Color(0xFF121212), // Tambahkan ini
    ),
  );
}
  }



