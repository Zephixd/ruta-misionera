import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Modelo de datos de un Sitio de Interés / Misión Jesuítica
/// Colección Firestore: sitios/{sitioId}
class Sitio {
  final String id;
  final String nombre;
  final String? nombreGuarani;
  final String descripcion;
  final String historia;
  final String categoria; // "mision_jesuitica" | "museo" | "naturaleza" | "gastronomia" | "otro"
  final double lat;
  final double lng;
  final String imagenAsset;
  final double radioCheckInMetros;
  final int comentariosCount;
  final bool esUnesco;

  const Sitio({
    required this.id,
    required this.nombre,
    this.nombreGuarani,
    required this.descripcion,
    required this.historia,
    required this.categoria,
    required this.lat,
    required this.lng,
    required this.imagenAsset,
    this.radioCheckInMetros = 150.0,
    this.comentariosCount = 0,
    this.esUnesco = false,
  });

  /// Ruta relativa del archivo de audioguía para audioplayers
  String get audioAssetPath => 'audios/$id.mp3';

  /// Etiqueta amigable de la categoría para la UI
  String get categoriaLabel {
    switch (categoria) {
      case 'mision_jesuitica':
        return esUnesco ? 'Patrimonio UNESCO' : 'Misión jesuítica';
      case 'museo':
        return 'Museo y Arte';
      case 'gastronomia':
        return 'Gastronomía Típica';
      case 'naturaleza':
        return 'Naturaleza y Paisaje';
      default:
        return 'Punto de Interés';
    }
  }

  /// Ícono representativo de la categoría
  IconData get categoriaIcon {
    switch (categoria) {
      case 'mision_jesuitica':
        return esUnesco ? Icons.verified : Icons.church;
      case 'museo':
        return Icons.museum;
      case 'gastronomia':
        return Icons.restaurant;
      case 'naturaleza':
        return Icons.forest;
      default:
        return Icons.place;
    }
  }

  factory Sitio.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Sitio(
      id: doc.id,
      nombre: data['nombre'] as String? ?? 'Sitio Histórico',
      nombreGuarani: data['nombreGuarani'] as String?,
      descripcion: data['descripcion'] as String? ?? '',
      historia: data['historia'] as String? ?? '',
      categoria: data['categoria'] as String? ?? 'mision_jesuitica',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      imagenAsset: data['imagenAsset'] as String? ?? 'assets/images/san_ignacio.png',
      radioCheckInMetros: (data['radioCheckInMetros'] as num?)?.toDouble() ?? 150.0,
      comentariosCount: (data['comentariosCount'] as num?)?.toInt() ?? 0,
      esUnesco: data['esUnesco'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      if (nombreGuarani != null) 'nombreGuarani': nombreGuarani,
      'descripcion': descripcion,
      'historia': historia,
      'categoria': categoria,
      'lat': lat,
      'lng': lng,
      'imagenAsset': imagenAsset,
      'radioCheckInMetros': radioCheckInMetros,
      'comentariosCount': comentariosCount,
      'esUnesco': esUnesco,
    };
  }
}
