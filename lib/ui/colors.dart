import 'package:flutter/material.dart';

// ============ DISASTER GLASSMORPHISM THEME ============

// Base Colors - Dark emergency theme
const Color disasterDark = Color(0xFF0D0D0D);
const Color disasterDarker = Color(0xFF080808);
const Color disasterSurface = Color(0xFF141414);

// Glass effect colors
const Color glassWhite = Color(0x0DFFFFFF);  // 5% white
const Color glassBorder = Color(0x1AFFFFFF); // 10% white
const Color glassHighlight = Color(0x33FFFFFF); // 20% white

// Accent Colors - Emergency orange/amber
const Color disasterOrange = Color(0xFFFF6B35);
const Color disasterAmber = Color(0xFFFFAB40);
const Color disasterRed = Color(0xFFFF4444);
const Color disasterGreen = Color(0xFF00C853);

// Legacy aliases
const Color disasterGray = Color(0xFF1E1E1E);

// Text Colors
const Color disasterText = Color(0xFFF5F5F5);
const Color disasterTextMuted = Color(0xFF8A8A8A);
const Color disasterTextDim = Color(0xFF5A5A5A);

// Gradients
const LinearGradient disasterGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
);

const LinearGradient glassGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0x1AFFFFFF), Color(0x05FFFFFF)],
);

const LinearGradient accentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6B35), Color(0xFFFF8F00)],
);

// Glass Card Decoration
BoxDecoration glassCardDecoration({
  double borderRadius = 16,
  Color? borderColor,
  bool hasGlow = false,
}) {
  return BoxDecoration(
    color: const Color(0xFF1A1A1A),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: borderColor ?? glassBorder,
      width: 1,
    ),
    boxShadow: hasGlow
        ? [
            BoxShadow(
              color: disasterOrange.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ]
        : null,
  );
}

// Glass Input Decoration
InputDecoration glassInputDecoration({
  required String hintText,
  IconData? prefixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: disasterTextMuted),
    prefixIcon: prefixIcon != null 
        ? Icon(prefixIcon, color: disasterTextMuted, size: 20)
        : null,
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: glassBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: glassBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: disasterOrange, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
