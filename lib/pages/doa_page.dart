import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 

class DoaPage extends StatefulWidget {
  const DoaPage({super.key});

  @override
  State<DoaPage> createState() => _DoaPageState();
}

class _DoaPageState extends State<DoaPage> {
  String _selectedCategory = 'Doa Keseharian';
  String _searchQuery = '';
  
  List<dynamic> _listKeseharian = [];
  List<dynamic> _listSholat = [];
  List<dynamic> _listTahlil = [];
  bool _isLoading = true;

  // ID User  mengikuti akun yang  login saat ini.
  // Jika belum login, dia akan memakai cadangan "user_pembaca_doa_123" agar aplikasi tidak crash.
  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? "user_pembaca_doa_123"; 

  // List lokal ini tetap kita jaga hanya untuk mengecek status warna icon bookmark di halaman utama
  List<dynamic> _savedDoasLocal = [];

  @override
  void initState() {
    super.initState();
    _loadAllJsonData();
    _listenToBookmarksRealtime();
  }

  // Mengambil data JSON 
  Future<void> _loadAllJsonData() async {
    try {
      final String keseharianResponse = await DefaultAssetBundle.of(context).loadString('assets/doa_keseharian.json');
      final String sholatResponse = await DefaultAssetBundle.of(context).loadString('assets/doa_sholat.json');
      final String tahlilResponse = await DefaultAssetBundle.of(context).loadString('assets/tahlil.json');
      
      setState(() {
        _listKeseharian = json.decode(keseharianResponse);
        _listSholat = json.decode(sholatResponse);
        _listTahlil = json.decode(tahlilResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      debugPrint("Error loading JSON files: $e");
    }
  }

  // 2. LISTEN PERUBAHAN DATABASE UNTUK WARNA ICON DI HALAMAN UTAMA
  void _listenToBookmarksRealtime() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('bookmarks')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _savedDoasLocal = snapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    });
  }

  //FUNGSI TAMBAH HAPUS FIREBASE FIRESTORE
  Future<void> _toggleBookmarkFirebase(dynamic doa) async {
    // Kita gunakan 'title' doa sebagai ID Dokumen agar tidak ada duplikasi doa yang sama
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('bookmarks')
        .doc(doa['title']);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Jika doa sudah ada di Firebase, maka kita HAPUS (Un-bookmark)
      await docRef.delete();
    } else {
      // Jika belum ada, kita SIMPAN ke Firebase
      await docRef.set({
        'title': doa['title'],
        'arabic': doa['arabic'],
        'latin': doa['latin'],
        'translation': doa['translation'],
        'savedAt': FieldValue.serverTimestamp(), // Menyimpan waktu kapan disimpan
      });
    }
  }

  // 4. POP-UP  STREAMBUILDER FIREBASE
  void _showSavedDoaBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Doa Tersimpan (Cloud)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // KITA GUNAKAN STREAMBUILDER DI SINI
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(_userId)
                      .collection('bookmarks')
                      .orderBy('savedAt', descending: true) // Doa terbaru di atas
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF006D44)));
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Belum ada doa yang disimpan di Cloud.', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final doa = docs[index].data() as Map<String, dynamic>;
                        return _buildDoaCard(
                          doa['title']!,
                          doa['arabic']!,
                          doa['latin']!,
                          doa['translation']!,
                          true, // Di dalam sheet ini posisinya pasti true (ter-bookmark)
                          () => _toggleBookmarkFirebase(doa),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> activeList = [];
    if (_selectedCategory == 'Doa Keseharian') {
      activeList = _listKeseharian;
    } else if (_selectedCategory == 'Doa Sholat') {
      activeList = _listSholat;
    } else if (_selectedCategory == 'Tahlil') {
      activeList = _listTahlil;
    }

    final displayList = activeList.where((doa) {
      final matchesSearch = doa['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            doa['translation']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF006D44)))
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Doa Harian', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.bookmark_outline, size: 28, color: Color(0xFF006D44)),
                          onPressed: _showSavedDoaBottomSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      onChanged: (value) {
                        setState(() { _searchQuery = value; });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari di $_selectedCategory...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildTab(Icons.wb_sunny_outlined, 'Doa Keseharian')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTab(Icons.mosque_outlined, 'Doa Sholat')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTab(Icons.menu_book_outlined, 'Tahlil')),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Expanded(
                      child: displayList.isEmpty
                          ? const Center(child: Text('Data tidak ditemukan.', style: TextStyle(color: Colors.grey)))
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: displayList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final doa = displayList[index];
                                
                                // Cek apakah judul doa ini ada di list lokal yang disinkronkan dengan Firebase
                                final isSaved = _savedDoasLocal.any((element) => element['title'] == doa['title']);
                                
                                return _buildDoaCard(
                                  doa['title']!,
                                  doa['arabic']!,
                                  doa['latin']!,
                                  doa['translation']!,
                                  isSaved,
                                  () => _toggleBookmarkFirebase(doa),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    final bool active = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
          _searchQuery = ''; 
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF006D44) : Colors.white, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoaCard(String title, String arabic, String latin, String trans, bool isBookmarked, VoidCallback onBookmarkTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              GestureDetector(
                onTap: onBookmarkTap,
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined, 
                  color: const Color(0xFF006D44),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(arabic, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(latin, style: const TextStyle(color: Color(0xFF006D44), fontSize: 13, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text('"$trans"', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}