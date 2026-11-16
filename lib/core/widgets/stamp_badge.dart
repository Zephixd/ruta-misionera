import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Componente visual del "Sello Gamificado de Pasaporte"
/// Representa el sello de tinta con doble aro concéntrico y rotación natural.
class StampBadge extends StatelessWidget {
  final String title;
  final String? date;
  final bool isUnlocked;
  final double size;
  final double rotationDegrees;
  final Color? customColor;
  final VoidCallback? onTap;

  const StampBadge({
    super.key,
    required this.title,
    this.date,
    this.isUnlocked = false,
    this.size = 80,
    this.rotationDegrees = -2.5,
    this.customColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color stampColor = isUnlocked
        ? (customColor ?? AppColors.primary)
        : const Color(0xFFA3988E);

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: isUnlocked ? (rotationDegrees * 3.14159 / 180.0) : 0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked ? stampColor.withValues(alpha: 0.08) : Colors.transparent,
            border: Border.all(
              color: stampColor,
              width: isUnlocked ? 2.5 : 1.5,
              style: isUnlocked ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: stampColor.withValues(alpha: isUnlocked ? 0.8 : 0.4),
                width: 1.0,
              ),
            ),
            child: Center(
              child: isUnlocked
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          color: stampColor,
                          size: size * 0.28,
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            title.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.stampLabel(
                              color: stampColor,
                              fontSize: (size * 0.1).clamp(9.0, 12.0),
                            ),
                          ),
                        ),
                        if (date != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            date!,
                            style: TextStyle(
                              fontSize: (size * 0.09).clamp(8.0, 10.0),
                              fontWeight: FontWeight.bold,
                              color: stampColor.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: stampColor,
                          size: size * 0.32,
                        ),
                        const SizedBox(height: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: (size * 0.1).clamp(8.0, 11.0),
                              color: stampColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
