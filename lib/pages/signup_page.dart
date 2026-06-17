import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Tambahkan import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 TAMBAHAN 1: Import Cloud Firestore
import '../../core/constants/warna.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // 2. Tambahkan variabel loading

  // 3. Ubah fungsi menjadi async
  void _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom formulir!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true); // Nyalakan loading

    try {
      // 4. Proses daftarkan email & password ke Firebase Server
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // (Opsional) Simpan Nama Lengkap pengguna ke dalam profil Firebase mereka
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      // 👈 TAMBAHAN 2: Daftarkan data user baru ke Firestore database agar teks tidak miring lagi
      User? user = userCredential.user;
      if (user != null) {
        await saveUserData(
          user.uid,
          _nameController.text.trim(),
          _emailController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Akun Berhasil! Silakan Sign In.'), backgroundColor: WarnaAplikasi.hijauSage),
        );
        Navigator.pop(context); // Otomatis kembali ke Welcome Page untuk Sign In
      }
    } on FirebaseAuthException catch (e) {
      // 5. Tangani error spesifik saat mendaftar
      String pesanError = 'Terjadi kesalahan, silakan coba lagi.';
      if (e.code == 'weak-password') {
        pesanError = 'Kata sandi terlalu lemah (minimal 6 karakter).';
      } else if (e.code == 'email-already-in-use') {
        pesanError = 'Email ini sudah terdaftar dengan akun lain.';
      } else if (e.code == 'invalid-email') {
        pesanError = 'Format penulisan email salah.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(pesanError), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Matikan loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WarnaAplikasi.hitamArang),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Daftar Akun Baru", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: WarnaAplikasi.hitamArang)),
              const SizedBox(height: 8),
              const Text("Mulai perjalanan ibadah digital teratur Anda bersama kami", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 40),
              
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 40),
              
              //  animasi loading 
              _isLoading
                ? const Center(child: CircularProgressIndicator(color: WarnaAplikasi.biruMuted))
                : ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.biruMuted,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text("Daftar Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  //  Fungsi save user
  Future<void> saveUserData(String userId, String userName, String userEmail) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': userName,
      'email': userEmail,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}