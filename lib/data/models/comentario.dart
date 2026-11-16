import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para las Reseñas y Comentarios de la comunidad sobre un Sitio.
///
/// **Justificación para defensa oral:**
/// Permite el engagement social (interacción comunitaria), evaluación colaborativa (crowdsourcing de opiniones)
/// y almacenamiento estructurado en subcolecciones de Firestore (`sitios/{sitioId}/comentarios`).
class Comentario {
  final String id;
  final String sitioId;
  final String usuarioUid;
  final String usuarioNombre;
  final String? usuarioFotoUrl;
  final String texto;
  final double calificacion; // 1.0 a 5.0
  final DateTime fecha;
  final int likesCount;
  final List<String> likesUids;

  const Comentario({
    required this.id,
    required this.sitioId,
    required this.usuarioUid,
    required this.usuarioNombre,
    this.usuarioFotoUrl,
    required this.texto,
    required this.calificacion,
    required this.fecha,
    this.likesCount = 0,
    this.likesUids = const [],
  });

  factory Comentario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime fechaParsed = DateTime.now();
    if (data['fecha'] is Timestamp) {
      fechaParsed = (data['fecha'] as Timestamp).toDate();
    } else if (data['fecha'] is String) {
      fechaParsed = DateTime.tryParse(data['fecha']) ?? DateTime.now();
    }

    return Comentario(
      id: doc.id,
      sitioId: data['sitioId'] ?? '',
      usuarioUid: data['usuarioUid'] ?? '',
      usuarioNombre: data['usuarioNombre'] ?? 'Explorador Misionero',
      usuarioFotoUrl: data['usuarioFotoUrl'],
      texto: data['texto'] ?? '',
      calificacion: ((data['calificacion'] ?? 5.0) as num).toDouble(),
      fecha: fechaParsed,
      likesCount: (data['likesCount'] ?? 0) as int,
      likesUids: List<String>.from(data['likesUids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sitioId': sitioId,
      'usuarioUid': usuarioUid,
      'usuarioNombre': usuarioNombre,
      'usuarioFotoUrl': usuarioFotoUrl,
      'texto': texto,
      'calificacion': calificacion,
      'fecha': Timestamp.fromDate(fecha),
      'likesCount': likesCount,
      'likesUids': likesUids,
    };
  }

  Comentario copyWith({
    String? id,
    String? sitioId,
    String? usuarioUid,
    String? usuarioNombre,
    String? usuarioFotoUrl,
    String? texto,
    double? calificacion,
    DateTime? fecha,
    int? likesCount,
    List<String>? likesUids,
  }) {
    return Comentario(
      id: id ?? this.id,
      sitioId: sitioId ?? this.sitioId,
      usuarioUid: usuarioUid ?? this.usuarioUid,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioFotoUrl: usuarioFotoUrl ?? this.usuarioFotoUrl,
      texto: texto ?? this.texto,
      calificacion: calificacion ?? this.calificacion,
      fecha: fecha ?? this.fecha,
      likesCount: likesCount ?? this.likesCount,
      likesUids: likesUids ?? this.likesUids,
    );
  }
}
