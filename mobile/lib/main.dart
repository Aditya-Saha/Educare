import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/signup_screen.dart';
import 'src/screens/home_screen.dart';           // student home
import 'src/screens/teacher_home_screen.dart';  // teacher home

void main() {
  runApp(const EducareApp());
}

class EducareApp extends StatelessWidget {
  const EducareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );

    return MaterialApp(
      title: 'Educare',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1724),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start with splash
      initialRoute: '/splash',
      routes: {
        '/splash': (c) => const SplashScreen(),
        '/login': (c) => const LoginScreen(),
        '/signup': (c) => const SignupScreen(),
        '/studentHome': (c) => const HomeScreen(),            // student
        '/teacherHome': (c) => const TeacherHomeScreen(),     // teacher
      },
    );
  }
}
