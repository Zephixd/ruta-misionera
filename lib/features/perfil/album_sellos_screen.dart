import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/sitio.dart';
import '../../data/services/sellos_service.dart';
import '../ajustes/settings_provider.dart';
import '../auth/auth_provider.dart';
import '../inicio/sitios_provider.dart';
import '../sitio/detalle_sitio_screen.dart';

/// Pantalla 7 y 8: Pasaporte Digital y Álbum de Sellos (Gamificación Patrimonial)
///
/// **Justificación para defensa oral de tesis/proyecto:**
/// - Cumple con el objetivo de fidelización y gamificación turística de la investigación.
/// - Representa el modelo físico de pasaporte turístico mediante un álbum digital coleccionable.
/// - Implementa certificados de visita verificados con geolocalización y compartibles en redes sociales.
class AlbumSellosScreen extends StatefulWidget {
  const AlbumSellosScreen({super.key});

  @override
  State<AlbumSellosScreen> createState() => _AlbumSellosScreenState();
}

class _AlbumSellosScreenState extends State<AlbumSellosScreen> {
  final SellosService _sellosService = SellosService();
  String _filtroSeleccionado = 'todos'; // 'todos', 'obtenidos', 'pendientes'

  void _mostrarCertificadoSello({
    required BuildContext context,
    required Sitio sitio,
    required DateTime? fecha,
    required String nombreExplorador,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fechaStr = fecha != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(fecha)
        : DateFormat('dd/MM/yyyy').format(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabecera del Certificado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondary),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            'VISITA VERIFICADA',
                            style: AppTypography.stampLabel(color: AppColors.secondary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Gran Sello Central
                Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.tertiary, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.temple_buddhist, size: 40, color: AppColors.tertiary),
                        const SizedBox(width: 2),
                        Text(
                          'OFICIAL',
                          style: AppTypography.stampLabel(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Título y Leyenda Oficial
                Text(
                  'CERTIFICADO DE EXPLORADOR',
                  style: AppTypography.stampLabel(
                    color: AppColors.primary,
                    fontSize: 14,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sitio.nombre,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),

                if (sitio.nombreGuarani != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    sitio.nombreGuarani!,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Detalles del Registro
                _buildDetalleFila('Explorador Titular', nombreExplorador, isDark),
                const SizedBox(height: 8),
                _buildDetalleFila('Fecha de Timbrado', fechaStr, isDark),
                const SizedBox(height: 8),
                _buildDetalleFila('Puntos Acreditados', '+50 Pts de Aventura', isDark),
                const SizedBox(height: 8),
                _buildDetalleFila('Categoría', sitio.categoriaLabel, isDark),

                const SizedBox(height: 20),

                // Botón Compartir
                CustomButton(
                  text: 'Compartir este Sello',
                  icon: Icons.share,
                  variant: ButtonVariant.primary,
                  onPressed: () {
                    Share.share(
                      '📜 ¡Certificado Oficial de Visita! He conseguido el sello de ${sitio.nombre} en la app Ruta Misionera Paraguay 🇵🇾✨\n\n'
                      '¡Explora tú también las misiones jesuíticas y colecciona todos los sellos!',
                      subject: 'Mi Sello de ${sitio.nombre} - Ruta Misionera',
                    );
                  },
                  height: 48,
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleSitioScreen(sitio: sitio),
                      ),
                    );
                  },
                  child: const Text('Ver Información del Sitio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleFila(String label, String valor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
          ),
        ),
        Text(
          valor,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sitiosProvider = context.watch<SitiosProvider>();
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final usuario = authProvider.usuarioApp;
    final uid = authProvider.firebaseUser?.uid ?? '';
    final nombreUsuario = usuario?.nombre ?? 'Explorador Misionero';
    final nivelExplorador = usuario?.nivelExplorador ?? 'Novato';
    final puntosTotal = usuario?.puntosTotal ?? (sitiosProvider.sellosCount * 50);

    final sitios = sitiosProvider.sitios;
    final sellosCount = sitiosProvider.sellosCount;
    final totalSitios = sitiosProvider.totalSitiosCount;
    final progreso = sitiosProvider.progresoPorcentaje;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasaporte Digital'),
        elevation: 0,
        actions: [
          // Interruptor rápido de Modo Demo para defensa universitaria
          IconButton(
            tooltip: settingsProvider.isDemoMode
                ? 'Modo Demo Activo (Toca para desactivar)'
                : 'Activar Modo Demo para Defensa',
            icon: Icon(
              settingsProvider.isDemoMode ? Icons.bug_report : Icons.bug_report_outlined,
              color: settingsProvider.isDemoMode ? Colors.orange : null,
            ),
            onPressed: () {
              final nuevoEstado = !settingsProvider.isDemoMode;
              settingsProvider.toggleDemoMode(nuevoEstado);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    nuevoEstado
                        ? 'Modo Demo ACTIVADO: Ahora puedes registrar cualquier sello sin estar físicamente en el lugar.'
                        : 'Modo Demo DESACTIVADO: Se requerirá proximidad GPS real.',
                  ),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<Map<String, DateTime>>(
        stream: _sellosService.getSellosDetalleStream(uid),
        builder: (context, snapshot) {
          final sellosDetalle = snapshot.data ?? {};

          // Filtrar sitios según el estado
          final sitiosFiltrados = sitios.where((s) {
            final obtenido = sitiosProvider.isSitioSellado(s.id);
            if (_filtroSeleccionado == 'obtenidos') return obtenido;
            if (_filtroSeleccionado == 'pendientes') return !obtenido;
            return true;
          }).toList();

          return CustomScrollView(
            slivers: [
              // 1. Tarjeta Pasaporte (Estilo Carnet Oficial de Explorador)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.primaryDark, const Color(0xFF1E1513)]
                            : [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado del Pasaporte
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.menu_book, color: AppColors.tertiary, size: 22),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PASAPORTE MISIONERO',
                                      style: AppTypography.stampLabel(
                                        color: AppColors.tertiary,
                                        fontSize: 11,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const Text(
                                      'República del Paraguay',
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Puntos
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppColors.textPrimaryLight),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$puntosTotal PTS',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Datos del Explorador
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombreUsuario,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.military_tech, color: AppColors.tertiary, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      nivelExplorador,
                                      style: const TextStyle(
                                        color: AppColors.tertiary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Indicador de Sellos
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$sellosCount de $totalSitios',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'sellos estampados',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Barra de Progreso
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progreso,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
                          ),
                        ),

                        // Aviso de Modo Demo si está activado
                        if (settingsProvider.isDemoMode) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: Colors.orangeAccent),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Modo Demo Activo: Validación de geocerca omitida para defensa oral.',
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Filtro Horizontal de Estado (Todos, Obtenidos, Pendientes)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: Row(
                    children: [
                      _buildChipFiltro('todos', 'Todos ($totalSitios)'),
                      const SizedBox(width: 8),
                      _buildChipFiltro('obtenidos', 'Sellados ($sellosCount)'),
                      const SizedBox(width: 8),
                      _buildChipFiltro('pendientes', 'Pendientes (${totalSitios - sellosCount})'),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 3. Cuadrícula de Sellos Coleccionables (2 Columnas)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sitio = sitiosFiltrados[index];
                      final obtenido = sitiosProvider.isSitioSellado(sitio.id);
                      final fechaObtenido = sellosDetalle[sitio.id];
                      final distancia = sitiosProvider.distanciaFormateadaAlSitio(sitio);

                      return _buildSelloCard(
                        context: context,
                        sitio: sitio,
                        obtenido: obtenido,
                        fecha: fechaObtenido,
                        distancia: distancia,
                        isDark: isDark,
                        nombreExplorador: nombreUsuario,
                      );
                    },
                    childCount: sitiosFiltrados.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChipFiltro(String id, String label) {
    final isSelected = _filtroSeleccionado == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSeleccionado = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSelloCard({
    required BuildContext context,
    required Sitio sitio,
    required bool obtenido,
    required DateTime? fecha,
    required String? distancia,
    required bool isDark,
    required String nombreExplorador,
  }) {
    return GestureDetector(
      onTap: () {
        if (obtenido) {
          _mostrarCertificadoSello(
            context: context,
            sitio: sitio,
            fecha: fecha,
            nombreExplorador: nombreExplorador,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleSitioScreen(sitio: sitio),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceContainerDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: obtenido
                ? AppColors.tertiary
                : (isDark ? AppColors.outlineDark.withValues(alpha: 0.3) : AppColors.outlineLight.withValues(alpha: 0.5)),
            width: obtenido ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Estampilla / Sello Gráfico
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: obtenido ? -0.06 : 0.0,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: obtenido
                          ? AppColors.secondary
                          : Colors.grey.withValues(alpha: 0.15),
                      border: Border.all(
                        color: obtenido ? AppColors.tertiary : Colors.grey.shade400,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        obtenido ? Icons.verified : Icons.lock_outline,
                        size: 30,
                        color: obtenido ? AppColors.tertiary : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (obtenido)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'TIMBRADO',
                        style: AppTypography.stampLabel(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Título del Sitio
            Text(
              sitio.nombre,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: obtenido
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            // Estado o Fecha / Distancia
            if (obtenido) ...[
              Text(
                fecha != null
                    ? DateFormat('dd/MM/yyyy').format(fecha)
                    : 'Visitado',
                style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text(
                distancia != null ? 'A $distancia' : 'Pendiente',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
