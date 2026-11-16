import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Configuración de Temas Material 3 para "Ruta Misionera"
/// Diseñado para cumplir pautas de usabilidad y accesibilidad (WCAG AA)
class AppTheme {
  // Constantes de diseño según DESIGN.md
  static const double cardRadius = 20.0;
  static const double buttonRadius = 9999.0; // Pill-shaped buttons
  static const double minTouchTarget = 48.0;

  // --- TEMA CLARO ---
  static ThemeData get lightTheme {
    final textTheme = AppTypography.textTheme(false);

    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.surfaceContainerLowLight,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: textTheme,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),

      // Tarjetas con esquinas redondeadas de 20dp
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 1,
        shadowColor: const Color(0x142A2623),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // Botones Primarios estilo Pill
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      // Botones Outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      // Campos de Entrada de Texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariantLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.outlineVariantLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMutedLight),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
      ),

      // Barra de Navegación Inferior (Material 3 NavigationBar)
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: AppColors.textMutedLight,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 26);
          }
          return const IconThemeData(color: AppColors.textMutedLight, size: 24);
        }),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLowLight,
        selectedColor: AppColors.secondary,
        labelStyle: textTheme.labelMedium,
        shape: const StadiumBorder(),
        side: BorderSide(color: AppColors.outlineVariantLight, width: 1),
      ),
    );
  }

  // --- TEMA OSCURO ---
  static ThemeData get darkTheme {
    final textTheme = AppTypography.textTheme(true);

    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD35C43), // Terracota ligeramente más luminoso para contraste nocturno
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF5F1D0E),
      onPrimaryContainer: Color(0xFFFFDAD2),
      secondary: Color(0xFF4FA077),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF14472F),
      onSecondaryContainer: Color(0xFFAEEDCA),
      tertiary: Color(0xFFF0BA4E),
      onTertiary: Color(0xFF271900),
      tertiaryContainer: Color(0xFF6E4C00),
      onTertiaryContainer: Color(0xFFFFDEAA),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerLowest: Color(0xFF161210),
      surfaceContainerLow: AppColors.surfaceContainerLowDark,
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
      outline: AppColors.outlineDark,
      outlineVariant: Color(0xFF4A3F3B),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),

      // Tarjetas en Modo Oscuro
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: Color(0xFF352F2A), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD35C43),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4FA077),
          side: const BorderSide(color: Color(0xFF4FA077), width: 1.5),
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      // Campos de Entrada de Texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4A3F3B), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF4A3F3B), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD35C43), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryDark),
      ),

      // Barra de Navegación Inferior
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.surfaceDark,
        elevation: 3,
        indicatorColor: const Color(0xFF5F1D0E),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: const Color(0xFFFFDAD2),
              fontWeight: FontWeight.w800,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondaryDark,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFFFDAD2), size: 26);
          }
          return const IconThemeData(color: AppColors.textSecondaryDark, size: 24);
        }),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerDark,
        selectedColor: const Color(0xFF14472F),
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.textPrimaryDark),
        shape: const StadiumBorder(),
        side: const BorderSide(color: Color(0xFF4A3F3B), width: 1),
      ),
    );
  }
}
