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
  String? _selectedKidId;

  @override
  void initState() {
    super.initState();
    _selectedKidId = widget.storage.getActiveKidId();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Cheerful Indonesian family welcome
    Future.delayed(const Duration(milliseconds: 400), () {
      AudioService().speakPraise('Selamat datang di Achmad Family Apps! Pilih namamu dan ayo kita mewarnai!');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectProfileAndStart(String kidId, String kidName) async {
    await widget.storage.setActiveKidId(kidId);
    AudioService().speakPraise('Halo $kidName! Ayo kita mulai mewarnai!');
    widget.onStart();
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Golden Sparkle Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFFE169), Color(0xFFFF923C)]),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF923C).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              '🌟 PERSEMBAHAN SPESIAL KELUARGA 🌟',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.1,
                                color: Color(0xFF432800),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // 2. Animated Headline Achmad Family Apps
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                const Text('🎨', style: TextStyle(fontSize: 44)),
                                const SizedBox(height: 2),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Color(0xFFFF5E7E), Color(0xFFFF923C), Color(0xFF4D96FF)],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'Achmad Family Apps',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Aplikasi Mewarnai Ceria untuk Ketiga Buah Hati Tercinta ✨',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6C757D),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // 3. Instruction Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFCCD7)),
                            ),
                            child: const Text(
                              '👇 Ketuk nama anak untuk langsung mulai: 👇',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE64A19),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // 4. Interactive Tappable Profile Cards
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: profiles.map((p) {
                              final isSelected = p.id == _selectedKidId;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _selectProfileAndStart(p.id, p.name),
                                    borderRadius: BorderRadius.circular(20),
                                    splashColor: const Color(0xFFFF5E7E).withValues(alpha: 0.2),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 124,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFFFF0F3) : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFFF5E7E) : const Color(0xFFFFCCD7),
                                          width: isSelected ? 2.5 : 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSelected
                                                ? const Color(0xFFFF5E7E).withValues(alpha: 0.25)
                                                : Colors.black.withValues(alpha: 0.06),
                                            blurRadius: isSelected ? 12 : 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(p.avatar, style: const TextStyle(fontSize: 34)),
                                          const SizedBox(height: 2),
                                          Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: Color(0xFF2B2D42),
                                            ),
                                          ),
                                          Text(
                                            '${p.age} Thn',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? const Color(0xFFFF5E7E)
                                                  : const Color(0xFF4D96FF),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text('Mulai', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                SizedBox(width: 2),
                                                Icon(Icons.arrow_forward, size: 10, color: Colors.white),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 8),

                          // 5. Always-Visible Primary Start Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5E7E),
                              foregroundColor: Colors.white,
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              final active = widget.storage.getActiveProfile();
                              _selectProfileAndStart(active.id, active.name);
                            },
                            icon: const Text('🚀', style: TextStyle(fontSize: 20)),
                            label: const Text(
                              'Mulai Mewarnai Sekarang!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
