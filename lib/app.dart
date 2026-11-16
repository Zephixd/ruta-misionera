import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/ajustes/settings_provider.dart';
import 'features/auth/auth_wrapper.dart';

/// Aplicación principal de Ruta Misionera
/// Configura temas claro/oscuro, accesibilidad y navegación.
class RutaMisioneraApp extends StatelessWidget {
  const RutaMisioneraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Ruta Misionera',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          builder: (context, child) {
            // Aplicar escala de texto accesible seleccionada por el usuario
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settings.textScaleFactor),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const AuthWrapper(),
        );
      },
    );
  }
}
