import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/sitio.dart';

/// Tarjeta Gamificada de Progreso del Pasaporte (Fiel a 4._inicio de Stitch)
class PasaporteProgressCard extends StatelessWidget {
  final int sellosCount;
  final int totalSitios;
  final double progreso;
  final List<Sitio> sitios;
  final bool Function(String sitioId) isSellado;
  final VoidCallback? onTap;

  const PasaporteProgressCard({
    super.key,
    required this.sellosCount,
    required this.totalSitios,
    required this.progreso,
    required this.sitios,
    required this.isSellado,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final porcentajeTexto = '${(progreso * 100).round()}%';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB5472E), // Terracota Misionero
              Color(0xFFCD663E),
              Color(0xFFE3A72F), // Oro Cálido
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33B5472E),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Marca de agua de fondo
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.12,
                child: const Icon(Icons.stars, size: 140, color: Colors.white),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de la tarjeta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_stories, size: 12, color: AppColors.tertiaryContainer),
                            const SizedBox(width: 6),
                            Text(
                              'PASAPORTE GUARANÍ',
                              style: AppTypography.stampLabel(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$porcentajeTexto Completado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Título principal
                  Text(
                    'Llevás $sellosCount de $totalSitios sellos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sellosCount >= totalSitios
                        ? '¡Felicitaciones! Has completado todas las misiones jesuíticas.'
                        : 'Coleccioná ${totalSitios - sellosCount} sellos más para obtener la Insignia de Oro Jesuítica.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Barra de Progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 8,
                      backgroundColor: Colors.black.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Carrusel horizontal de mini-sellos circulares
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sitios.length.clamp(0, 8),
                      separatorBuilder: (_, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final sitio = sitios[index];
                        final obtenido = isSellado(sitio.id);
                        final shortName = sitio.nombre.split(' ').take(2).join(' ').replaceAll('Misión ', '');

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: obtenido ? (index % 2 == 0 ? -0.1 : 0.1) : 0,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: obtenido ? AppColors.tertiaryContainer : Colors.black.withValues(alpha: 0.25),
                                  border: Border.all(
                                    color: obtenido ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    obtenido ? Icons.verified : Icons.lock_outline,
                                    size: 20,
                                    color: obtenido ? AppColors.primaryDark : Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              shortName,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: obtenido ? FontWeight.bold : FontWeight.normal,
                                color: Colors.white.withValues(alpha: obtenido ? 1.0 : 0.7),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
