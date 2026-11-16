import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import 'auth_provider.dart';
import 'login_screen.dart';

/// Pantalla 2: Registro Mejorado (Fiel al UI Kit de Stitch)
/// Cumple principios de usabilidad:
/// - Prevención de errores con validación reactiva en tiempo real.
/// - Visibilidad del estado con medidor visual de fortaleza de contraseña.
/// - Botón deshabilitado hasta que todos los campos sean válidos.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _termsAccepted = true;

  // Estados de validación en tiempo real
  bool _isNameValid = false;
  bool _isEmailValid = false;
  double _passwordStrength = 0.0;
  String? _emailErrorMessage;

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(_validateNameLive);
    _emailController.addListener(_validateEmailLive);
    _passwordController.addListener(_validatePasswordLive);
  }

  void _validateNameLive() {
    final text = _nombreController.text.trim();
    setState(() {
      _isNameValid = text.length >= 2;
    });
  }

  void _validateEmailLive() {
    final text = _emailController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isEmailValid = false;
        _emailErrorMessage = null;
      });
      return;
    }
    final error = Validators.validateEmail(text);
    setState(() {
      _isEmailValid = error == null;
      _emailErrorMessage = error;
    });
  }

  void _validatePasswordLive() {
    final text = _passwordController.text;
    setState(() {
      _passwordStrength = Validators.getPasswordStrength(text);
    });
  }

  bool get _isFormValid =>
      _isNameValid &&
      _isEmailValid &&
      _passwordStrength >= 0.5 &&
      _termsAccepted;

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return AppColors.error;
    if (strength <= 0.5) return AppColors.tertiary;
    return AppColors.secondary;
  }

  Future<void> _mostrarExitoRegistro(String nombre) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(
                Icons.celebration,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '¡Bienvenido, $nombre!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Tu cuenta y tu Pasaporte Digital han sido creados con éxito.\nYa puedes recorrer las 7 reducciones jesuíticas, timbrar tus sellos y sumar puntos en el ranking patrimonial.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Comenzar Exploración',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_isFormValid) return;

    final nombre = _nombreController.text.trim();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nombre: nombre,
    );

    if (!mounted) return;

    if (success) {
      await _mostrarExitoRegistro(nombre);
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithGoogle();
    if (!mounted) return;
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver atrás',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ruta Misionera',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF2E2823) : AppColors.surfaceContainerHighLight,
                ),
                child: Center(
                  child: Text(
                    'PY',
                    style: AppTypography.stampLabel(color: AppColors.primary, fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge & Título
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'PASAPORTE DIGITAL',
                    style: AppTypography.stampLabel(
                      color: AppColors.onSecondaryContainer,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crear cuenta',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Solo necesitamos lo básico para registrar tus sellos.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Campo 1: Nombre Completo con Validación en Tiempo Real
                Text(
                  'Nombre completo',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Ej. Mateo Caballero',
                    prefixIcon: const Icon(Icons.person_outline),
                    suffixIcon: _isNameValid
                        ? const Icon(Icons.check_circle, color: AppColors.secondary)
                        : null,
                  ),
                ),
                if (_isNameValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      'Nombre válido para tu pasaporte oficial',
                      style: AppTypography.stampLabel(color: AppColors.secondary, fontSize: 10),
                    ),
                  ),
                const SizedBox(height: 18),

                // Campo 2: Correo Electrónico
                Text(
                  'Correo electrónico',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _emailErrorMessage != null ? AppColors.error : null,
                      ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: const Icon(Icons.mail_outline),
                    suffixIcon: _isEmailValid
                        ? const Icon(Icons.check_circle, color: AppColors.secondary)
                        : (_emailErrorMessage != null
                            ? const Icon(Icons.error_outline, color: AppColors.error)
                            : null),
                    errorText: _emailErrorMessage,
                  ),
                ),
                const SizedBox(height: 18),

                // Campo 3: Contraseña con Ocultar/Mostrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contraseña',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'MÍNIMO 6 CARACTERES',
                      style: AppTypography.stampLabel(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Ingresá una clave segura',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                // Medidor Visual de Fortaleza de Contraseña
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStrengthColor(_passwordStrength),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Validators.getPasswordStrengthLabel(_passwordStrength),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStrengthColor(_passwordStrength),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(_passwordStrength * 100).round()}%',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: isDark ? Colors.white12 : Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStrengthColor(_passwordStrength),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _buildRequirementChip(
                        '6+ caracteres',
                        _passwordController.text.length >= 6,
                      ),
                      _buildRequirementChip(
                        'un número',
                        RegExp(r'[0-9]').hasMatch(_passwordController.text),
                      ),
                      _buildRequirementChip(
                        'mayúscula o símbolo',
                        RegExp(r'[A-Z!@#\$&*~]').hasMatch(_passwordController.text),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Términos y Condiciones
                CheckboxListTile(
                  value: _termsAccepted,
                  onChanged: (val) {
                    setState(() {
                      _termsAccepted = val ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'Acepto los términos de servicio y la política de privacidad de Ruta Misionera.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),

                const SizedBox(height: 20),

                // Botón Primario Reactivo (Deshabilitado si formulario no es válido)
                CustomButton(
                  text: 'Crear cuenta',
                  icon: Icons.arrow_forward,
                  isLoading: authProvider.isLoading,
                  onPressed: _isFormValid ? _handleRegister : null,
                  height: 54,
                ),

                const SizedBox(height: 18),

                // Divisor "o"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'o',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 18),

                // Continuar con Google
                OutlinedButton(
                  onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(
                      color: isDark ? AppColors.outlineDark : AppColors.outlineVariantLight,
                    ),
                    minimumSize: const Size(double.infinity, 52),
                    shape: const StadiumBorder(),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Continuar con Google',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Footer hacia Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tenés cuenta? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementChip(String label, bool satisfied) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          satisfied ? Icons.check_circle : Icons.circle_outlined,
          size: 14,
          color: satisfied ? AppColors.secondary : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: satisfied ? AppColors.secondary : Colors.grey,
            fontWeight: satisfied ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
