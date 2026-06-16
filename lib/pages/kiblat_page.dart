import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';

class KiblatPage extends StatefulWidget {
  const KiblatPage({super.key});

  @override
  State<KiblatPage> createState() => _KiblatPageState();
}

class _KiblatPageState extends State<KiblatPage> {
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _isLoading = false; _hasPermission = false; });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _isLoading = false; _hasPermission = false; });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() { _isLoading = false; _hasPermission = false; });
      return;
    }

    setState(() {
      _hasPermission = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006D44)), 
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kiblat', style: TextStyle(color: Color(0xFF006D44), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [Icon(Icons.location_on_outlined, color: Color(0xFF006D44)), SizedBox(width: 20)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF006D44)))
          : !_hasPermission
              ? const Center(child: Text('Mohon izinkan akses lokasi untuk menggunakan Kompas Kiblat.'))
              : StreamBuilder<QiblahDirection>(
                  stream: FlutterQiblah.qiblahStream,
                  builder: (context, snapshot) {
                    // 1. JIKA TERJADI ERROR
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'Error: Perangkat tidak mendukung sensor kompas atau GPS mati.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }

                    // 2. JIKA MASIH MENUNGGU SINYAL/SENSOR
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF006D44)),
                            const SizedBox(height: 20),
                            Text(
                              'Mengalibrasi Kompas & GPS...',
                              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pastikan GPS aktif & tes di HP fisik (Bukan Emulator)',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }

                    // 3. JIKA DATA SUDAH SIAP (UI Utama)
                    final qiblahDirection = snapshot.data!;
                    
                    // Memastikan nilai derajat tetap positif di rentang 0-360 derajat
                    final double cleanQiblah = qiblahDirection.qiblah >= 0
                        ? qiblahDirection.qiblah % 360
                        : (qiblahDirection.qiblah % 360) + 360;
                    
                    // PERBAIKAN UTAMA: Menggunakan qiblahDirection.qiblah dan dikali -1 
                    // agar putaran jarum berlawanan dengan gerakan HP (mengunci ke arah Ka'bah)
                    final double angleInput = (qiblahDirection.qiblah * (math.pi / 180) * -1);

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 300, height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.withOpacity(0.2), width: 2),
                                ),
                              ),
                              Transform.rotate(
                                angle: angleInput, 
                                child: const Icon(
                                  Icons.navigation, 
                                  size: 100, 
                                  color: Color(0xFF006D44),
                                ),
                              ),
                              const Icon(Icons.circle, color: Color(0xFF1C1C1C), size: 40),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Text(
                            '${cleanQiblah.toStringAsFixed(0)}° NW', 
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFDCEFE5), borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Color(0xFF006D44), size: 16),
                                SizedBox(width: 8),
                                Text('Kalibrasi Selesai', style: TextStyle(color: Color(0xFF006D44), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Pegang ponsel Anda secara\nhorizontal.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}