import 'package:flutter/material.dart';
import 'package:islami_app/pages/welcome_page.dart';
import 'core/theme_notifier.dart'; 
import 'core/tema/tema_aplikasi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';


void main() async {
  // 3. Tambahkan 2 baris ini di dalam void main() dan ubah menjadi 'async'
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  
  runApp(const MyIslamicApp());
}


class MyIslamicApp extends StatelessWidget {
  const MyIslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, 
      builder: (_, currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          
          // 1. Setup Tema Terang (Global Nav Theme)
          theme: TemaAplikasi.lightTheme.copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF006D44),
              unselectedItemColor: Colors.grey,
            ),
          ),
          
          // 2. Setup Tema Gelap (Global Nav Theme)
          darkTheme: TemaAplikasi.darkTheme.copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF121212), // Warna background gelap
              selectedItemColor: Color(0xFF006D44), // Hijau tetap terlihat
              unselectedItemColor: Colors.white60,  // Warna icon tidak terpilih
            ),
          ),
          
          themeMode: currentMode,
          home: const WelcomePage(), // Tanpa const
          
        );
      },
    );
  }
}