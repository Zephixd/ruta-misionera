/// Validadores de formularios y medidor de fortaleza de contraseñas.
/// Diseñado para cumplir con el principio de prevención de errores y feedback visual en tiempo real.
class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Valida si el correo tiene un formato electrónico válido.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresá tu correo electrónico.';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Ingresá un correo electrónico válido (ej. usuario@gmail.com).';
    }
    return null;
  }

  /// Valida campo de nombre obligatorio
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresá tu nombre.';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 letras.';
    }
    return null;
  }

  /// Valida contraseña para login (solo obligatoriedad básica)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresá tu contraseña.';
    }
    return null;
  }

  /// Nivel de fortaleza de contraseña:
  /// Retorna un valor entre 0.0 y 1.0 para la barra de progreso
  static double getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;

    // Criterio 1: Longitud
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;

    // Criterio 2: Contiene números
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;

    // Criterio 3: Contiene mayúsculas o caracteres especiales
    if (RegExp(r'[A-Z]').hasMatch(password) || RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      strength += 0.25;
    }

    return strength;
  }

  /// Texto descriptivo de la fortaleza
  static String getPasswordStrengthLabel(double strength) {
    if (strength <= 0.25) return 'Muy débil';
    if (strength <= 0.5) return 'Débil';
    if (strength <= 0.75) return 'Aceptable';
    return 'Fuerte y segura';
  }

  /// Valida texto de comentario
  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El comentario no puede estar vacío.';
    }
    if (value.trim().length > 300) {
      return 'El comentario no puede superar los 300 caracteres.';
    }
    return null;
  }
}
