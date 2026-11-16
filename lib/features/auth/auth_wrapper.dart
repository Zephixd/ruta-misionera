import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/main_nav_screen.dart';
import 'auth_provider.dart';
import 'bienvenida_screen.dart';

/// Envoltorio de Autenticación (AuthWrapper)
///
/// **Justificación para defensa oral:**
/// Implementa la persistencia de sesión transparente. Escucha los cambios del token de
/// sesión de Firebase Auth: si el usuario ya inició sesión previamente en el dispositivo,
/// accede directamente a la experiencia principal sin tener que autenticarse cada vez.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      return const MainNavScreen();
    }

    // Si no está autenticado, mostramos la pantalla de Bienvenida
    return const BienvenidaScreen();
  }
}
