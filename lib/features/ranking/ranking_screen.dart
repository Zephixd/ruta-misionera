import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/usuario_app.dart';
import '../../data/services/ranking_service.dart';
import '../auth/auth_provider.dart';

/// Pantalla 9 y 10: Tabla de Líderes y Ranking de Exploradores Misioneros
///
/// **Justificación para defensa oral:**
/// - Motor de competencia y gamificación social que incentiva a los turistas a recorrer el circuito completo.
/// - Podio gráfico con diseño Material 3 para los primeros 3 puestos.
/// - Tarjeta anclada de posición relativa para que el usuario conozca su progreso en la comunidad.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final RankingService _rankingService = RankingService();

  void _mostrarInfoPuntos(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.tertiary),
            SizedBox(width: 8),
            Text('Sistema de Puntos'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Cómo sumar puntos en la Ruta Misionera?'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                SizedBox(width: 8),
                Expanded(child: Text('Check-in en misión turística: +50 pts')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.rate_review, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('Publicar una reseña: +10 pts')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.share, size: 16, color: AppColors.tertiary),
                SizedBox(width: 8),
                Expanded(child: Text('Invitar a un amigo (Referido): +25 pts')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserUid = authProvider.firebaseUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de Exploradores'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Reglas de puntuación',
            onPressed: () => _mostrarInfoPuntos(context),
          ),
        ],
      ),
      body: StreamBuilder<List<UsuarioApp>>(
        stream: _rankingService.getTopExploradoresStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final exploradores = snapshot.data ?? [];
          if (exploradores.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '¡Sé el primer explorador!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Aún no hay exploradores registrados en el ranking patrimonial.\nRecorré las reducciones jesuíticas, timbrá sellos en tu pasaporte y sumá puntos para liderar el Cuadro de Honor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final top1 = exploradores.isNotEmpty ? exploradores[0] : null;
          final top2 = exploradores.length > 1 ? exploradores[1] : null;
          final top3 = exploradores.length > 2 ? exploradores[2] : null;

          final restoLista = exploradores.length > 3 ? exploradores.sublist(3) : <UsuarioApp>[];

          // Posición del usuario actual
          final indexUsuario = exploradores.indexWhere((u) => u.uid == currentUserUid);
          final usuarioActual = indexUsuario != -1 ? exploradores[indexUsuario] : null;

          return CustomScrollView(
            slivers: [
              // 1. Podio Gráfico de los Top 3 Exploradores
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.surfaceContainerDark, const Color(0xFF1E1714)]
                            : [AppColors.backgroundLight, AppColors.surfaceContainerLowLight],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.outlineDark.withValues(alpha: 0.2) : AppColors.outlineLight.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          'CUADRO DE HONOR',
                          style: AppTypography.stampLabel(
                            color: AppColors.tertiary,
                            fontSize: 12,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Puesto 2 (Plata)
                            if (top2 != null)
                              Expanded(
                                child: _buildPodioItem(
                                  usuario: top2,
                                  puesto: 2,
                                  alturaPodio: 95,
                                  colorMedalla: const Color(0xFFC0C0C0),
                                  isDark: isDark,
                                  isCurrentUser: top2.uid == currentUserUid,
                                ),
                              )
                            else
                              const Spacer(),

                            // Puesto 1 (Oro - Central más alto)
                            if (top1 != null)
                              Expanded(
                                child: _buildPodioItem(
                                  usuario: top1,
                                  puesto: 1,
                                  alturaPodio: 125,
                                  colorMedalla: AppColors.tertiary,
                                  isDark: isDark,
                                  isCurrentUser: top1.uid == currentUserUid,
                                ),
                              )
                            else
                              const Spacer(),

                            // Puesto 3 (Bronce)
                            if (top3 != null)
                              Expanded(
                                child: _buildPodioItem(
                                  usuario: top3,
                                  puesto: 3,
                                  alturaPodio: 75,
                                  colorMedalla: const Color(0xFFCD7F32),
                                  isDark: isDark,
                                  isCurrentUser: top3.uid == currentUserUid,
                                ),
                              )
                            else
                              const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Tarjeta Resaltada de Posición del Usuario Actual (Si está autenticado)
              if (currentUserUid != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Text(
                              indexUsuario != -1 ? '#${indexUsuario + 1}' : '—',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tu Posición en el Ranking',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  usuarioActual != null
                                      ? '${usuarioActual.sellosCount} sellos conseguidos • ${usuarioActual.puntosTotal} puntos'
                                      : 'Realiza tu primer check-in para entrar al top',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_upward, size: 16, color: AppColors.secondary),
                        ],
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // 3. Encabezado de la Lista
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tabla General de Posiciones',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Text(
                        'Top 20',
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Lista del Puesto 4 en adelante
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final puesto = index + 4;
                      final explorador = restoLista[index];
                      final isUser = explorador.uid == currentUserUid;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : (isDark ? AppColors.surfaceContainerDark : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isUser
                                ? AppColors.primary
                                : (isDark ? AppColors.outlineDark.withValues(alpha: 0.15) : AppColors.outlineLight.withValues(alpha: 0.2)),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Número de Puesto
                            SizedBox(
                              width: 28,
                              child: Text(
                                '#$puesto',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Avatar con Inicial
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                              child: Text(
                                explorador.nombre.isNotEmpty ? explorador.nombre[0].toUpperCase() : 'E',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Datos del Explorador
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          explorador.nombre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isUser ? AppColors.primary : null,
                                          ),
                                        ),
                                      ),
                                      if (isUser) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('Tú', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${explorador.sellosCount} sellos • ${explorador.nivelExplorador}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Puntos
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 13, color: AppColors.tertiary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${explorador.puntosTotal} pts',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: restoLista.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodioItem({
    required UsuarioApp usuario,
    required int puesto,
    required double alturaPodio,
    required Color colorMedalla,
    required bool isDark,
    required bool isCurrentUser,
  }) {
    final avatarRadius = puesto == 1 ? 28.0 : 22.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Corona para el primer lugar
        if (puesto == 1)
          const Icon(Icons.workspace_premium, color: AppColors.tertiary, size: 26)
        else
          const SizedBox(height: 26),

        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius + 3,
              backgroundColor: colorMedalla,
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: isDark ? AppColors.surfaceContainerDark : Colors.white,
                child: Text(
                  usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : 'E',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: puesto == 1 ? 20 : 16,
                    color: colorMedalla,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorMedalla,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$puesto',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Nombre
        Text(
          usuario.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: puesto == 1 ? 13 : 11,
            color: isCurrentUser ? AppColors.primary : null,
          ),
        ),

        const SizedBox(height: 2),

        // Puntos
        Text(
          '${usuario.puntosTotal} pts',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: puesto == 1 ? 12 : 10,
            color: colorMedalla,
          ),
        ),

        const SizedBox(height: 6),

        // Base del Podio Gráfico
        Container(
          height: alturaPodio,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: colorMedalla.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: colorMedalla.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$puesto',
                style: TextStyle(
                  fontSize: puesto == 1 ? 20 : 16,
                  fontWeight: FontWeight.w900,
                  color: colorMedalla,
                ),
              ),
              Text(
                '${usuario.sellosCount} sellos',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
