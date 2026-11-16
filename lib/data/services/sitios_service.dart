import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/sitio.dart';
import '../seed/seed_sitios.dart';

/// Servicio de datos para los Sitios de Interés en Cloud Firestore.
/// Colección: `sitios/{sitioId}`
class SitiosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream en tiempo real de todos los sitios registrados
  /// Si la base de datos aún no tiene sitios o está sin conexión, entrega los datos iniciales de respaldo.
  Stream<List<Sitio>> getSitiosStream() {
    return _firestore.collection('sitios').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return SeedSitios.sitiosIniciales;
      }
      return snapshot.docs.map((doc) => Sitio.fromFirestore(doc)).toList();
    }).handleError((error) {
      debugPrint('Aviso: Error obteniendo sitios de Firestore ($error). Usando fallback local.');
      return SeedSitios.sitiosIniciales;
    });
  }

  /// Obtener un sitio específico por su ID
  Future<Sitio?> getSitioById(String id) async {
    try {
      final doc = await _firestore.collection('sitios').doc(id).get();
      if (doc.exists) {
        return Sitio.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error obteniendo sitio $id: $e');
    }
    // Fallback de búsqueda local
    try {
      return SeedSitios.sitiosIniciales.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Carga (Seed) de los sitios iniciales en Firestore.
  /// Si `force` es false, solo los sube si la colección está vacía.
  Future<int> seedSitiosIniciales({bool force = false}) async {
    try {
      final snapshot = await _firestore.collection('sitios').get();
      if (snapshot.docs.isNotEmpty && !force) {
        debugPrint('Los sitios ya existen en Firestore (${snapshot.docs.length} documentos).');
        return snapshot.docs.length;
      }

      final batch = _firestore.batch();
      for (final sitio in SeedSitios.sitiosIniciales) {
        final docRef = _firestore.collection('sitios').doc(sitio.id);
        batch.set(docRef, sitio.toMap());
      }
      await batch.commit();
      debugPrint('Seed completado exitosamente: ${SeedSitios.sitiosIniciales.length} sitios cargados.');
      return SeedSitios.sitiosIniciales.length;
    } catch (e) {
      debugPrint('Error cargando seed de sitios: $e');
      rethrow;
    }
  }
}
