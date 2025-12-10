import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/farmer_provider.dart';
import 'providers/farmer_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/setup_dairy_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/farmer/farmer_dashboard.dart';
import 'screens/splash_screen.dart';
import 'widgets/watermark_overlay.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => FarmerProvider()),
      ],
      child: MaterialApp(
        title: 'Cloud Dairy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(),
        ),
        home: const SplashScreen(), // Start with Splash
        builder: (context, child) {
          return WatermarkOverlay(child: child!); // Wrap everything with Watermark
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check for auto-login and startup setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAppStartup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (auth.isAuthenticated) {
          if (auth.role == 'admin') {
            return const AdminDashboard();
          } else {
            return const FarmerDashboard();
          }
        }
        if (auth.needsSetup) {
          return const SetupDairyScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

