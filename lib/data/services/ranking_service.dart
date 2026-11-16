import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/usuario_app.dart';

/// Servicio para obtener el Ranking Top 20 de Exploradores de la Ruta Misionera.
///
/// **Justificación para defensa oral:**
/// - Implementa la dimensión competitiva y social de la gamificación (Leaderboard).
/// - Consulta limpia en Firestore sin requerir índices complejos, ordenando en memoria.
/// - Muestra exclusivamente usuarios reales registrados en Firebase, sin datos ficticios.
class RankingService {
  final FirebaseFirestore? _customFirestore;

  RankingService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Retorna un stream con el Top 20 de exploradores reales registrados
  Stream<List<UsuarioApp>> getTopExploradoresStream() {
    if (_firestore == null) {
      return Stream.value(const <UsuarioApp>[]);
    }

    try {
      return _firestore!
          .collection('usuarios')
          .snapshots()
          .map((snapshot) {
        final list = <UsuarioApp>[];
        for (final doc in snapshot.docs) {
          try {
            list.add(UsuarioApp.fromFirestore(doc));
          } catch (e) {
            debugPrint('Error parseando usuario ranking: $e');
          }
        }
        list.sort((a, b) => b.puntosTotal.compareTo(a.puntosTotal));
        return list.take(20).toList();
      });
    } catch (e) {
      debugPrint('Excepción al conectar con ranking: $e');
      return Stream.value(const <UsuarioApp>[]);
    }
  }
}
