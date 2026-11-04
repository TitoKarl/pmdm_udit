import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/contenido.dart';

/// Reproductor de demostración.
///
/// La reproducción está simulada con un [Timer]. Para reproducir vídeo real
/// habría que integrar el paquete `video_player` y usar la URL del contenido.
class ReproductorScreen extends StatefulWidget {
  const ReproductorScreen({super.key, required this.contenido});

  final Contenido contenido;

  @override
  State<ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<ReproductorScreen> {
  Timer? _timer;
  Duration _posicion = Duration.zero;
  late final Duration _duracion;
  bool _reproduciendo = true;

  @override
  void initState() {
    super.initState();
    _duracion = Duration(
      minutes: widget.contenido.esSerie
          ? 45
          : widget.contenido.duracionMinutos,
    );
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _iniciarReproduccion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _iniciarReproduccion() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final siguiente = _posicion + const Duration(seconds: 1);
      if (siguiente >= _duracion) {
        setState(() {
          _posicion = _duracion;
          _reproduciendo = false;
        });
        _timer?.cancel();
      } else {
        setState(() => _posicion = siguiente);
      }
    });
  }

  void _alternarReproduccion() {
    if (_posicion >= _duracion) {
      setState(() {
        _posicion = Duration.zero;
        _reproduciendo = true;
      });
      _iniciarReproduccion();
      return;
    }

    setState(() => _reproduciendo = !_reproduciendo);
    if (_reproduciendo) {
      _iniciarReproduccion();
    } else {
      _timer?.cancel();
    }
  }

  void _saltar(Duration salto) {
    var destino = _posicion + salto;
    if (destino < Duration.zero) {
      destino = Duration.zero;
    } else if (destino > _duracion) {
      destino = _duracion;
    }
    setState(() => _posicion = destino);
  }

  bool get _haTerminado => _posicion >= _duracion;

  IconData get _iconoCentral {
    if (_haTerminado) {
      return Icons.replay;
    }
    return _reproduciendo ? Icons.pause : Icons.play_arrow;
  }

  IconData get _iconoInferior {
    if (_haTerminado) {
      return Icons.replay;
    }
    return _reproduciendo ? Icons.pause : Icons.play_arrow;
  }

  String _formatear(Duration duracion) {
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos =
        duracion.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (horas > 0) {
      return '$horas:$minutos:$segundos';
    }
    return '$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.contenido.portada,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF24242E), Color(0xFF0B0B0F)],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.movie_outlined,
                  size: 80,
                  color: Colors.white12,
                ),
              ),
            ),
          ),
          const ColoredBox(color: Colors.black54),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black38,
                        ),
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Volver',
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.contenido.titulo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.contenido.generosTexto,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                ),
                Expanded(
                  child: Center(
                    child: IconButton(
                      onPressed: _alternarReproduccion,
                      iconSize: 72,
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black45,
                      ),
                      icon: Icon(_iconoCentral),
                      tooltip: _reproduciendo ? 'Pausar' : 'Reproducir',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: _posicion.inSeconds.toDouble(),
                          max: _duracion.inSeconds.toDouble(),
                          onChanged: (valor) => setState(
                            () => _posicion = Duration(
                              seconds: valor.round(),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _alternarReproduccion,
                            color: Colors.white,
                            icon: Icon(_iconoInferior),
                            tooltip: _reproduciendo ? 'Pausar' : 'Reproducir',
                          ),
                          IconButton(
                            onPressed: () =>
                                _saltar(const Duration(seconds: -10)),
                            color: Colors.white,
                            icon: const Icon(Icons.replay_10),
                            tooltip: 'Retroceder 10 s',
                          ),
                          IconButton(
                            onPressed: () =>
                                _saltar(const Duration(seconds: 10)),
                            color: Colors.white,
                            icon: const Icon(Icons.forward_10),
                            tooltip: 'Avanzar 10 s',
                          ),
                          const Spacer(),
                          Text(
                            '${_formatear(_posicion)} / ${_formatear(_duracion)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.volume_up_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
