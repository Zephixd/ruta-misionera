import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/map_launcher_utils.dart';
import '../../data/models/sitio.dart';
import '../inicio/sitios_provider.dart';
import '../sitio/detalle_sitio_screen.dart';
import '../../core/widgets/audioguia_player_sheet.dart';

/// Pantalla 5: Mapa Interactivo de la Ruta Misionera (OpenStreetMap + flutter_map)
///
/// **Justificación para defensa oral de tesis/proyecto:**
/// - Cumplimiento del Plan Spark de Firebase al no requerir Google Maps API de pago (evita facturación de tarjeta de crédito).
/// - Uso de tiles abiertos de OpenStreetMap con atribución obligatoria según la licencia Open Data Commons Open Database License (ODbL).
/// - Algoritmo de filtrado reactivo de marcadores y cálculo de distancia en tiempo real con Haversine.
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();

  // Coordenadas centrales del circuito jesuítico en el departamento de Misiones / Itapúa
  static const LatLng _centroCircuito = LatLng(-26.8894, -56.5);
  static const double _zoomInicial = 9.2;

  Sitio? _sitioSeleccionado;

  final List<Map<String, dynamic>> _categoriasFiltro = const [
    {'id': 'todos', 'nombre': 'Todos', 'icon': Icons.map_outlined},
    {'id': 'mision', 'nombre': 'Misiones', 'icon': Icons.account_balance_outlined},
    {'id': 'museo', 'nombre': 'Museos', 'icon': Icons.museum_outlined},
    {'id': 'naturaleza', 'nombre': 'Naturaleza', 'icon': Icons.forest_outlined},
    {'id': 'gastronomia', 'nombre': 'Gastronomía', 'icon': Icons.restaurant_outlined},
  ];

  void _moverMapa(LatLng destino, double zoom) {
    _mapController.move(destino, zoom);
  }

  Future<void> _centrarEnUbicacionUsuario(SitiosProvider sitiosProvider) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        _moverMapa(LatLng(pos.latitude, pos.longitude), 14.5);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requieren permisos de ubicación para centrar el mapa en tu posición.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo obtener la ubicación: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sitiosProvider = context.watch<SitiosProvider>();
    final sitios = sitiosProvider.sitiosFiltrados;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userPos = sitiosProvider.currentPosition;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Capa de Mapa OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centroCircuito,
              initialZoom: _zoomInicial,
              minZoom: 6.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                if (_sitioSeleccionado != null) {
                  setState(() {
                    _sitioSeleccionado = null;
                  });
                }
              },
            ),
            children: [
              // Tiles OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.grimmjow.dev.rutamisionera',
                maxZoom: 19,
              ),

              // Marcador de ubicación actual del usuario (punto azul pulsante)
              if (userPos != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(userPos.latitude, userPos.longitude),
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withValues(alpha: 0.25),
                            ),
                          ),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // Capa de Marcadores de Sitios Turísticos
              MarkerLayer(
                markers: sitios.map((sitio) {
                  final isSellado = sitiosProvider.isSitioSellado(sitio.id);
                  final isSelected = _sitioSeleccionado?.id == sitio.id;

                  return Marker(
                    point: LatLng(sitio.lat, sitio.lng),
                    width: isSelected ? 56 : 46,
                    height: isSelected ? 66 : 54,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _sitioSeleccionado = sitio;
                        });
                        _moverMapa(LatLng(sitio.lat, sitio.lng), 13.0);
                      },
                      child: _buildMarkerWidget(
                        sitio: sitio,
                        isSellado: isSellado,
                        isSelected: isSelected,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. Barra Superior Flotante: Título y Filtros por Categoría
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado translúcido
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.surfaceContainerDark : Colors.white).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.travel_explore, color: AppColors.primary, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Circuito Misionero',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${sitios.length} sitios disponibles en el mapa',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Contador de Sellos
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium, size: 14, color: AppColors.tertiary),
                              const SizedBox(width: 4),
                              Text(
                                '${sitiosProvider.sellosCount}/${sitiosProvider.totalSitiosCount}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Carrusel de Chips de Categorías
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categoriasFiltro.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categoriasFiltro[index];
                      final isSelected = sitiosProvider.categoriaSeleccionada == cat['id'];

                      return GestureDetector(
                        onTap: () => sitiosProvider.setCategoria(cat['id'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.surfaceContainerDark : Colors.white).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 15,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['nombre'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Botones Flotantes de Control de Mapa (Derecha)
          Positioned(
            right: 16,
            bottom: _sitioSeleccionado != null ? 220 : 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón Mi Ubicación
                FloatingActionButton.small(
                  heroTag: 'fab_my_location',
                  onPressed: () => _centrarEnUbicacionUsuario(sitiosProvider),
                  backgroundColor: isDark ? AppColors.surfaceContainerDark : Colors.white,
                  tooltip: 'Mi ubicación GPS',
                  child: const Icon(Icons.my_location, color: Colors.blueAccent),
                ),
                const SizedBox(height: 8),

                // Botón Centrar en Misiones
                FloatingActionButton.small(
                  heroTag: 'fab_recenter_circuit',
                  onPressed: () => _moverMapa(_centroCircuito, _zoomInicial),
                  backgroundColor: isDark ? AppColors.surfaceContainerDark : Colors.white,
                  tooltip: 'Centrar circuito misionero',
                  child: const Icon(Icons.explore, color: AppColors.primary),
                ),
                const SizedBox(height: 8),

                // Zoom In
                FloatingActionButton.small(
                  heroTag: 'fab_zoom_in',
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                  backgroundColor: isDark ? AppColors.surfaceContainerDark : Colors.white,
                  tooltip: 'Acercar',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),

                // Zoom Out
                FloatingActionButton.small(
                  heroTag: 'fab_zoom_out',
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                  backgroundColor: isDark ? AppColors.surfaceContainerDark : Colors.white,
                  tooltip: 'Alejar',
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // 4. Tarjeta Flotante Inferior de Vista Previa del Sitio Seleccionado
          if (_sitioSeleccionado != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: _buildTarjetaPreviaSitio(
                sitio: _sitioSeleccionado!,
                sitiosProvider: sitiosProvider,
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }

  /// Construye el pin/marcador gráfico del mapa
  Widget _buildMarkerWidget({
    required Sitio sitio,
    required bool isSellado,
    required bool isSelected,
  }) {
    final colorFondo = isSellado
        ? AppColors.secondary
        : (isSelected ? AppColors.primaryDark : AppColors.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSelected ? 48 : 38,
          height: isSelected ? 48 : 38,
          decoration: BoxDecoration(
            color: colorFondo,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.tertiary : Colors.white,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.35 : 0.2),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isSellado ? Icons.check_circle : sitio.categoriaIcon,
              size: isSelected ? 24 : 18,
              color: Colors.white,
            ),
          ),
        ),
        // Punta del pin
        CustomPaint(
          size: Size(isSelected ? 12 : 10, isSelected ? 8 : 6),
          painter: _PinTipPainter(color: colorFondo),
        ),
      ],
    );
  }

  /// Tarjeta de previsualización flotante inferior
  Widget _buildTarjetaPreviaSitio({
    required Sitio sitio,
    required SitiosProvider sitiosProvider,
    required bool isDark,
  }) {
    final isSellado = sitiosProvider.isSitioSellado(sitio.id);
    final distancia = sitiosProvider.distanciaFormateadaAlSitio(sitio);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppColors.surfaceContainerDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen miniatura
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    sitio.imagenAsset,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 76,
                      height: 76,
                      color: AppColors.primaryDark,
                      child: const Icon(Icons.temple_buddhist, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Información central
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoría y Estado de Sello
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              sitio.categoriaLabel.toUpperCase(),
                              style: AppTypography.stampLabel(color: AppColors.primary, fontSize: 9),
                            ),
                          ),
                          if (isSellado)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, size: 11, color: AppColors.secondary),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Sellado',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Título
                      Text(
                        sitio.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),

                      if (sitio.nombreGuarani != null)
                        Text(
                          sitio.nombreGuarani!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Distancia GPS
                      if (distancia != null)
                        Row(
                          children: [
                            const Icon(Icons.near_me, size: 12, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              'A $distancia de ti',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Botón Cerrar (X)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _sitioSeleccionado = null;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Botón de Audioguía interactivo
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.headphones_rounded, size: 18),
                label: const Text(
                  'Escuchar Audioguía',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
                onPressed: () {
                  AudioGuiaPlayerSheet.mostrar(context, sitio);
                },
              ),
            ),
            const SizedBox(height: 8),
            // Botones de acción: Google Maps y Ver Detalles
            Row(
              children: [
                // Abrir en Google Maps
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.directions, size: 16, color: Colors.blueAccent),
                      label: const Text(
                        'Ruta Maps',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueAccent),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.blueAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        MapLauncherUtils.abrirGoogleMaps(
                          lat: sitio.lat,
                          lng: sitio.lng,
                          nombreLugar: sitio.nombre,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Ver Detalles
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('Ver Detalles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleSitioScreen(sitio: sitio),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dibuja la punta triangular inferior del pin del mapa
class _PinTipPainter extends CustomPainter {
  final Color color;

  _PinTipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
