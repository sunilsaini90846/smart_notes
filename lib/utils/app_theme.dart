import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6B4EFF);
  static const Color secondaryColor = Color(0xFFFF6B9D);
  static const Color backgroundColor = Color(0xFF0F0F1E);
  static const Color surfaceColor = Color(0xFF1A1A2E);
  static const Color accentColor = Color(0xFF00D9FF);
  
  // Gradient colors
  static const List<Color> backgroundGradient = [
    Color(0xFF0F0F1E),
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
  ];
  
  static const List<Color> cardGradient1 = [
    Color(0x40FF6B9D),
    Color(0x206B4EFF),
  ];
  
  static const List<Color> cardGradient2 = [
    Color(0x406B4EFF),
    Color(0x2000D9FF),
  ];
  
  // Note type colors
  static const Map<String, Color> noteTypeColors = {
    'plain': Color(0xFFFFD93D),
    'account': Color(0xFF6BCB77),
    'password': Color(0xFFFF6B9D),
    'bank': Color(0xFF4D96FF),
    'subscription': Color(0xFFBB86FC),
  };
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Colors.white60,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.white54,
  );
  
  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: caption,
      ),
      cardTheme: CardTheme(
        color: surfaceColor.withOpacity(0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
    );
  }
  
  // Get color by note type
  static Color getColorByType(String type) {
    return noteTypeColors[type] ?? noteTypeColors['plain']!;
  }
}

