import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/utils/haversine.dart';
import '../../data/models/sitio.dart';
import '../../data/services/sellos_service.dart';
import '../../data/services/sitios_service.dart';

/// Provider que administra los sitios turísticos, filtros, distancias GPS
/// y estado del pasaporte de sellos del usuario actual.
class SitiosProvider extends ChangeNotifier {
  final SitiosService _sitiosService = SitiosService();
  final SellosService _sellosService = SellosService();

  List<Sitio> _sitios = [];
  List<String> _sellosObtenidosIds = [];
  String _categoriaSeleccionada = 'todos';
  String _searchQuery = '';
  Position? _currentPosition;
  bool _isLoading = true;
  bool _isSeeding = false;

  StreamSubscription<List<Sitio>>? _sitiosSubscription;
  StreamSubscription<List<String>>? _sellosSubscription;

  List<Sitio> get sitios => _sitios;
  List<String> get sellosObtenidosIds => _sellosObtenidosIds;
  String get categoriaSeleccionada => _categoriaSeleccionada;
  String get searchQuery => _searchQuery;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  bool get isSeeding => _isSeeding;

  int get totalSitiosCount => _sitios.isNotEmpty ? _sitios.length : 6;
  int get sellosCount => _sellosObtenidosIds.length;
  double get progresoPorcentaje => totalSitiosCount > 0 ? (sellosCount / totalSitiosCount).clamp(0.0, 1.0) : 0.0;

  SitiosProvider() {
    _initSitiosStream();
    _fetchCurrentLocation();
  }

  void _initSitiosStream() {
    _sitiosSubscription = _sitiosService.getSitiosStream().listen((data) {
      _sitios = data;
      _isLoading = false;
      notifyListeners();

      // Sembrar los 8 sitios históricos en Firestore si la colección está vacía
      _sitiosService.seedSitiosIniciales(force: false);
    });
  }

  /// Escuchar sellos cuando el usuario inicia sesión
  void updateUsuarioUid(String? uid) {
    _sellosSubscription?.cancel();
    if (uid != null && uid.isNotEmpty) {
      _sellosSubscription = _sellosService.getSellosUsuarioStream(uid).listen((sellos) {
        _sellosObtenidosIds = sellos;
        notifyListeners();
      });
    } else {
      _sellosObtenidosIds = [];
      notifyListeners();
    }
  }

  /// Intentar obtener ubicación GPS de forma silenciosa para calcular distancias
  Future<void> _fetchCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        notifyListeners();
      }
    } catch (_) {
      // Ignorar si el usuario aún no otorgó permisos
    }
  }

  void setCategoria(String categoria) {
    if (_categoriaSeleccionada != categoria) {
      _categoriaSeleccionada = categoria;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isSitioSellado(String sitioId) {
    return _sellosObtenidosIds.contains(sitioId);
  }

  /// Distancia en metros desde la posición actual al sitio
  double? distanciaMetrosAlSitio(Sitio sitio) {
    if (_currentPosition == null) return null;
    return HaversineUtils.distanceInMeters(
      lat1: _currentPosition!.latitude,
      lon1: _currentPosition!.longitude,
      lat2: sitio.lat,
      lon2: sitio.lng,
    );
  }

  /// Texto formateado de la distancia ("1,2 km", "85 m", etc.)
  String? distanciaFormateadaAlSitio(Sitio sitio) {
    final metros = distanciaMetrosAlSitio(sitio);
    if (metros == null) return null;
    return HaversineUtils.formatDistance(metros);
  }

  /// Lista filtrada según categoría y texto de búsqueda
  List<Sitio> get sitiosFiltrados {
    return _sitios.where((s) {
      final matchesCategory = _categoriaSeleccionada == 'todos' || s.categoria == _categoriaSeleccionada;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          s.nombre.toLowerCase().contains(query) ||
          (s.nombreGuarani != null && s.nombreGuarani!.toLowerCase().contains(query)) ||
          s.descripcion.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Acción de desarrollo para sembrar (seed) sitios en Firestore
  Future<void> ejecutarSeedEnFirestore() async {
    _isSeeding = true;
    notifyListeners();
    try {
      await _sitiosService.seedSitiosIniciales(force: true);
    } finally {
      _isSeeding = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sitiosSubscription?.cancel();
    _sellosSubscription?.cancel();
    super.dispose();
  }
}
