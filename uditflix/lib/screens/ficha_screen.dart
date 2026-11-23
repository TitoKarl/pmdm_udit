import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../widgets/portada_ancha.dart';
import 'reproductor_screen.dart';

/// Pantalla de detalle de una película o serie.
class FichaScreen extends StatelessWidget {
  const FichaScreen({super.key, required this.contenido});

  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: const Color(0xFF0B0B0F),
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'portada-${contenido.id}',
                    child: PortadaAncha(contenido: contenido),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black38, Colors.transparent],
                        stops: [0, 0.25],
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0B0B0F)],
                        stops: [0.6, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          contenido.titulo,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Valoracion(valoracion: contenido.valoracion),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${contenido.anio}  ·  ${contenido.tipo.etiqueta}'
                    '  ·  ${contenido.duracionFormateada}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final genero in contenido.generos)
                        _EtiquetaGenero(texto: genero),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ReproductorScreen(contenido: contenido),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Reproducir'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '«${contenido.titulo}» añadido a Mi lista',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Mi lista'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Sinopsis',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contenido.sinopsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Ficha técnica',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Detalle(etiqueta: 'Tipo', valor: contenido.tipo.etiqueta),
                  _Detalle(etiqueta: 'Año', valor: '${contenido.anio}'),
                  _Detalle(
                    etiqueta: 'Duración',
                    valor: contenido.esSerie
                        ? '${contenido.duracionMinutos} min por episodio'
                        : contenido.duracionFormateada,
                  ),
                  if (contenido.esSerie)
                    _Detalle(
                      etiqueta: 'Temporadas',
                      valor: '${contenido.temporadas}',
                    ),
                  _Detalle(etiqueta: 'Géneros', valor: contenido.generosTexto),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Valoracion extends StatelessWidget {
  const _Valoracion({required this.valoracion});

  final double valoracion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
          const SizedBox(width: 4),
          Text(
            valoracion.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _EtiquetaGenero extends StatelessWidget {
  const _EtiquetaGenero({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
