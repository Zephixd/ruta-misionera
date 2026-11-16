import 'package:flutter/material.dart';

/// Paleta de colores de "Ruta Misionera"
/// Basada en las especificaciones del UI Kit (DESIGN.md)
/// Inspirada en la tierra colorada, la selva subtropical y el arte barroco jesuítico.
class AppColors {
  // --- Colores Principales (Brand) ---
  /// Rojo Terracota: Tierra colorada, ladrillo misionero y llamadas a la acción principales
  static const Color primary = Color(0xFFB5472E);
  static const Color primaryDark = Color(0xFF943019);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFFDAD2);
  static const Color onPrimaryContainer = Color(0xFF3D0600);

  /// Verde Selva: Vegetación paranaense, naturaleza y estados visitados/éxito
  static const Color secondary = Color(0xFF2D694D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFAEEDCA);
  static const Color onSecondaryContainer = Color(0xFF002113);

  /// Oro Cálido / Dorado: Retablos barrocos jesuíticos, sellos obtenidos y ranking
  static const Color tertiary = Color(0xFFE3A72F);
  static const Color tertiaryDark = Color(0xFF8D6300);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFDEAA);
  static const Color onTertiaryContainer = Color(0xFF271900);

  // --- Modo Claro ---
  /// Crema Cálido: Evoca papel de archivo histórico y reduce el brillo bajo el sol
  static const Color backgroundLight = Color(0xFFFDF9F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF7F3EC);
  static const Color surfaceContainerLight = Color(0xFFF1EDE6);
  static const Color surfaceContainerHighLight = Color(0xFFEBE8E1);
  static const Color surfaceContainerHighestLight = Color(0xFFE6E2DB);

  static const Color textPrimaryLight = Color(0xFF1C1C18);
  static const Color textSecondaryLight = Color(0xFF57423D);
  static const Color textMutedLight = Color(0xFF6B625B);
  static const Color outlineLight = Color(0xFF8B716C);
  static const Color outlineVariantLight = Color(0xFFDEC0B9);

  // --- Modo Oscuro ---
  /// Tierra Umbría y Arenisca ahumada: Suave para la vista nocturna
  static const Color backgroundDark = Color(0xFF1B1714);
  static const Color surfaceDark = Color(0xFF26211D);
  static const Color surfaceContainerLowDark = Color(0xFF221D1A);
  static const Color surfaceContainerDark = Color(0xFF2E2823);
  static const Color surfaceContainerHighDark = Color(0xFF352F2A);
  static const Color surfaceContainerHighestDark = Color(0xFF3E3630);

  static const Color textPrimaryDark = Color(0xFFF3ECE4);
  static const Color textSecondaryDark = Color(0xFFA3988E);
  static const Color outlineDark = Color(0xFF5A4D48);

  // --- Estados / Feedback ---
  static const Color success = Color(0xFF2E7D4F);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
}
