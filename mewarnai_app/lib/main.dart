import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/drawing_item.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'screens/splash_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/studio_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/gallery_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientation to landscape for optimal kids coloring tablet experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final storage = StorageService();
  await storage.init();
  await AudioService().init();

  runApp(MewarnaiApp(storage: storage));
}

class MewarnaiApp extends StatelessWidget {
  final StorageService storage;

  const MewarnaiApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mewarnai Ceria - Achmad Family',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5E7E),
          primary: const Color(0xFFFF5E7E),
        ),
        useMaterial3: true,
      ),
      home: AppRoot(storage: storage),
    );
  }
}

enum AppView { splash, catalog, studio, profile, gallery }

class AppRoot extends StatefulWidget {
  final StorageService storage;

  const AppRoot({super.key, required this.storage});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AppView _currentView = AppView.splash;
  DrawingItem? _selectedDrawing;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentView == AppView.catalog || _currentView == AppView.splash,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentView == AppView.studio ||
            _currentView == AppView.profile ||
            _currentView == AppView.gallery) {
          setState(() => _currentView = AppView.catalog);
        }
      },
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case AppView.splash:
        return SplashScreen(
          storage: widget.storage,
          onStart: () {
            setState(() => _currentView = AppView.catalog);
          },
        );

      case AppView.catalog:
        return CatalogScreen(
          storage: widget.storage,
          onSelectDrawing: (drawing) {
            setState(() {
              _selectedDrawing = drawing;
              _currentView = AppView.studio;
            });
          },
          onOpenProfile: () {
            setState(() => _currentView = AppView.profile);
          },
          onOpenGallery: () {
            setState(() => _currentView = AppView.gallery);
          },
        );

      case AppView.studio:
        if (_selectedDrawing == null) {
          return CatalogScreen(
            storage: widget.storage,
            onSelectDrawing: (drawing) {
              setState(() {
                _selectedDrawing = drawing;
                _currentView = AppView.studio;
              });
            },
            onOpenProfile: () => setState(() => _currentView = AppView.profile),
            onOpenGallery: () => setState(() => _currentView = AppView.gallery),
          );
        }
        return StudioScreen(
          drawing: _selectedDrawing!,
          storage: widget.storage,
          onBackToCatalog: () {
            setState(() => _currentView = AppView.catalog);
          },
          onViewGallery: () {
            setState(() => _currentView = AppView.gallery);
          },
        );

      case AppView.profile:
        return ProfileScreen(
          storage: widget.storage,
          onProfileSelected: () {
            setState(() => _currentView = AppView.catalog);
          },
        );

      case AppView.gallery:
        return GalleryScreen(
          storage: widget.storage,
          onBackToCatalog: () {
            setState(() => _currentView = AppView.catalog);
          },
        );
    }
  }
}
