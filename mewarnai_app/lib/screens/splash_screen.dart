import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onStart;

  const SplashScreen({
    super.key,
    required this.storage,
    required this.onStart,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Speak cheerful family welcome
    Future.delayed(const Duration(milliseconds: 600), () {
      AudioService().speakPraise('Selamat datang di Achmad Family Apps! Ayo kita mewarnai bersama!');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.storage.getProfiles();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EE),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFEEDB), Color(0xFFFFF8EE), Color(0xFFE8F4FD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Golden Sparkle Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFE169), Color(0xFFFF923C)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF923C).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  '🌟 PERSEMBAHAN SPESIAL KELUARGA 🌟',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.2,
                    color: Color(0xFF432800),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Big Achmad Family Apps Headline
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 6),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF5E7E), Color(0xFFFF923C), Color(0xFF4D96FF)],
                      ).createShader(bounds),
                      child: const Text(
                        'Achmad Family Apps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Aplikasi Mewarnai Ceria untuk Ketiga Buah Hati Tercinta ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // The 3 Kids Profile Cards Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: profiles.map((p) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFCCD7), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(p.avatar, style: const TextStyle(fontSize: 34)),
                        const SizedBox(height: 4),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2B2D42),
                          ),
                        ),
                        Text(
                          '${p.age} Thn',
                          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Start Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5E7E),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: widget.onStart,
                icon: const Text('🚀', style: TextStyle(fontSize: 22)),
                label: const Text(
                  'Mulai Mewarnai Sekarang!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
