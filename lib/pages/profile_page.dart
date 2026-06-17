import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Mengambil data nama & email dari Firestore berdasarkan UID user yang sedang login
  Future<void> _fetchUserData() async {
    final user = _currentUser;
    if (user == null) return; 

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // 
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() { _isLoading = false; });
      }
    } catch (e) {
      debugPrint("Error ambil data user: $e");
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  // Fungsi untuk Logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      //kembali ke login
     if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()), 
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil inisial nama untuk avatar
    String name = _userData?['name'] ?? 'User';
    String email = _userData?['email'] ?? _currentUser?.email ?? '-';
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF006D44),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF006D44)))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar lingkaran dengan inisial nama
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF006D44),
                    child: Text(
                      initial,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Card Info User
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nama Lengkap', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        const Text('Alamat Email', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar Akun (Logout)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        // Tampilkan dialog konfirmasi sebelum logout
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Apakah Abang yakin ingin keluar dari aplikasi?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _logout();
                                },
                                child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}