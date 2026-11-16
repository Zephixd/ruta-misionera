import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state.dart';
import '../auth/auth_provider.dart';
import '../sitio/detalle_sitio_screen.dart';
import 'sitios_provider.dart';
import 'widgets/pasaporte_progress_card.dart';
import 'widgets/sitio_card.dart';

/// Pantalla 4: Inicio (Fiel al UI Kit de Stitch)
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categorias = const [
    {'id': 'todos', 'label': 'Todos', 'icon': Icons.grid_view},
    {'id': 'mision_jesuitica', 'label': 'Misiones', 'icon': Icons.church},
    {'id': 'museo', 'label': 'Museos', 'icon': Icons.museum},
    {'id': 'gastronomia', 'label': 'Gastronomía', 'icon': Icons.restaurant},
    {'id': 'naturaleza', 'label': 'Naturaleza', 'icon': Icons.forest},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final sitiosProvider = context.watch<SitiosProvider>();
    final usuario = authProvider.usuarioApp;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Asegurar que el proveedor de sitios esté escuchando los sellos del usuario actual
    if (authProvider.firebaseUser != null) {
      sitiosProvider.updateUsuarioUid(authProvider.firebaseUser!.uid);
    }

    final sitios = sitiosProvider.sitiosFiltrados;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refrescar sitios
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Saludo y Avatar del Usuario
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.nature_people, size: 16, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              usuario?.nivelExplorador ?? 'Explorador Novato',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '¡Hola, ${usuario?.nombre.split(' ').first ?? 'Viajero'}! 👋',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),

                    // Avatar con Borde y Estrella
                    Stack(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.tertiary, width: 2),
                            color: AppColors.primaryContainer,
                          ),
                          child: Center(
                            child: Text(
                              usuario?.nombre.isNotEmpty == true ? usuario!.nombre[0].toUpperCase() : 'E',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
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
                              color: AppColors.secondary,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Center(
                              child: Icon(Icons.star, size: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Buscador Tipo Píldora
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceContainerDark : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark ? AppColors.outlineDark : const Color(0xFFE4DCD3),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => sitiosProvider.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Buscar misiones, museos...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                sitiosProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Tarjeta de Progreso del Pasaporte Guaraní
                PasaporteProgressCard(
                  sellosCount: sitiosProvider.sellosCount,
                  totalSitios: sitiosProvider.totalSitiosCount,
                  progreso: sitiosProvider.progresoPorcentaje,
                  sitios: sitiosProvider.sitios,
                  isSellado: (id) => sitiosProvider.isSitioSellado(id),
                ),

                const SizedBox(height: 20),

                // 4. Chips Horizontales de Filtros de Categoría
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categorias.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categorias[index];
                      final isSelected = sitiosProvider.categoriaSeleccionada == cat['id'];

                      return GestureDetector(
                        onTap: () => sitiosProvider.setCategoria(cat['id'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLowLight),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.outlineDark : const Color(0xFFE0D8CC)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Encabezado de la Sección de Sitios
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sitios para visitar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                        ),
                        Text(
                          'Patrimonio cultural de la humanidad',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${sitios.length} sitios',
                      style: AppTypography.stampLabel(color: AppColors.primary, fontSize: 11),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 6. Carrusel Horizontal de Tarjetas de Sitios
                if (sitios.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: EmptyState(
                      icon: Icons.travel_explore,
                      title: 'No se encontraron sitios',
                      message: 'Probá buscando con otro nombre o cambiando el filtro de categoría.',
                      actionText: 'Ver todos',
                      onAction: () {
                        _searchController.clear();
                        sitiosProvider.setCategoria('todos');
                        sitiosProvider.setSearchQuery('');
                      },
                    ),
                  )
                else
                  SizedBox(
                    height: 295,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sitios.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final sitio = sitios[index];
                        final isSellado = sitiosProvider.isSitioSellado(sitio.id);
                        final distancia = sitiosProvider.distanciaFormateadaAlSitio(sitio);

                        return SitioCard(
                          sitio: sitio,
                          isSellado: isSellado,
                          distancia: distancia,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleSitioScreen(sitio: sitio),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 20),

                // 7. Botón de Desarrollador / Demo: Carga Inicial de Sitios en Firestore
                if (kDebugMode)
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: AppColors.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Herramienta de desarrollo',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                'Cargar/sincronizar los 8 sitios históricos en Firestore',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: sitiosProvider.isSeeding
                              ? null
                              : () async {
                                  try {
                                    await sitiosProvider.ejecutarSeedEnFirestore();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('¡Sitios jesuíticos subidos a Firestore con éxito!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al subir sitios: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: sitiosProvider.isSeeding
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Sembrar Seed', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
