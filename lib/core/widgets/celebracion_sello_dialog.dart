import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_button.dart';
import '../../data/models/sitio.dart';

/// Diálogo de Celebración al Desbloquear un Sello del Pasaporte Misionero
///
/// **Justificación para defensa oral:**
/// Implementa principios de gamificación (recompensa inmediata, feedback visual eufórico
/// y fomento de viralidad compartiendo en redes sociales).
class CelebracionSelloDialog extends StatelessWidget {
  final Sitio sitio;
  final int puntos;
  final bool esModoDemo;
  final VoidCallback? onVerPasaporte;

  const CelebracionSelloDialog({
    super.key,
    required this.sitio,
    this.puntos = 50,
    this.esModoDemo = false,
    this.onVerPasaporte,
  });

  static Future<void> show(
    BuildContext context, {
    required Sitio sitio,
    int puntos = 50,
    bool esModoDemo = false,
    VoidCallback? onVerPasaporte,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CelebracionSelloDialog(
        sitio: sitio,
        puntos: puntos,
        esModoDemo: esModoDemo,
        onVerPasaporte: onVerPasaporte,
      ),
    );
  }

  void _compartirLogro() {
    Share.share(
      '🎉 ¡Acabo de visitar ${sitio.nombre} y estampé un nuevo sello oficial en mi Pasaporte Digital de la Ruta Misionera! 🇵🇾✨\n\n'
      '¡Únete a la aventura turística y explora el patrimonio jesuítico de Paraguay!',
      subject: '¡Nuevo Sello en Ruta Misionera!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sello Gráfico Central con Rotación y Relieve
            Stack(
              alignment: Alignment.center,
              children: [
                // Brillo de fondo
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.tertiary.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Estampilla / Sello
                Transform.rotate(
                  angle: -0.08,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.tertiary, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified, size: 38, color: AppColors.tertiary),
                        const SizedBox(height: 2),
                        Text(
                          'SELLADO',
                          style: AppTypography.stampLabel(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Badge de Puntos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tertiary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: AppColors.tertiary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '+$puntos PUNTOS DE EXPLORADOR',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '¡Sello Desbloqueado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              sitio.nombre,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),

            if (esModoDemo) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Modo Demostración Académica Activo',
                  style: TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 12),

            Text(
              'Tu pasaporte digital ha sido timbrado con éxito. Este logro queda registrado en tu perfil y suma puntos para el Ranking de Exploradores.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Botón Compartir Logro
            OutlinedButton.icon(
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Compartir Logro'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _compartirLogro,
            ),

            const SizedBox(height: 10),

            // Botón Ver Pasaporte
            CustomButton(
              text: 'Ver en mi Pasaporte',
              icon: Icons.book_outlined,
              variant: ButtonVariant.primary,
              onPressed: () {
                Navigator.pop(context);
                if (onVerPasaporte != null) {
                  onVerPasaporte!();
                }
              },
              height: 48,
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar Explorando'),
            ),
          ],
        ),
      ),
    );
  }
}
