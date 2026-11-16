import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/celebracion_sello_dialog.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/audioguia_player_sheet.dart';
import '../../core/utils/map_launcher_utils.dart';
import '../../data/models/comentario.dart';
import '../../data/models/sitio.dart';
import '../../data/services/comentarios_service.dart';
import '../../data/services/sellos_service.dart';
import '../ajustes/settings_provider.dart';
import '../auth/auth_provider.dart';
import '../auth/bienvenida_screen.dart';
import '../inicio/sitios_provider.dart';

/// Pantalla 6: Detalle del Sitio y Experiencia Cultural Completa
///
/// **Justificación para defensa oral:**
/// - Integración multimedia con simulación de Audioguía para accesibilidad cognitiva y auditiva.
/// - Funcionalidad social nativa con Compartir (`share_plus`) y sistema colaborativo de reseñas en Firestore.
/// - Preparación de telemetría y geocercas para la validación de Check-in GPS de la Fase 5.
class DetalleSitioScreen extends StatefulWidget {
  final Sitio sitio;

  const DetalleSitioScreen({
    super.key,
    required this.sitio,
  });

  @override
  State<DetalleSitioScreen> createState() => _DetalleSitioScreenState();
}

class _DetalleSitioScreenState extends State<DetalleSitioScreen> {
  final ComentariosService _comentariosService = ComentariosService();
  final SellosService _sellosService = SellosService();
  late Stream<List<Comentario>> _comentariosStream;
  bool _isCheckingIn = false;

  @override
  void initState() {
    super.initState();
    _comentariosStream = _comentariosService.getComentariosStream(widget.sitio.id);
  }

  void _refrescarComentarios() {
    setState(() {
      _comentariosStream = _comentariosService.getComentariosStream(widget.sitio.id);
    });
  }

  void _compartirSitio() {
    final mensaje = '¡Descubre ${widget.sitio.nombre} en la Ruta Misionera!\n\n'
        '${widget.sitio.descripcion}\n\n'
        '📍 Coordenadas: ${widget.sitio.lat}, ${widget.sitio.lng}\n'
        '¡Descarga Ruta Misionera, visita las misiones históricas y colecciona sellos en tu pasaporte digital!';

    Share.share(mensaje, subject: 'Ruta Misionera - ${widget.sitio.nombre}');
  }

  Future<void> _realizarCheckIn() async {
    final authProvider = context.read<AuthProvider>();
    final sitiosProvider = context.read<SitiosProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión con tu cuenta para registrar visitas y sellar tu pasaporte.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isCheckingIn = true;
    });

    try {
      double? lat = sitiosProvider.currentPosition?.latitude;
      double? lng = sitiosProvider.currentPosition?.longitude;

      if (lat == null && !settingsProvider.isDemoMode) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
          lat = pos.latitude;
          lng = pos.longitude;
        } catch (_) {}
      }

      final uid = authProvider.firebaseUser!.uid;
      final resultado = await _sellosService.registrarCheckIn(
        usuarioUid: uid,
        sitio: widget.sitio,
        latActual: lat,
        lngActual: lng,
        isDemoMode: settingsProvider.isDemoMode,
      );

      if (!mounted) return;

      if (resultado.success) {
        CelebracionSelloDialog.show(
          context,
          sitio: widget.sitio,
          puntos: resultado.puntosOtorgados,
          esModoDemo: settingsProvider.isDemoMode,
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.orange),
                SizedBox(width: 8),
                Text('Check-in no disponible'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resultado.mensaje),
                const SizedBox(height: 14),
                const Text(
                  '💡 Consejo para defensa oral: Puedes activar el "Modo Demo" en los Ajustes de la app para simular estar físicamente dentro del radio de esta misión.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              if (!settingsProvider.isDemoMode)
                TextButton(
                  onPressed: () {
                    settingsProvider.toggleDemoMode(true);
                    Navigator.pop(ctx);
                    _realizarCheckIn();
                  },
                  child: const Text('Activar Modo Demo y Sellar'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
      }
    }
  }

  void _mostrarModalAudioguia(BuildContext context) {
    AudioGuiaPlayerSheet.mostrar(context, widget.sitio);
  }

  void _mostrarModalNuevaResena(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Iniciar Sesión'),
            ],
          ),
          content: const Text(
            'Para compartir tu opinión sobre este sitio y sumar +10 puntos a tu ranking de explorador, debes iniciar sesión o registrarte.',
            style: TextStyle(fontSize: 14),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BienvenidaScreen()),
                );
              },
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      );
      return;
    }

    double calificacion = 5.0;
    final textController = TextEditingController();
    bool isPublicando = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dejar tu Reseña',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isPublicando ? null : () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Selector de Estrellas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= calificacion ? Icons.star : Icons.star_border,
                          color: AppColors.tertiary,
                          size: 32,
                        ),
                        onPressed: isPublicando
                            ? null
                            : () {
                                setModalState(() {
                                  calificacion = starValue.toDouble();
                                });
                              },
                      );
                    }),
                  ),
                  Center(
                    child: Text(
                      '$calificacion de 5 estrellas',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: textController,
                    maxLines: 3,
                    enabled: !isPublicando,
                    maxLength: 600,
                    decoration: InputDecoration(
                      hintText: 'Comparte tu experiencia, qué ver y consejos para otros exploradores...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isPublicando
                          ? null
                          : () async {
                              final texto = textController.text.trim();
                              if (texto.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Por favor escribe un comentario antes de publicar.'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              setModalState(() {
                                isPublicando = true;
                              });

                              final usuario = authProvider.usuarioApp;
                              final uid = authProvider.firebaseUser?.uid;
                              if (uid == null) {
                                setModalState(() {
                                  isPublicando = false;
                                });
                                return;
                              }
                              final nombre = (usuario?.nombre.isNotEmpty ?? false)
                                  ? usuario!.nombre
                                  : (authProvider.firebaseUser?.displayName ?? 'Explorador Misionero');

                              try {
                                await _comentariosService.agregarComentario(
                                  sitioId: widget.sitio.id,
                                  usuarioUid: uid,
                                  usuarioNombre: nombre,
                                  texto: texto,
                                  calificacion: calificacion,
                                );

                                _refrescarComentarios();

                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.white),
                                          SizedBox(width: 8),
                                          Expanded(child: Text('¡Reseña publicada! Ganaste +10 puntos de explorador.')),
                                        ],
                                      ),
                                      backgroundColor: AppColors.secondary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  setModalState(() {
                                    isPublicando = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al publicar reseña: $e'),
                                      backgroundColor: AppColors.error,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                      child: isPublicando
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Publicar Reseña (+10 pts)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sitiosProvider = context.watch<SitiosProvider>();
    final isSellado = sitiosProvider.isSitioSellado(widget.sitio.id);
    final distancia = sitiosProvider.distanciaFormateadaAlSitio(widget.sitio);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar con Hero Image y Controles Flotantes
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
                onPressed: _compartirSitio,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'sitio_${widget.sitio.id}',
                    child: Image.asset(
                      widget.sitio.imagenAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.primaryDark,
                        child: const Center(
                          child: Icon(Icons.temple_buddhist, size: 64, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Colors.transparent,
                          Color(0xCC000000),
                        ],
                        stops: [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  // Insignia de UNESCO en la esquina superior derecha
                  if (widget.sitio.esUnesco)
                    Positioned(
                      top: 48,
                      right: 60,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, size: 14, color: AppColors.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              'PATRIMONIO UNESCO',
                              style: AppTypography.stampLabel(color: Colors.white, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Insignia de Sello Obtenido en la esquina inferior izquierda
                  if (isSellado)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'SELLO OBTENIDO EN TU PASAPORTE',
                              style: AppTypography.stampLabel(color: Colors.white, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Contenido Detallado
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y Distancia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(widget.sitio.categoriaIcon, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              widget.sitio.categoriaLabel.toUpperCase(),
                              style: AppTypography.stampLabel(color: AppColors.primary, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      if (distancia != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me, size: 14, color: AppColors.secondary),
                              const SizedBox(width: 4),
                              Text(
                                distancia,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Nombre Principal
                  Text(
                    widget.sitio.nombre,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),

                  if (widget.sitio.nombreGuarani != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Nombre guaraní: ${widget.sitio.nombreGuarani!}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Barra de Accesos Rápidos (Audioguía + Google Maps + Compartir)
                  Row(
                    children: [
                      // Audioguía
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.headphones_outlined, size: 16),
                          label: const Text('Audioguía', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _mostrarModalAudioguia(context),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Google Maps
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Cómo llegar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                          ),
                          onPressed: () => MapLauncherUtils.abrirGoogleMaps(
                            lat: widget.sitio.lat,
                            lng: widget.sitio.lng,
                            nombreLugar: widget.sitio.nombre,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Compartir
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        onPressed: _compartirSitio,
                        child: const Icon(Icons.share_outlined, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Descripción Resumida
                  Text(
                    'Acerca del lugar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.sitio.descripcion,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // Historia y Legado Patrimonial
                  Text(
                    'Historia y Patrimonio Cultural',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.sitio.historia,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),

                  const SizedBox(height: 24),

                  // Cuadrícula de Información Práctica (Horarios, Geocerca, Entrada)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLowLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.outlineDark.withValues(alpha: 0.3) : AppColors.outlineLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoFila(
                          icon: Icons.access_time,
                          titulo: 'Horario sugerido',
                          valor: '08:00 a 17:30 hs (Todos los días)',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildInfoFila(
                          icon: Icons.pin_drop,
                          titulo: 'Radio de Check-in GPS',
                          valor: '${widget.sitio.radioCheckInMetros.toInt()} metros a la redonda',
                          isDark: isDark,
                        ),
                        const Divider(height: 20),
                        _buildInfoFila(
                          icon: Icons.confirmation_number_outlined,
                          titulo: 'Entrada y Acceso',
                          valor: widget.sitio.esUnesco ? 'Ticket circuito unificado Senatur' : 'Acceso libre y gratuito',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón Principal de Check-in GPS
                  CustomButton(
                    text: isSellado
                        ? '¡Sello conseguido en tu Pasaporte!'
                        : (_isCheckingIn ? 'Verificando ubicación GPS...' : 'Registrar visita y obtener sello'),
                    icon: isSellado ? Icons.check_circle : Icons.qr_code_scanner,
                    variant: isSellado ? ButtonVariant.secondary : ButtonVariant.primary,
                    isLoading: _isCheckingIn,
                    onPressed: isSellado || _isCheckingIn ? null : () => _realizarCheckIn(),
                    height: 54,
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Sección Social: Reseñas y Comentarios de la Comunidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reseñas de Exploradores',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Text(
                            'Experiencias y consejos de visitantes',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.rate_review_outlined, size: 16),
                        label: const Text('Opinar', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _mostrarModalNuevaResena(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Stream de comentarios de Firestore
                  StreamBuilder<List<Comentario>>(
                    stream: _comentariosStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        );
                      }

                      final comentarios = snapshot.data ?? [];
                      if (comentarios.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'Sé el primer explorador en dejar una reseña sobre este lugar.',
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      final currentUid = context.read<AuthProvider>().firebaseUser?.uid ?? '';

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comentarios.length,
                        separatorBuilder: (_, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = comentarios[index];
                          final hasLiked = c.likesUids.contains(currentUid);

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLowLight,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? AppColors.outlineDark.withValues(alpha: 0.2) : AppColors.outlineLight.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                          child: Text(
                                            c.usuarioNombre.isNotEmpty ? c.usuarioNombre[0].toUpperCase() : 'E',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          c.usuarioNombre,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    // Estrellas
                                    Row(
                                      children: List.generate(5, (sIndex) {
                                        return Icon(
                                          sIndex < c.calificacion.round() ? Icons.star : Icons.star_border,
                                          size: 14,
                                          color: AppColors.tertiary,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.texto,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${c.fecha.day}/${c.fecha.month}/${c.fecha.year}',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (currentUid.isNotEmpty) {
                                          _comentariosService.toggleLikeComentario(
                                            sitioId: widget.sitio.id,
                                            comentarioId: c.id,
                                            usuarioUid: currentUid,
                                          );
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            hasLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                            size: 14,
                                            color: hasLiked ? AppColors.primary : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${c.likesCount}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: hasLiked ? AppColors.primary : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoFila({
    required IconData icon,
    required String titulo,
    required String valor,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                ),
              ),
              Text(
                valor,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
