import 'package:flutter/material.dart';

import '../data/contenidos.dart';
import '../models/contenido.dart';
import '../widgets/portada_ancha.dart';
import 'arcade_screen.dart';
import 'ficha_screen.dart';
import 'reproductor_screen.dart';

/// Pantalla principal con el contenido destacado y la cuadrícula del catálogo.
class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final destacado = contenidos.first;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            backgroundColor: Color(0xFF0B0B0F),
            surfaceTintColor: Colors.transparent,
            title: _LogoUditflix(),
          ),
          SliverToBoxAdapter(child: _Destacado(contenido: destacado)),
          SliverToBoxAdapter(
            child: Tooltip(
              message: 'Abrir UDIT Arcade',
              child: _AccesoArcade(
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ArcadeScreen())),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _CabeceraCatalogo()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 160,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _TarjetaContenido(contenido: contenidos[index]),
                childCount: contenidos.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoUditflix extends StatelessWidget {
  const _LogoUditflix();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
        children: [
          TextSpan(
            text: 'UDIT',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'FLIX',
            style: TextStyle(color: Color(0xFFE50914)),
          ),
        ],
      ),
    );
  }
}

class _Destacado extends StatelessWidget {
  const _Destacado({required this.contenido});

  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: SizedBox(
        height: 320,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'destacado-${contenido.id}',
                child: PortadaAncha(contenido: contenido),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xFF0B0B0F)],
                    stops: [0.35, 1],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESTACADO',
                      style: textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFE50914),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contenido.titulo,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${contenido.anio}  ·  ${contenido.tipo.etiqueta}'
                      '  ·  ${contenido.duracionFormateada}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReproductorScreen(contenido: contenido),
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Reproducir'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _abrirFicha(context, contenido),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Más información'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Acceso destacado a la nueva sección de juegos UDIT Arcade.
class _AccesoArcade extends StatelessWidget {
  const _AccesoArcade({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B2D90), Color(0xFFE50914)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.sports_esports, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UDIT Arcade',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Descubre minas, marca banderas y gana',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabeceraCatalogo extends StatelessWidget {
  const _CabeceraCatalogo();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Todo el catálogo',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '${contenidos.length} títulos',
            style: textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _TarjetaContenido extends StatelessWidget {
  const _TarjetaContenido({required this.contenido});

  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _abrirFicha(context, contenido),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'portada-${contenido.id}',
            child: _Portada(contenido: contenido),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
                stops: [0.55, 1],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contenido.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${contenido.tipo.etiqueta} · ${contenido.anio}',
                  style: textTheme.labelSmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Portada extends StatelessWidget {
  const _Portada({required this.contenido});

  final Contenido contenido;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        contenido.portada,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const ColoredBox(
            color: Color(0xFF1A1A22),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const _PortadaVacia(),
      ),
    );
  }
}

class _PortadaVacia extends StatelessWidget {
  const _PortadaVacia();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF24242E), Color(0xFF14141A)],
        ),
      ),
      child: Center(
        child: Icon(Icons.movie_outlined, size: 40, color: Colors.white24),
      ),
    );
  }
}

void _abrirFicha(BuildContext context, Contenido contenido) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => FichaScreen(contenido: contenido)));
}
