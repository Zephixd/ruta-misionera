import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/services/referidos_service.dart';
import '../ajustes/settings_provider.dart';
import '../auth/auth_provider.dart';
import '../auth/bienvenida_screen.dart';
import '../inicio/sitios_provider.dart';
import 'album_sellos_screen.dart';

/// Pantalla 11 y 12: Perfil de Usuario, Estadísticas, Accesibilidad y Ajustes
///
/// **Justificación para defensa oral de tesis/proyecto:**
/// - Centraliza las opciones de Accesibilidad (WCAG AA: Modo Oscuro y Escala de Texto 1.25x).
/// - Integra la estrategia de crecimiento y retención orgánica mediante Código de Referidos.
/// - Conexión fluida con los servicios de autenticación y estado reactivo.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  void _mostrarDialogCanjearCodigo(BuildContext context, String uid) {
    final controller = TextEditingController();
    final referidosService = ReferidosService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.redeem, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Canjear Código'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el código de invitación de un amigo (o el código promocional MISIONES) para ganar +25 puntos de bonificación:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Ej. RM-9B3E o MISIONES',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final codigo = controller.text.trim();
              if (codigo.isEmpty) return;
              Navigator.pop(ctx);

              final res = await referidosService.canjearCodigo(
                usuarioUid: uid,
                codigo: codigo,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.mensaje),
                    backgroundColor: res.success ? AppColors.secondary : Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Canjear (+25 pts)'),
          ),
        ],
      ),
    );
  }

  void _compartirCodigoReferido(String codigo) {
    Share.share(
      '🌟 ¡Únete a la Ruta Misionera Paraguay! Usa mi código de explorador "$codigo" al registrarte y ambos ganaremos +25 puntos para el ranking patrimonial 🇵🇾✨\n\n'
      'Descubre las misiones jesuíticas y colecciona sellos en tu pasaporte digital.',
      subject: 'Únete a Ruta Misionera con mi código $codigo',
    );
  }

  void _mostrarInfoAcademica(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.school, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Acerca del Proyecto'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ruta Misionera - Versión 1.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Aplicación móvil turística gamificada desarrollada para la valorización del patrimonio jesuítico-guaraní en el departamento de Misiones e Itapúa, Paraguay.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Proyecto Académico Universitario\nUniversidad Católica "Nuestra Señora de la Asunción"\nCampus Itapúa / Misiones.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogEditarNombre(BuildContext context, AuthProvider authProvider) {
    final controller = TextEditingController(text: authProvider.usuarioApp?.nombre ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.badge_outlined, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Editar Nombre'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este nombre aparecerá en tu pasaporte, tus reseñas comunitarias y en el ranking de exploradores:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  enabled: !isSaving,
                  decoration: InputDecoration(
                    labelText: 'Nombre de Explorador',
                    hintText: 'Ej. Juan Pérez',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        final nuevoNombre = controller.text.trim();
                        if (nuevoNombre.isEmpty) return;

                        setDialogState(() => isSaving = true);
                        final ok = await authProvider.updateDisplayName(nuevoNombre);

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? '¡Nombre de usuario actualizado con éxito!'
                                    : (authProvider.errorMessage ?? 'No se pudo actualizar el nombre.'),
                              ),
                              backgroundColor: ok ? AppColors.secondary : AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogCambiarPassword(BuildContext context, AuthProvider authProvider) {
    final actualController = TextEditingController();
    final nuevaController = TextEditingController();
    final confirmarController = TextEditingController();
    bool isSaving = false;
    bool obscureActual = true;
    bool obscureNueva = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.lock_reset, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Cambiar Contraseña'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingresá tu clave actual y escribí la nueva contraseña (mínimo 6 caracteres):',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: actualController,
                    obscureText: obscureActual,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureActual ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureActual = !obscureActual),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nuevaController,
                    obscureText: obscureNueva,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNueva ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscureNueva = !obscureNueva),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmarController,
                    obscureText: obscureNueva,
                    enabled: !isSaving,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      prefixIcon: const Icon(Icons.check_circle_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        final actual = actualController.text;
                        final nueva = nuevaController.text;
                        final confirmar = confirmarController.text;

                        if (actual.isEmpty || nueva.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor completa todos los campos.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (nueva.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('La nueva contraseña debe tener al menos 6 caracteres.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        if (nueva != confirmar) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Las nuevas contraseñas no coinciden.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);
                        final ok = await authProvider.changePassword(
                          passwordActual: actual,
                          nuevaPassword: nueva,
                        );

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? '¡Contraseña actualizada con éxito!'
                                    : (authProvider.errorMessage ?? 'Error al cambiar la contraseña.'),
                              ),
                              backgroundColor: ok ? AppColors.secondary : AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Actualizar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmarCerrarSesion(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Se guardará todo tu progreso en tu cuenta de Firebase.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final sitiosProvider = context.watch<SitiosProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final usuario = authProvider.usuarioApp;
    final isAuth = authProvider.isAuthenticated;

    final sellosCount = sitiosProvider.sellosCount;
    final totalSitios = sitiosProvider.totalSitiosCount;
    final pendientes = (totalSitios - sellosCount).clamp(0, totalSitios);
    final puntos = usuario?.puntosTotal ?? (sellosCount * 50);
    final nivel = usuario?.nivelExplorador ?? (sellosCount >= 3 ? 'Aventurero' : 'Explorador Novato');
    final codigoReferido = usuario?.codigoReferido ?? 'MISIONES';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Información del proyecto',
            onPressed: () => _mostrarInfoAcademica(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tarjeta de Usuario Principal
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainerDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.outlineDark.withValues(alpha: 0.2) : AppColors.outlineLight.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          isAuth && usuario != null && usuario.nombre.isNotEmpty
                              ? usuario.nombre[0].toUpperCase()
                              : 'E',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Datos de Nombre y Correo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isAuth && usuario != null ? usuario.nombre : 'Explorador Invitado',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAuth)
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                    tooltip: 'Editar nombre',
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _mostrarDialogEditarNombre(context, authProvider),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isAuth && usuario != null ? usuario.email : 'Inicia sesión para sincronizar',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Badge de Nivel
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.6)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.military_tech, size: 14, color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    nivel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: AppColors.tertiary,
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

                  // Si no está autenticado, botón para iniciar sesión
                  if (!isAuth) ...[
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Iniciar Sesión / Registrarse',
                      icon: Icons.login,
                      variant: ButtonVariant.primary,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BienvenidaScreen()),
                        );
                      },
                      height: 44,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Tarjeta del Código de Referidos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2E241E), AppColors.surfaceContainerDark]
                      : [AppColors.backgroundLight, AppColors.surfaceContainerLowLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_giftcard, color: AppColors.tertiary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CÓDIGO DE INVITACIÓN',
                          style: AppTypography.stampLabel(color: AppColors.tertiary, fontSize: 10),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              codigoReferido,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: codigoReferido));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('¡Código copiado al portapapeles!')),
                                );
                              },
                            ),
                          ],
                        ),
                        const Text(
                          '+25 pts al invitar a otro explorador',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: AppColors.primary),
                    onPressed: () => _compartirCodigoReferido(codigoReferido),
                  ),
                ],
              ),
            ),

            if (isAuth)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.redeem, size: 16, color: AppColors.primary),
                    label: const Text(
                      '¿Tienes el código de un amigo? Canjéalo aquí (+25 pts)',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: () => _mostrarDialogCanjearCodigo(context, authProvider.firebaseUser!.uid),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 3. Cuadrícula de Métricas y Estadísticas (2x2)
            Row(
              children: [
                Expanded(
                  child: _buildMetricaCard(
                    context: context,
                    icon: Icons.workspace_premium,
                    color: AppColors.secondary,
                    titulo: 'Sellos Obtenidos',
                    valor: '$sellosCount de $totalSitios',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricaCard(
                    context: context,
                    icon: Icons.star,
                    color: AppColors.tertiary,
                    titulo: 'Puntos Totales',
                    valor: '$puntos pts',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricaCard(
                    context: context,
                    icon: Icons.explore,
                    color: AppColors.primary,
                    titulo: 'Por Descubrir',
                    valor: '$pendientes sitios',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricaCard(
                    context: context,
                    icon: Icons.verified_user_outlined,
                    color: Colors.blueAccent,
                    titulo: 'Rango Misionero',
                    valor: nivel,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. Secciones de Accesibilidad y Ajustes
            Text(
              'Accesibilidad y Configuración',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Material(
              color: isDark ? AppColors.surfaceContainerDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.outlineDark.withValues(alpha: 0.15) : AppColors.outlineLight.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    // Modo Oscuro
                    SwitchListTile(
                      secondary: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.primary,
                      ),
                      title: const Text('Modo Oscuro', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settingsProvider.isFollowingSystem
                                ? 'Automático según el dispositivo (${isDark ? "Oscuro" : "Claro"})'
                                : isDark
                                    ? 'Modo oscuro fijado manualmente'
                                    : 'Modo claro fijado manualmente',
                            style: const TextStyle(fontSize: 11),
                          ),
                          if (!settingsProvider.isFollowingSystem)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: InkWell(
                                onTap: () => settingsProvider.useSystemTheme(),
                                child: const Text(
                                  'Restablecer a tema del dispositivo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      value: isDark,
                      onChanged: (val) => settingsProvider.toggleThemeMode(val),
                    ),
                    const Divider(height: 1),

                    // Texto Grande Accesible (WCAG AA)
                    SwitchListTile(
                      secondary: const Icon(Icons.format_size, color: AppColors.secondary),
                      title: const Text('Texto Grande Accesible (1.25x)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        settingsProvider.isLargeText ? 'Texto ampliado activo (1.25x)' : 'Facilita la lectura para personas mayores (WCAG AA)',
                        style: const TextStyle(fontSize: 11),
                      ),
                      value: settingsProvider.isLargeText,
                      onChanged: (val) => settingsProvider.toggleLargeText(val),
                    ),
                    const Divider(height: 1),

                    // Modo Demostración Académica
                    SwitchListTile(
                      secondary: const Icon(Icons.bug_report_outlined, color: Colors.orange),
                      title: const Text('Modo Demostración (Defensa Oral)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        settingsProvider.isDemoMode
                            ? 'Simulación GPS activa para defensa en aula'
                            : 'Permite simular check-in en el aula sin viajar físicamente',
                        style: const TextStyle(fontSize: 11),
                      ),
                      value: settingsProvider.isDemoMode,
                      onChanged: (val) => settingsProvider.toggleDemoMode(val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5. Accesos Rápidos
            Material(
              color: isDark ? AppColors.surfaceContainerDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppColors.outlineDark.withValues(alpha: 0.15) : AppColors.outlineLight.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.book_outlined, color: AppColors.primary),
                      title: const Text('Mi Pasaporte Digital', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Ver mi colección de sellos estampados', style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AlbumSellosScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.share_outlined, color: AppColors.secondary),
                      title: const Text('Compartir la Aplicación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Invita a turistas y amigos a recorrer las misiones', style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => _compartirCodigoReferido(codigoReferido),
                    ),
                  ],
                ),
              ),
            ),
            // 6. Gestión de Cuenta (Editar nombre, Cambiar contraseña)
            if (isAuth) ...[
              const SizedBox(height: 20),
              Material(
                color: isDark ? AppColors.surfaceContainerDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.outlineDark.withValues(alpha: 0.15) : AppColors.outlineLight.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                        title: const Text('Editar Nombre de Usuario', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          authProvider.isGoogleUser ? 'Modificar nombre visible (Cuenta Google)' : 'Modificar tu nombre en el ranking',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _mostrarDialogEditarNombre(context, authProvider),
                      ),
                      if (authProvider.canChangePassword) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock_reset, color: AppColors.tertiary),
                          title: const Text('Cambiar Contraseña', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: const Text('Actualizar tu clave de acceso', style: TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.chevron_right, size: 20),
                          onTap: () => _mostrarDialogCambiarPassword(context, authProvider),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Botón Cerrar Sesión
            if (isAuth)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _confirmarCerrarSesion(context, authProvider),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricaCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String titulo,
    required String valor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.outlineDark.withValues(alpha: 0.15) : AppColors.outlineLight.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}
