import 'package:flutter/material.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0;
  int _target = 33; 
  
  final TextEditingController _targetController = TextEditingController();

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _showEditTargetDialog() {
    _targetController.text = _target.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Atur Target Tasbih',
            style: TextStyle(color: Color(0xFF006D44), fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan jumlah target zikir yang Anda inginkan:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 100',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF006D44), width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final int? inputBaru = int.tryParse(_targetController.text);
                if (inputBaru != null && inputBaru > 0) {
                  setState(() {
                    _target = inputBaru;
                    _counter = 0; // Opsional: reset hitungan ke 0 kalau targetnya diubah
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Masukkan angka target yang valid!')),
                  );
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah hitungan sudah mencapai target
    final bool isTargetReached = _counter >= _target;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006D44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jakarta, Indonesia', 
          style: TextStyle(color: Color(0xFF006D44), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.location_on_outlined, color: Color(0xFF006D44)), 
          SizedBox(width: 20)
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _showEditTargetDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'custom', 
                  style: TextStyle(color: Color(0xFF555555), fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('TARGET', style: TextStyle(color: Colors.grey, letterSpacing: 2)),
            Text(
              '$_target', 
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C)),
            ),
            const Spacer(),
            
            //Kunci Target
            GestureDetector(
              onTap: () {
                // Hanya bertambah jika konter masih di bawah target
                if (_counter < _target) {
                  setState(() {
                    _counter++;
                  });
                }
              },
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  // Mengubah warna border/shadow sedikit menjadi hijau samar kalau target sudah tercapai
                  border: isTargetReached 
                      ? Border.all(color: const Color(0xFF006D44).withOpacity(0.5), width: 4) 
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isTargetReached 
                          ? const Color(0xFF006D44).withOpacity(0.1) 
                          : Colors.black.withOpacity(0.05), 
                      blurRadius: 30, 
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_counter', 
                      style: TextStyle(
                        fontSize: 80, 
                        fontWeight: FontWeight.bold, 
                        // Jika target tercapai, warnanya berubah sedikit berbeda sebagai penanda
                        color: isTargetReached ? const Color(0xFF2E7D32) : const Color(0xFF006D44),
                      ),
                    ),
                    Text(
                      isTargetReached ? 'Target Selesai!' : 'Ketuk untuk menghitung', 
                      style: TextStyle(
                        color: isTargetReached ? const Color(0xFF2E7D32) : Colors.grey,
                        fontWeight: isTargetReached ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            IconButton(
              onPressed: () => setState(() => _counter = 0),
              icon: const Icon(Icons.refresh, color: Colors.grey, size: 30),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}