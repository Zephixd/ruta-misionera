import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import 'registro_screen.dart';

/// Pantalla 1: Bienvenida (Fiel al UI Kit de Stitch)
/// Hero visual con branding colonial, pasaporte cultural y llamadas a la acción claras.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF1B1714),
      body: Stack(
        children: [
          // 1. Imagen de Fondo Hero con Gradiente Editorial
          Positioned.fill(
            child: Image.asset(
              'assets/images/bienvenida.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF26211D),
                child: const Center(
                  child: Icon(Icons.temple_buddhist, size: 80, color: AppColors.primary),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x991B1714),
                    Colors.transparent,
                    Color(0xCC1B1714),
                    Color(0xFF1B1714),
                  ],
                  stops: [0.0, 0.35, 0.7, 0.95],
                ),
              ),
            ),
          ),

          // 2. Contenido Seguro
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de Marca con Sello
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryDark.withValues(alpha: 0.5),
                                border: Border.all(color: AppColors.tertiary, width: 1.5),
                              ),
                              child: const Icon(Icons.explore, size: 16, color: AppColors.tertiary),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RUTA MISIONERA',
                                  style: AppTypography.stampLabel(
                                    color: AppColors.tertiary,
                                    fontSize: 10,
                                  ),
                                ),
                                const Text(
                                  'PARAGUAY',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.travel_explore, size: 14, color: AppColors.secondary),
                            SizedBox(width: 4),
                            Text(
                              'PY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Marca de Agua Sello UNESCO
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Transform.rotate(
                        angle: 0.1,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.tertiary.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: AppColors.tertiary.withValues(alpha: 0.7),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'PATRIMONIO\nUNESCO',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.stampLabel(
                                    color: AppColors.tertiary.withValues(alpha: 0.8),
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Títulos y Textos de Impacto
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.secondaryContainer.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_edu, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'PASAPORTE CULTURAL',
                          style: AppTypography.stampLabel(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Descubrí las Misiones.\nColeccioná sellos.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recorré sitios históricos, ganá sellos en tu pasaporte digital y competí con otros exploradores.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                        ),
                  ),

                  const SizedBox(height: 28),

                  // Botón 1: Crear Cuenta (Terracota Pill)
                  CustomButton(
                    text: 'Crear cuenta',
                    icon: Icons.person_add,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegistroScreen()),
                      );
                    },
                    height: 52,
                  ),

                  const SizedBox(height: 12),

                  // Botón 2: Ya tengo cuenta (Outlined Pill)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                      minimumSize: const Size(double.infinity, 52),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Ya tengo cuenta',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Botón 3: Continuar con Google
                  Center(
                    child: TextButton.icon(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              final success = await authProvider.loginWithGoogle();
                              if (!success && authProvider.errorMessage != null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authProvider.errorMessage!),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                      icon: authProvider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.g_mobiledata, size: 26, color: Colors.white),
                      label: const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Center(
                    child: Text(
                      'Explorá las misiones jesuíticas reconocidas por la UNESCO en Paraguay.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
