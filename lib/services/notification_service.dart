import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Inisialisasi plugin notifikasi lokal
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Pengaturan ikon notifikasi (menggunakan ikon bawaan aplikasi Flutter)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // KUNCI PERBAIKAN: Ubah menjadi 'settings:'
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Minta izin khusus Android 13 ke atas agar notifikasi boleh muncul
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // FUNGSI UTAMA UNTUK MEMUTAR ADZAN SESUAI KONDISI DI SETTING PAGE
  static Future<void> tampilkanAdzan({
    required String namaFileAdzan,
    required bool isSilentMode,
    required bool isAdzanReminder,
  }) async {
    
    // Jika Mode Hening Aktif, blokir semua proses (tidak memunculkan apa-apa)
    if (isSilentMode) {
      return; 
    }

    String channelId;
    String channelName;
    bool playSoundAndVibrate;

    // Deteksi apakah pengingat adzan bersuara atau senyap
    if (isAdzanReminder) {
      channelId = 'adzan_berbunyi_$namaFileAdzan';
      channelName = 'Adzan Bersuara';
      playSoundAndVibrate = true;
    } else {
      channelId = 'adzan_senyap';
      channelName = 'Adzan Tanpa Suara';
      playSoundAndVibrate = false; 
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Channel pengingat waktu sholat islami_app',
      importance: playSoundAndVibrate ? Importance.max : Importance.low,
      priority: playSoundAndVibrate ? Priority.high : Priority.low,
      playSound: playSoundAndVibrate,
      enableVibration: playSoundAndVibrate,
      sound: playSoundAndVibrate ? RawResourceAndroidNotificationSound(namaFileAdzan) : null,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    // BARU: Menggunakan named parameters (id:, title:, body:, notificationDetails:)
    await _notificationsPlugin.show(
      id: 1, 
      title: 'Waktunya Sholat!', 
      body: 'Adzan sedang berkumandang...', 
      notificationDetails: notificationDetails,
    );
  }
}