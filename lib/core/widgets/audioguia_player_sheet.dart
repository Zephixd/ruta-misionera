import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../data/models/sitio.dart';

/// Modal BottomSheet con reproductor interactivo de audioguía para un Sitio.
/// Permite reproducir, pausar, adelantar (+10s), retroceder (-10s), buscar con Slider
/// y ajustar velocidad de reproducción.
class AudioGuiaPlayerSheet extends StatefulWidget {
  final Sitio sitio;

  const AudioGuiaPlayerSheet({
    super.key,
    required this.sitio,
  });

  /// Muestra el modal de audioguía de forma modal y fluida
  static Future<void> mostrar(BuildContext context, Sitio sitio) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AudioGuiaPlayerSheet(sitio: sitio),
    );
  }

  @override
  State<AudioGuiaPlayerSheet> createState() => _AudioGuiaPlayerSheetState();
}

class _AudioGuiaPlayerSheetState extends State<AudioGuiaPlayerSheet> {
  final AudioPlayer _player = AudioPlayer();

  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;
  String? _errorMessage;
  double _playbackRate = 1.0;

  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _completeSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      _stateSub = _player.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _playerState = state);
      });

      _durationSub = _player.onDurationChanged.listen((d) {
        if (mounted && d > Duration.zero) {
          setState(() {
            _duration = d;
            _isLoading = false;
          });
        }
      });

      _positionSub = _player.onPositionChanged.listen((p) {
        if (mounted) {
          setState(() {
            _position = p;
            _isLoading = false;
          });
        }
      });

      _completeSub = _player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _position = Duration.zero;
            _playerState = PlayerState.stopped;
          });
        }
      });

      // Configurar fuente y reproducir automáticamente
      await _player.setSource(AssetSource(widget.sitio.audioAssetPath));
      await _player.resume();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se pudo cargar el audio: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completeSub?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_playerState == PlayerState.completed || _position >= _duration) {
        await _player.seek(Duration.zero);
      }
      await _player.resume();
    }
  }

  Future<void> _seekRelative(int seconds) async {
    final newSeconds = (_position.inSeconds + seconds).clamp(0, _duration.inSeconds);
    await _player.seek(Duration(seconds: newSeconds));
  }

  Future<void> _cambiarVelocidad() async {
    double nuevaVelocidad;
    if (_playbackRate == 1.0) {
      nuevaVelocidad = 1.25;
    } else if (_playbackRate == 1.25) {
      nuevaVelocidad = 1.5;
    } else {
      nuevaVelocidad = 1.0;
    }
    await _player.setPlaybackRate(nuevaVelocidad);
    if (mounted) setState(() => _playbackRate = nuevaVelocidad);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxSeconds = _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;
    final currentSeconds = _position.inSeconds.toDouble().clamp(0.0, maxSeconds);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tirador superior del modal
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Encabezado con imagen miniatura, título y botón cerrar
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    widget.sitio.imagenAsset,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 58,
                      height: 58,
                      color: AppColors.primary,
                      child: const Icon(Icons.headphones, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.volume_up, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'AUDIOGUÍA PATRIMONIAL',
                            style: AppTypography.stampLabel(
                              color: AppColors.primary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.sitio.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isPlaying
                            ? 'Reproduciendo relato histórico...'
                            : (_isLoading ? 'Cargando narración...' : 'Audioguía lista'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Barra de progreso interactiva (Slider)
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withValues(alpha: 0.2),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: Slider(
                min: 0.0,
                max: maxSeconds,
                value: currentSeconds,
                onChanged: (val) {
                  _player.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),

            // Tiempos (Actual vs Total)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                    ),
                  ),
                  Text(
                    _formatDuration(_duration),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Controles de Reproducción: Retroceder 10s, Play/Pause, Adelantar 10s y Velocidad
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Velocidad
                TextButton(
                  onPressed: _cambiarVelocidad,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(44, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    '${_playbackRate}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Retroceder 10s
                IconButton(
                  iconSize: 34,
                  tooltip: 'Retroceder 10 segundos',
                  icon: const Icon(Icons.replay_10_rounded),
                  color: isDark ? Colors.white70 : Colors.black87,
                  onPressed: () => _seekRelative(-10),
                ),

                const SizedBox(width: 12),

                // Play / Pausa Principal
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 36,
                    color: Colors.white,
                    tooltip: _isPlaying ? 'Pausar' : 'Reproducir',
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    onPressed: _togglePlayPause,
                  ),
                ),

                const SizedBox(width: 12),

                // Adelantar 10s
                IconButton(
                  iconSize: 34,
                  tooltip: 'Adelantar 10 segundos',
                  icon: const Icon(Icons.forward_10_rounded),
                  color: isDark ? Colors.white70 : Colors.black87,
                  onPressed: () => _seekRelative(10),
                ),

                const SizedBox(width: 8),

                // Botón Reiniciar
                IconButton(
                  iconSize: 22,
                  tooltip: 'Reiniciar narración',
                  icon: const Icon(Icons.refresh_rounded),
                  color: isDark ? Colors.white54 : Colors.black54,
                  onPressed: () {
                    _player.seek(Duration.zero);
                    _player.resume();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
