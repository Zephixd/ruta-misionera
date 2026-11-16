import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/haversine.dart';
import '../models/sitio.dart';

/// Resultado de la operación de Check-in GPS
class CheckInResult {
  final bool success;
  final String mensaje;
  final double? distanciaMetros;
  final int puntosOtorgados;
  final bool yaEstabaSellado;
  final DateTime? fecha;

  const CheckInResult({
    required this.success,
    required this.mensaje,
    this.distanciaMetros,
    this.puntosOtorgados = 0,
    this.yaEstabaSellado = false,
    this.fecha,
  });
}

/// Servicio de Pasaporte de Sellos y Gamificación en Firestore
///
/// **Justificación para defensa oral de tesis:**
/// - Implementa geocercado (geofencing) en el cliente mediante la fórmula trigonométrica de Haversine.
/// - Asegura transacciones atómicas de gamificación con `FieldValue.increment` para evitar condiciones de carrera en el puntaje.
/// - Admite modo de simulación académica (Modo Demo) para demostraciones en vivo ante el tribunal de evaluación.
class SellosService {
  final FirebaseFirestore? _customFirestore;

  SellosService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Retorna un stream con la lista de IDs de sitios que el usuario ya selló
  Stream<List<String>> getSellosUsuarioStream(String uid) {
    if (uid.isEmpty || _firestore == null) {
      return Stream.value(<String>[]);
    }

    return _firestore!
        .collection('usuarios')
        .doc(uid)
        .collection('sellos')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList())
        .handleError((error) {
      debugPrint('Aviso: Error obteniendo sellos de usuario ($error)');
      return <String>[];
    });
  }

  /// Retorna los documentos completos de sellos del usuario con sus fechas
  Stream<Map<String, DateTime>> getSellosDetalleStream(String uid) {
    if (uid.isEmpty || _firestore == null) {
      return Stream.value(<String, DateTime>{});
    }

    return _firestore!
        .collection('usuarios')
        .doc(uid)
        .collection('sellos')
        .snapshots()
        .map((snapshot) {
      final mapa = <String, DateTime>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        DateTime fecha = DateTime.now();
        if (data['fecha'] is Timestamp) {
          fecha = (data['fecha'] as Timestamp).toDate();
        }
        mapa[doc.id] = fecha;
      }
      return mapa;
    }).handleError((_) => <String, DateTime>{});
  }

  /// Verifica si el usuario ya posee el sello de un sitio
  Future<bool> hasSello(String uid, String sitioId) async {
    if (uid.isEmpty || sitioId.isEmpty || _firestore == null) return false;
    try {
      final doc = await _firestore!
          .collection('usuarios')
          .doc(uid)
          .collection('sellos')
          .doc(sitioId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error verificando sello: $e');
      return false;
    }
  }

  /// Realiza la validación GPS (Haversine) y registra el sello en Firestore
  Future<CheckInResult> registrarCheckIn({
    required String usuarioUid,
    required Sitio sitio,
    double? latActual,
    double? lngActual,
    bool isDemoMode = false,
  }) async {
    if (usuarioUid.isEmpty) {
      return const CheckInResult(
        success: false,
        mensaje: 'Debes iniciar sesión con tu cuenta para registrar sellos en tu pasaporte.',
      );
    }

    // 1. Verificar si ya fue sellado previamente
    final yaSellado = await hasSello(usuarioUid, sitio.id);
    if (yaSellado) {
      return const CheckInResult(
        success: false,
        yaEstabaSellado: true,
        mensaje: 'Ya has conseguido este sello en tu pasaporte turístico.',
      );
    }

    // 2. Calcular distancia con la fórmula de Haversine
    double? distancia;
    if (latActual != null && lngActual != null) {
      distancia = HaversineUtils.distanceInMeters(
        lat1: latActual,
        lon1: lngActual,
        lat2: sitio.lat,
        lon2: sitio.lng,
      );
    }

    // 3. Validación de geocerca (Geofencing)
    final dentroDelRadio = distancia != null && distancia <= sitio.radioCheckInMetros;

    if (!dentroDelRadio && !isDemoMode) {
      final distanciaTexto = distancia != null
          ? HaversineUtils.formatDistance(distancia)
          : 'Ubicación GPS desconocida';
      final radioTexto = HaversineUtils.formatDistance(sitio.radioCheckInMetros);

      return CheckInResult(
        success: false,
        distanciaMetros: distancia,
        mensaje: 'Estás a $distanciaTexto del sitio. Debes acercarte a menos de $radioTexto para desbloquear el sello, o activar el Modo Demo para la defensa.',
      );
    }

    // 4. Registro atómico en Firestore
    const puntosGanados = 50;
    final ahora = DateTime.now();

    if (_firestore == null) {
      return CheckInResult(
        success: isDemoMode,
        puntosOtorgados: isDemoMode ? puntosGanados : 0,
        distanciaMetros: distancia,
        fecha: ahora,
        mensaje: isDemoMode
            ? '¡Sello simulado en Modo Demo! (+50 pts)'
            : 'Base de datos no inicializada',
      );
    }

    try {
      final batch = _firestore!.batch();

      // Guardar sello en subcolección
      final selloRef = _firestore!
          .collection('usuarios')
          .doc(usuarioUid)
          .collection('sellos')
          .doc(sitio.id);

      batch.set(selloRef, {
        'sitioId': sitio.id,
        'sitioNombre': sitio.nombre,
        'fecha': Timestamp.fromDate(ahora),
        'puntosOtorgados': puntosGanados,
        'esModoDemo': isDemoMode,
        'distanciaValidada': distancia ?? 0.0,
      });

      // Actualizar puntos acumulados y contador del usuario
      final userRef = _firestore!.collection('usuarios').doc(usuarioUid);
      batch.update(userRef, {
        'puntosTotal': FieldValue.increment(puntosGanados),
        'sellosCount': FieldValue.increment(1),
        'ultimaActividad': Timestamp.fromDate(ahora),
      });

      await batch.commit();

      return CheckInResult(
        success: true,
        puntosOtorgados: puntosGanados,
        distanciaMetros: distancia,
        fecha: ahora,
        mensaje: isDemoMode
            ? '¡Sello desbloqueado en Modo Demostración! (+50 pts)'
            : '¡Check-in GPS exitoso! Sello agregado a tu Pasaporte (+50 pts)',
      );
    } catch (e) {
      debugPrint('Error registrando check-in en Firestore: $e');
      return CheckInResult(
        success: false,
        mensaje: 'Ocurrió un error al registrar el sello: $e',
      );
    }
  }
}
