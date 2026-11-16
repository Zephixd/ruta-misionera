import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/usuario_app.dart';

/// Servicio de Autenticación con Firebase Auth y sincronización con Firestore.
///
/// **Justificación para defensa oral:**
/// Centraliza toda la comunicación con Firebase Auth y garantiza que cada usuario registrado
/// tenga su documento en la colección `usuarios/{uid}` en Firestore para el ranking de exploradores.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '411316705049-iqnbqptk1ean4tbg8cnu4pjjhogucrd5.apps.googleusercontent.com',
  );

  /// Stream del estado de autenticación (reactivo)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual de Firebase Auth
  User? get currentUser => _auth.currentUser;

  /// Stream en tiempo real de los datos de perfil del usuario en Firestore
  Stream<UsuarioApp?> usuarioAppStream(String uid) {
    return _firestore.collection('usuarios').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UsuarioApp.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Registro con correo, contraseña y nombre
  Future<UsuarioApp> registerWithEmailPassword({
    required String email,
    required String password,
    required String nombre,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw Exception('No se pudo crear la cuenta.');
      }

      // Actualizar nombre visible en el perfil de Firebase Auth
      await user.updateDisplayName(nombre.trim());

      // Crear el documento del usuario en Firestore (usuarios/{uid})
      final nuevoUsuario = UsuarioApp(
        uid: user.uid,
        nombre: nombre.trim(),
        email: email.trim(),
        fotoUrl: null,
        sellosCount: 0,
        creadoEn: DateTime.now(),
      );

      await _firestore.collection('usuarios').doc(user.uid).set(nuevoUsuario.toMap());

      return nuevoUsuario;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Inicio de sesión con correo y contraseña
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Inicio de sesión con Google Sign-In
  Future<UsuarioApp?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el flujo de selección de cuenta
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) return null;

      // Verificar si ya existe en Firestore para no sobreescribir sellosCount
      final userDoc = await _firestore.collection('usuarios').doc(user.uid).get();

      if (!userDoc.exists) {
        final nuevoUsuario = UsuarioApp(
          uid: user.uid,
          nombre: user.displayName ?? googleUser.displayName ?? 'Explorador',
          email: user.email ?? googleUser.email,
          fotoUrl: user.photoURL ?? googleUser.photoUrl,
          sellosCount: 0,
          creadoEn: DateTime.now(),
        );
        await _firestore.collection('usuarios').doc(user.uid).set(nuevoUsuario.toMap());
        return nuevoUsuario;
      } else {
        return UsuarioApp.fromFirestore(userDoc);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      throw Exception('No se pudo completar el inicio de sesión con Google: $e');
    }
  }

  /// Envío de correo para recuperar contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al enviar correo de recuperación: $e');
    }
  }

  /// Actualizar el nombre visible del usuario en Auth y Firestore
  Future<void> actualizarNombre(String nuevoNombre) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay ninguna sesión activa.');
    }

    final nombreLimpio = nuevoNombre.trim();
    if (nombreLimpio.isEmpty) {
      throw Exception('El nombre de explorador no puede estar vacío.');
    }

    try {
      // 1. Actualizar en Firebase Auth
      await user.updateDisplayName(nombreLimpio);

      // 2. Actualizar en Firestore usuarios/{uid}
      await _firestore.collection('usuarios').doc(user.uid).update({
        'nombre': nombreLimpio,
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al actualizar el nombre: $e');
    }
  }

  /// Cambiar la contraseña del usuario (reautenticando con la contraseña actual)
  Future<void> cambiarPassword({
    required String passwordActual,
    required String nuevaPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay ninguna sesión activa.');
    }
    final email = user.email;
    if (email == null) {
      throw Exception('No se encontró un correo electrónico asociado a esta cuenta.');
    }

    if (nuevaPassword.length < 6) {
      throw Exception('La nueva contraseña debe tener al menos 6 caracteres.');
    }

    try {
      // 1. Reautenticar con las credenciales actuales por seguridad
      final credential = EmailAuthProvider.credential(
        email: email,
        password: passwordActual,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Actualizar contraseña
      await user.updatePassword(nuevaPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al cambiar la contraseña: $e');
    }
  }

  /// Cierre de sesión seguro
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  /// Traducción amigable de excepciones de Firebase al español
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe ninguna cuenta registrada con este correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña o correo incorrectos. Verificá tus datos.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado. Probá iniciar sesión.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Revisá tus datos móviles o Wi-Fi.';
      case 'user-disabled':
        return 'Esta cuenta de usuario ha sido inhabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por seguridad, esperá unos minutos.';
      default:
        return e.message ?? 'Ocurrió un error de autenticación.';
    }
  }
}
