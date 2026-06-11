import 'package:flutter/material.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int _counter = 0;

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
        title: const Text('Jakarta, Indonesia', style: TextStyle(color: Color(0xFF006D44), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [Icon(Icons.location_on_outlined, color: Color(0xFF006D44)), SizedBox(width: 20)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(20)),
            child: const Text('custom', style: TextStyle(color: Color(0xFF555555))),
          ),
          const SizedBox(height: 30),
          const Text('TARGET', style: TextStyle(color: Colors.grey, letterSpacing: 2)),
          const Text('33', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1C1C1C))),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _counter++),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$_counter', style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF006D44))),
                  const Text('Ketuk untuk menghitung', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const Spacer(flex: 2),
          IconButton(
            onPressed: () => setState(() => _counter = 0),
            icon: const Icon(Icons.refresh, color: Colors.grey, size: 30),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}