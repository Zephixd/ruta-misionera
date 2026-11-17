<div align="center">

<img src="assets/images/Icono.png" alt="Ruta Misionera" width="120">

# Ruta Misionera

**Guía turística móvil de las Misiones Jesuíticas de San Ignacio Guazú, Paraguay**

Recorré los sitios históricos, escuchá sus audioguías y completá tu pasaporte digital de sellos.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

</div>

---

## Sobre el proyecto

**Ruta Misionera** acompaña al visitante por el circuito jesuítico del departamento de Misiones.
Cada sitio tiene su ficha con historia, nombre en guaraní y una audioguía narrada; al llegar
físicamente al lugar, la app valida la ubicación por GPS y otorga un **sello** en el pasaporte
digital del usuario. Los sellos suman puntos para un ranking entre visitantes.

### Sitios incluidos

| | Sitio | | Sitio |
|---|---|---|---|
| ⛪ | Iglesia de San Ignacio | 🏛️ | Museo Diocesano de San Ignacio Guazú |
| 🏛️ | Museo de Arte Jesuítico de Santa María | 🗼 | Torreón Jesuítico de Santa Rosa |
| 🏛️ | Tesoros Jesuíticos de Santiago | 🏰 | Ruinas de la Santísima Trinidad del Paraná |
| 🏰 | Misión Jesuítica de Jesús de Tavarangüé | 🍽️ | Gastronomía misionera |

## Funcionalidades

- 🗺️ **Mapa interactivo** con todos los sitios y la ubicación del visitante en tiempo real.
- 📍 **Check-in por geolocalización**: la distancia al sitio se calcula con la fórmula de
  Haversine y el sello solo se otorga dentro del radio configurado para cada lugar.
- 🎖️ **Pasaporte digital** con álbum de sellos, progreso del recorrido y animación de celebración.
- 🎧 **Audioguías** narradas para cada sitio, con reproductor integrado.
- ⭐ **Reseñas** con calificación de 1 a 5, comentarios y "me gusta".
- 🏆 **Ranking** de visitantes según sellos y puntos obtenidos.
- 🤝 **Sistema de referidos** para invitar a otros visitantes.
- 🔐 **Autenticación** con correo y contraseña o con Google.
- 🧭 **Cómo llegar**: abre la ruta al sitio en la app de mapas del teléfono.

## Tecnologías

| Capa | Tecnología |
|---|---|
| Framework | Flutter · Dart |
| Estado | Provider |
| Autenticación | Firebase Auth · Google Sign-In |
| Base de datos | Cloud Firestore (con reglas de seguridad en `firestore.rules`) |
| Mapas y ubicación | flutter_map (OpenStreetMap) · geolocator |
| Audio | audioplayers |
| Otros | cached_network_image · shared_preferences · share_plus · url_launcher · google_fonts |

## Arquitectura

Organización por funcionalidades (*feature-first*), con la lógica de datos separada de la interfaz:

```
lib/
├── core/            # Tema, utilidades (Haversine, validaciones) y widgets compartidos
├── data/
│   ├── models/      # Sitio, UsuarioApp, Comentario
│   ├── services/    # Auth, sitios, sellos, comentarios, ranking y referidos (Firestore)
│   └── seed/        # Datos iniciales de los sitios
└── features/        # auth · inicio · mapa · sitio · perfil · ranking · ajustes · navigation
```

Colecciones de Firestore: `usuarios`, `sitios`, `sellos`, `comentarios`, `referidos`.

## Cómo ejecutarlo

**Requisitos:** Flutter 3.x y un proyecto de Firebase con Authentication y Firestore habilitados.

```bash
git clone https://github.com/Zephixd/ruta-misionera.git
cd ruta-misionera
flutter pub get
```

Por seguridad, la configuración de Firebase no está incluida en el repositorio. Generala para
tu propio proyecto con [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup):

```bash
flutterfire configure      # crea lib/firebase_options.dart y android/app/google-services.json
firebase deploy --only firestore:rules
flutter run
```

## Autor

**Mathias Sebastian Britos Griffith** — *GreenKnow*
Estudiante de Ingeniería Informática · Universidad Católica «Nuestra Señora de la Asunción», Unidad Pedagógica San Ignacio Guazú

[![Portfolio](https://img.shields.io/badge/Portfolio-greenknow-00ff9c?style=flat-square&logo=vercel&logoColor=white)](https://greenknow-portfolio.vercel.app)
[![GitHub](https://img.shields.io/badge/GitHub-Zephixd-181717?style=flat-square&logo=github)](https://github.com/Zephixd)
