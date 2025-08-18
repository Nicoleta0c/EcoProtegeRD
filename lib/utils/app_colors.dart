import 'package:flutter/material.dart';

class AppColors {
  //Verde Medio Ambiente
  static const Color primaryGreen = Color(0xFF2E7D32); 
  static const Color lightGreen = Color(0xFF4CAF50); 
  static const Color darkGreen = Color(0xFF1B5E20); 
  static const Color accentGreen = Color(0xFF66BB6A); 
  
  //secundarios
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, lightGreen],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF1F8E9), white],
  );
}
