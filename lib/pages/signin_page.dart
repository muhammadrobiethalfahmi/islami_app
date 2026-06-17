import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../core/constants/warna.dart';
import 'package:islami_app/navigasi_utama.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // 2. Tambahkan variabel loading

  // 3. Ubah fungsi menjadi async
  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi Email dan Password Anda!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true); // Nyalakan loading

    try {
      // 4. Proses autentikasi ke Firebase (Diubah sedikit untuk menangkap data user)
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 👈 TAMBAHAN 2: Mengambil data user yang sukses login & menyimpannya ke Firestore
      User? user = userCredential.user;
      if (user != null) {
        // Kita ambil nama dari email (contoh: budi@gmail.com menjadi budi)
        String namaOtomatis = user.displayName ?? _emailController.text.split('@')[0];
        
        await saveUserData(
          user.uid,
          namaOtomatis,
          user.email ?? _emailController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Berhasil!'), backgroundColor: WarnaAplikasi.hijauSage),
        );
        
        // Berhasil login, bersihkan tumpukan halaman dan masuk ke NavigasiUtama
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const NavigasiUtama()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // 5. Tangani error spesifik dari Firebase
      String pesanError = 'Email atau password salah.';
      if (e.code == 'user-not-found') {
        pesanError = 'Akun tidak ditemukan. Silakan daftar dahulu.';
      } else if (e.code == 'wrong-password') {
        pesanError = 'Password salah. Silakan periksa kembali.';
      } else if (e.code == 'invalid-email') {
        pesanError = 'Format email yang Anda masukkan salah.';
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
              const Text("Selamat Datang", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: WarnaAplikasi.hitamArang)),
              const SizedBox(height: 8),
              const Text("Silakan masuk menggunakan akun Anda yang terdaftar", style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 40),
              
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
              
              // 6. Tampilkan animasi loading jika sedang memproses data
              _isLoading
                ? const Center(child: CircularProgressIndicator(color: WarnaAplikasi.hijauSage))
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WarnaAplikasi.hijauSage,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text("Masuk", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
  //TAMBAHAN 3: Fungsi save user 
  Future<void> saveUserData(String userId, String userName, String userEmail) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': userName,
      'email': userEmail,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}