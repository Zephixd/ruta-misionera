import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/comentario.dart';

/// Servicio para gestionar comentarios y valoraciones reales de los sitios en Firestore.
///
/// **Justificación para defensa oral:**
/// Permite interacción colaborativa y engagement social (crowdsourcing).
/// Almacena reseñas públicas en `sitios/{sitioId}/comentarios` y otorga +10 puntos
/// al perfil del explorador que publica su opinión.
class ComentariosService {
  final FirebaseFirestore? _customFirestore;

  ComentariosService({FirebaseFirestore? firestore}) : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Obtener stream de comentarios reales para un sitio específico
  Stream<List<Comentario>> getComentariosStream(String sitioId) {
    if (_firestore == null) {
      return Stream.value(const <Comentario>[]);
    }

    try {
      return _firestore!
          .collection('sitios')
          .doc(sitioId)
          .collection('comentarios')
          .snapshots()
          .map((snapshot) {
        final list = <Comentario>[];
        for (final doc in snapshot.docs) {
          try {
            list.add(Comentario.fromFirestore(doc));
          } catch (e) {
            debugPrint('Error convirtiendo reseña ${doc.id}: $e');
          }
        }
        // Ordenar en memoria por fecha más reciente sin requerir índices de Firestore
        list.sort((a, b) => b.fecha.compareTo(a.fecha));
        return list;
      });
    } catch (e) {
      debugPrint('Error inicializando stream de comentarios: $e');
      return Stream.value(const <Comentario>[]);
    }
  }

  /// Agregar un nuevo comentario real en Firestore y premiar con +10 puntos
  Future<void> agregarComentario({
    required String sitioId,
    required String usuarioUid,
    required String usuarioNombre,
    String? usuarioFotoUrl,
    required String texto,
    required double calificacion,
  }) async {
    if (_firestore == null) {
      throw Exception('Servicio de base de datos no disponible.');
    }

    final docRef = _firestore!
        .collection('sitios')
        .doc(sitioId)
        .collection('comentarios')
        .doc();

    final nuevoComentario = Comentario(
      id: docRef.id,
      sitioId: sitioId,
      usuarioUid: usuarioUid,
      usuarioNombre: usuarioNombre,
      usuarioFotoUrl: usuarioFotoUrl,
      texto: texto,
      calificacion: calificacion,
      fecha: DateTime.now(),
      likesCount: 0,
      likesUids: const [],
    );

    // 1. Guardar la reseña en la subcolección de Firestore con timeout de seguridad (10s)
    await docRef.set(nuevoComentario.toMap()).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Tiempo de espera agotado al conectar con el servidor.'),
    );

    // 2. Bonificación de +10 puntos de gamificación al usuario (usando merge para evitar fallos)
    try {
      await _firestore!.collection('usuarios').doc(usuarioUid).set({
        'puntosTotal': FieldValue.increment(10),
        'ultimaActividad': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Aviso al sumar puntos por reseña: $e');
    }
  }

  /// Alternar like en un comentario
  Future<void> toggleLikeComentario({
    required String sitioId,
    required String comentarioId,
    required String usuarioUid,
  }) async {
    if (_firestore == null) return;

    try {
      final docRef = _firestore!
          .collection('sitios')
          .doc(sitioId)
          .collection('comentarios')
          .doc(comentarioId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data() ?? {};
        final List<dynamic> likes = List.from(data['likesUids'] ?? []);
        int count = (data['likesCount'] ?? 0) as int;

        if (likes.contains(usuarioUid)) {
          likes.remove(usuarioUid);
          count = (count - 1).clamp(0, 999999);
        } else {
          likes.add(usuarioUid);
          count += 1;
        }

        await docRef.update({
          'likesUids': likes,
          'likesCount': count,
        });
      }
    } catch (e) {
      debugPrint('Aviso al dar like a reseña: $e');
    }
  }
}
