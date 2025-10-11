import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/signup_screen.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/teacher_home_screen.dart';

void main() {
  runApp(const EducareApp());
}

class EducareApp extends StatefulWidget {
  const EducareApp({super.key});

  @override
  State<EducareApp> createState() => _EducareAppState();
}

class _EducareAppState extends State<EducareApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Light Theme
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.indigo,
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF030303),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        unselectedItemColor: const Color(0xFF606060),
        selectedItemColor: Colors.blue.shade600,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
    );

    // Dark Theme
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.indigo,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        unselectedItemColor: const Color(0xFFB0B0B0),
        selectedItemColor: Colors.blue.shade600,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF313131),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF313131)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF313131)),
        ),
      ),
    );

    return MaterialApp(
      title: 'Educare',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      initialRoute: '/splash',
      routes: {
        '/splash': (c) => const SplashScreen(),
        '/login': (c) => const LoginScreen(),
        '/signup': (c) => const SignupScreen(),
        '/studentHome': (c) => const HomeScreen(),
        '/teacherHome': (c) => TeacherHomeScreen(
          onThemeToggle: _toggleTheme,
        ),
      },
    );
  }
}