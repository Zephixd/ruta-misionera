import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/sitio.dart';

/// Tarjeta de Destino Turístico según el UI Kit de Stitch (4._inicio)
class SitioCard extends StatelessWidget {
  final Sitio sitio;
  final bool isSellado;
  final String? distancia;
  final VoidCallback onTap;

  const SitioCard({
    super.key,
    required this.sitio,
    required this.isSellado,
    this.distancia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF352F2A) : const Color(0xFFF0EBE3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x142A2623),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con Fotografía y Overlays
            Stack(
              children: [
                SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.asset(
                    sitio.imagenAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryDark.withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(Icons.temple_buddhist, size: 48, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                // Gradiente para legibilidad
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x33000000),
                          Color(0xCC000000),
                        ],
                        stops: [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Badge Superior Izquierdo: Categoría
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sitio.categoriaIcon, size: 12, color: AppColors.tertiary),
                        const SizedBox(width: 4),
                        Text(
                          sitio.categoriaLabel,
                          style: AppTypography.stampLabel(color: Colors.white, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sello de "VISITADO" si ya tiene el check-in (Oro o Terracota)
                if (isSellado)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.verified, size: 22, color: AppColors.primaryDark),
                      ),
                    ),
                  ),

                // Barra Inferior de la Foto: Distancia y Calificación
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (distancia != null)
                        Row(
                          children: [
                            const Icon(Icons.near_me, size: 14, color: AppColors.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              distancia!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 12, color: AppColors.tertiary),
                            SizedBox(width: 2),
                            Text(
                              '4.9',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Cuerpo de la Tarjeta
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sitio.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (sitio.nombreGuarani != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sitio.nombreGuarani!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Estado: SELLADO vs PENDIENTE
                      Text(
                        isSellado ? 'CONSEGUIDO' : 'PENDIENTE',
                        style: AppTypography.stampLabel(
                          color: isSellado ? AppColors.secondary : AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
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
