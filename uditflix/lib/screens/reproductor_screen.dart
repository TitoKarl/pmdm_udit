import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../models/contenido.dart';

/// Vídeo MP4 público de demostración (comprobado: responde 206 `video/mp4`).
const String videoDemoUrl = 'https://media.w3.org/2010/05/sintel/trailer.mp4';

/// Reproductor real integrado en UDITflix.
///
/// Mantiene la navegación existente desde la ficha y el catálogo. La reproduce
/// con `video_player`, ofrece controles básicos y una vista a pantalla completa.
class ReproductorScreen extends StatefulWidget {
  const ReproductorScreen({
    super.key,
    required this.contenido,
    this.videoUrl = videoDemoUrl,
  });

  final Contenido contenido;

  /// URL del vídeo. Se puede sustituir en pruebas o por un recurso local.
  final String videoUrl;

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<ReproductorScreen> {
  late final VideoPlayerController _controller;
  bool _inicializado = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.addListener(_alCambiar);
    _iniciar();
  }

  Future<void> _iniciar() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() => _inicializado = true);
      await _controller.play();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    }
  }

  void _alCambiar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_alCambiar);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _abrirPantallaCompleta() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _PantallaCompleta(controller: _controller),
      ),
    );
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _Cabecera(
              contenido: widget.contenido,
              onVolver: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Center(child: _vistaVideo()),
            ),
            if (_inicializado && _error == null)
              _ControlesReproductor(
                controller: _controller,
                onPantallaCompleta: _abrirPantallaCompleta,
              ),
          ],
        ),
      ),
    );
  }

  Widget _vistaVideo() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el vídeo de demostración',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (!_inicializado) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE50914)),
      );
    }

    final aspectRatio = _controller.value.aspectRatio;
    return AspectRatio(
      aspectRatio: aspectRatio > 0 ? aspectRatio : 16 / 9,
      child: GestureDetector(
        onTap: _alternarReproduccion,
        child: VideoPlayer(_controller),
      ),
    );
  }

  void _alternarReproduccion() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.contenido, required this.onVolver});

  final Contenido contenido;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onVolver,
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(backgroundColor: Colors.black38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contenido.titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  contenido.generosTexto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'DEMO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Controles compartidos entre la vista normal y la pantalla completa.
class _ControlesReproductor extends StatelessWidget {
  const _ControlesReproductor({
    required this.controller,
    required this.onPantallaCompleta,
  });

  final VideoPlayerController controller;
  final VoidCallback onPantallaCompleta;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final duracion = value.duration;
    final posicion = value.position;
    final maximo = duracion.inSeconds > 0 ? duracion.inSeconds.toDouble() : 1.0;
    final actual = posicion.inSeconds.clamp(0, duracion.inSeconds).toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: const Color(0xFFE50914),
              inactiveTrackColor: Colors.white24,
              thumbColor: const Color(0xFFE50914),
              overlayColor: const Color(0x33E50914),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: actual,
              max: maximo,
              onChanged: (valor) {
                controller.seekTo(Duration(seconds: valor.round()));
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _alternar(controller),
                color: Colors.white,
                icon: Icon(
                  value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                tooltip: value.isPlaying ? 'Pausar' : 'Reproducir',
              ),
              IconButton(
                onPressed: () => _saltar(controller, const Duration(seconds: -10)),
                color: Colors.white,
                icon: const Icon(Icons.replay_10),
                tooltip: 'Retroceder 10 s',
              ),
              IconButton(
                onPressed: () => _saltar(controller, const Duration(seconds: 10)),
                color: Colors.white,
                icon: const Icon(Icons.forward_10),
                tooltip: 'Avanzar 10 s',
              ),
              const Spacer(),
              Text(
                '${_formatear(posicion)} / ${_formatear(duracion)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onPantallaCompleta,
                color: Colors.white,
                icon: const Icon(Icons.fullscreen),
                tooltip: 'Pantalla completa',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _alternar(VideoPlayerController controller) {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _saltar(VideoPlayerController controller, Duration salto) {
    var destino = controller.value.position + salto;
    if (destino < Duration.zero) {
      destino = Duration.zero;
    }
    final fin = controller.value.duration;
    if (fin > Duration.zero && destino > fin) {
      destino = fin;
    }
    controller.seekTo(destino);
  }

  String _formatear(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos =
        duracion.inSeconds.remainder(60).toString().padLeft(2, '0');
    return horas > 0 ? '$horas:$minutos:$segundos' : '$minutos:$segundos';
  }
}

/// Vista a pantalla completa reutiliza el mismo controlador (no se reinicia).
class _PantallaCompleta extends StatefulWidget {
  const _PantallaCompleta({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_PantallaCompleta> createState() => _PantallaCompletaState();
}

class _PantallaCompletaState extends State<_PantallaCompleta> {
  bool _controlesVisibles = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_alCambiar);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_alCambiar);
    super.dispose();
  }

  void _alCambiar() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.controller.value.aspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(
                  () => _controlesVisibles = !_controlesVisibles,
                ),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: aspectRatio > 0 ? aspectRatio : 16 / 9,
                    child: VideoPlayer(widget.controller),
                  ),
                ),
              ),
            ),
            if (_controlesVisibles)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent, Colors.black87],
                      stops: [0, 0.4, 1],
                    ),
                  ),
                ),
              ),
            if (_controlesVisibles)
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: 'Salir de pantalla completa',
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            if (_controlesVisibles)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ControlesReproductor(
                  controller: widget.controller,
                  onPantallaCompleta: () => Navigator.of(context).maybePop(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
