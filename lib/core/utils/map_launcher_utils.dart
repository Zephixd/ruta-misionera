import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utilidad para abrir aplicaciones de mapas externas (Google Maps, Waze, etc.)
///
/// **Justificación para defensa oral:**
/// Permite delegar la navegación GPS turno a turno (turn-by-turn navigation)
/// a Google Maps nativo en el dispositivo móvil del usuario sin generar costos
/// de API ni requerir tarjetas de crédito en Google Cloud Platform.
class MapLauncherUtils {
  /// Abre Google Maps directamente con la ruta hacia las coordenadas del destino
  static Future<bool> abrirGoogleMaps({
    required double lat,
    required double lng,
    String? nombreLugar,
  }) async {
    // 1. Intent nativo de Google Maps para navegación directa
    final String query = nombreLugar != null ? Uri.encodeComponent(nombreLugar) : '$lat,$lng';
    final Uri googleMapsAppUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final Uri googleMapsGeoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($query)');
    final Uri googleMapsWebUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      // Intentar abrir la app nativa de navegación de Google Maps
      if (await canLaunchUrl(googleMapsAppUri)) {
        return await launchUrl(googleMapsAppUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsGeoUri)) {
        return await launchUrl(googleMapsGeoUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback al navegador web universal
        return await launchUrl(googleMapsWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback final
      return await launchUrl(googleMapsWebUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Abre un modal amigable para elegir cómo navegar
  static void mostrarModalNavegacion(
    BuildContext context, {
    required double lat,
    required double lng,
    required String nombreLugar,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.navigation, color: Colors.blueAccent, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Iniciar Navegación GPS',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          nombreLugar,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.map, color: Colors.redAccent),
                ),
                title: const Text('Abrir en Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Ruta recomendada, tráfico en vivo y guía por voz'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  abrirGoogleMaps(lat: lat, lng: lng, nombreLugar: nombreLugar);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
