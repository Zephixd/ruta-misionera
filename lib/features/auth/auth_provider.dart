import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/models/usuario_app.dart';
import '../../data/services/auth_service.dart';

/// Provider de Autenticación de la App.
///
/// **Justificación para defensa oral:**
/// Implementa el patrón Observer mediante `ChangeNotifier`. La interfaz gráfica
/// reacciona automáticamente a cambios de sesión sin necesidad de recargar manualmente.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UsuarioApp? _usuarioApp;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UsuarioApp?>? _usuarioSubscription;

  User? get firebaseUser => _firebaseUser;
  UsuarioApp? get usuarioApp => _usuarioApp;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get canChangePassword {
    if (_firebaseUser == null) return false;
    return _firebaseUser!.providerData.any((p) => p.providerId == 'password');
  }

  bool get isGoogleUser {
    if (_firebaseUser == null) return false;
    return _firebaseUser!.providerData.any((p) => p.providerId == 'google.com');
  }

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      _firebaseUser = user;
      _usuarioSubscription?.cancel();

      if (user != null) {
        // Escuchar en tiempo real los cambios del perfil en Firestore (sellos, nivel, etc.)
        _usuarioSubscription = _authService.usuarioAppStream(user.uid).listen((usuario) {
          _usuarioApp = usuario;
          notifyListeners();
        });
      } else {
        _usuarioApp = null;
        notifyListeners();
      }
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final nuevoUsuario = await _authService.registerWithEmailPassword(
        email: email,
        password: password,
        nombre: nombre,
      );
      _usuarioApp = nuevoUsuario;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _usuarioApp = user;
      }
      _setLoading(false);
      return user != null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateDisplayName(String nuevoNombre) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.actualizarNombre(nuevoNombre);
      if (_usuarioApp != null) {
        _usuarioApp = _usuarioApp!.copyWith(nombre: nuevoNombre.trim());
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword({
    required String passwordActual,
    required String nuevaPassword,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.cambiarPassword(
        passwordActual: passwordActual,
        nuevaPassword: nuevaPassword,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _usuarioSubscription?.cancel();
    super.dispose();
  }
}
