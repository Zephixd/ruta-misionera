import 'dart:math' as math;

/// Utilidad para cálculo de distancias geográficas mediante la Fórmula del Haversine.
///
/// **Justificación teórica para defensa oral:**
/// La Tierra no es plana; es una esfera aproximada (geoide). La fórmula del Haversine
/// calcula la distancia de círculo máximo ("gran círculo") entre dos puntos en una esfera
/// a partir de sus latitudes y longitudes, evitando errores significativos causados
/// por la proyección plana.
class HaversineUtils {
  /// Radio medio de la Tierra en metros (WGS-84 aproximado)
  static const double _earthRadiusMeters = 6371000.0;

  /// Retorna la distancia en metros entre dos coordenadas (lat1, lon1) y (lat2, lon2).
  static double distanceInMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    // 1. Convertir grados decimales a radianes
    final double phi1 = _degreesToRadians(lat1);
    final double phi2 = _degreesToRadians(lat2);
    final double deltaPhi = _degreesToRadians(lat2 - lat1);
    final double deltaLambda = _degreesToRadians(lon2 - lon1);

    // 2. Aplicar la ecuación del Haversine:
    // a = sin²(Δφ/2) + cos(φ1) * cos(φ2) * sin²(Δλ/2)
    final double a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
        math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);

    // 3. Ángulo angular central c = 2 * atan2(√a, √(1−a))
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    // 4. Distancia d = R * c
    return _earthRadiusMeters * c;
  }

  /// Retorna la distancia en kilómetros entre dos coordenadas.
  static double distanceInKilometers({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return distanceInMeters(
      lat1: lat1,
      lon1: lon1,
      lat2: lat2,
      lon2: lon2,
    ) / 1000.0;
  }

  /// Convierte la distancia en un texto legible para el usuario en la UI.
  /// Ejemplos: "85 m", "1,4 km", "25 km"
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final double km = meters / 1000.0;
      return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
    }
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
