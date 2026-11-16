import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { primary, secondary, tertiary, text }

/// Botón estilizado reutilizable según los lineamientos de DESIGN.md:
/// - Altura táctil mínima de 54-56dp (Cumple WCAG AA de hit target)
/// - Geometría tipo cápsula/pill (StadiumBorder)
/// - Soporte para estado de carga (CircularProgressIndicator)
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == ButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(48, height),
          shape: const StadiumBorder(),
          foregroundColor: AppColors.primary,
        ),
        child: _buildChild(context, AppColors.primary),
      );
    }

    if (variant == ButtonVariant.secondary) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, height),
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          shape: const StadiumBorder(),
          foregroundColor: AppColors.secondary,
        ),
        child: _buildChild(context, AppColors.secondary),
      );
    }

    // Primario o Terciario (Dorado de recompensas)
    final Color bgColor = variant == ButtonVariant.tertiary
        ? AppColors.tertiary
        : AppColors.primary;
    final Color fgColor = variant == ButtonVariant.tertiary
        ? const Color(0xFF2A2623)
        : Colors.white;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
        minimumSize: Size(double.infinity, height),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
      child: _buildChild(context, fgColor),
    );
  }

  Widget _buildChild(BuildContext context, Color fgColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: fgColor,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }
}
