import 'package:flutter/material.dart';
import '../../core/constants/warna.dart';
import 'signin_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo Aplikasi
              Image.network(
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? "https://i.postimg.cc/nz0YBQcH/Logo-light.png"
                    : "https://i.postimg.cc/MHH0DKv1/Logo-dark.png",
                height: 146,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.mosque_outlined, size: 100, color: WarnaAplikasi.hijauSage);
                },
              ),
              
              const Spacer(),
              
              // Tombol Sign In menuju halaman sendiri
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: WarnaAplikasi.hijauSage,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 16.0),
              
              // Tombol Sign Up menuju halaman sendiri
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: WarnaAplikasi.biruMuted,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: const StadiumBorder(),
                ),
                child: const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}