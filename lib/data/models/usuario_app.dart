import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos del Usuario en Firestore
/// Colección: usuarios/{uid}
class UsuarioApp {
  final String uid;
  final String nombre;
  final String email;
  final String? fotoUrl;
  final int sellosCount;
  final int puntosTotal;
  final DateTime creadoEn;

  UsuarioApp({
    required this.uid,
    required this.nombre,
    required this.email,
    this.fotoUrl,
    this.sellosCount = 0,
    this.puntosTotal = 0,
    required this.creadoEn,
  });

  /// Nivel calculado en el cliente según cantidad de sellos (para la experiencia gamificada)
  String get nivelExplorador {
    if (sellosCount >= 6) return 'Maestro de las Misiones';
    if (sellosCount >= 3) return 'Aventurero';
    if (sellosCount >= 1) return 'Explorador Novato';
    return 'Turista Curioso';
  }

  /// Código de referido simple basado en los primeros 6 caracteres del uid
  String get codigoReferido => uid.length >= 6 ? uid.substring(0, 6).toUpperCase() : uid.toUpperCase();

  factory UsuarioApp.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final count = (data['sellosCount'] as num?)?.toInt() ?? 0;
    return UsuarioApp(
      uid: doc.id,
      nombre: data['nombre'] as String? ?? 'Explorador',
      email: data['email'] as String? ?? '',
      fotoUrl: data['fotoUrl'] as String?,
      sellosCount: count,
      puntosTotal: (data['puntosTotal'] as num?)?.toInt() ?? (count * 50),
      creadoEn: (data['creadoEn'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'fotoUrl': fotoUrl,
      'sellosCount': sellosCount,
      'puntosTotal': puntosTotal,
      'creadoEn': Timestamp.fromDate(creadoEn),
    };
  }

  UsuarioApp copyWith({
    String? nombre,
    String? email,
    String? fotoUrl,
    int? sellosCount,
    int? puntosTotal,
    DateTime? creadoEn,
  }) {
    return UsuarioApp(
      uid: uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      sellosCount: sellosCount ?? this.sellosCount,
      puntosTotal: puntosTotal ?? this.puntosTotal,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
