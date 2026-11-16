import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'features/ajustes/settings_provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/inicio/sitios_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las credenciales generadas para Android/Web
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Nota: Firebase no inicializado o ya inicializado ($e)');
  }

  // Cargar preferencias locales persistentes (tema, accesibilidad, demo)
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('Nota: SharedPreferences no disponible en main ($e)');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SitiosProvider()),
      ],
      child: const RutaMisioneraApp(),
    ),
  );
}
