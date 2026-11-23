import 'package:flutter/material.dart';

import '../models/contenido.dart';

/// Imagen panorámica para el contenido destacado y la cabecera de la ficha.
///
/// Pide a Picsum una versión ancha de la portada con resolución suficiente
/// para el tamaño real del widget, en lugar de escalar la miniatura de 300 px.
class PortadaAncha extends StatelessWidget {
  const PortadaAncha({super.key, required this.contenido, this.radio = 0});

  final Contenido contenido;
  final double radio;

  static const _anchosDisponibles = [800, 1600, 2400, 3200];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final anchoLogico = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final resolucion = _resolucionPara(
          anchoLogico * MediaQuery.devicePixelRatioOf(context),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(radio),
          child: Image.network(
            contenido.portadaAncha(resolucion),
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              }
              return const ColoredBox(
                color: Color(0xFF1A1A22),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF24242E), Color(0xFF14141A)],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.movie_outlined,
                  size: 48,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static int _resolucionPara(double anchoFisico) {
    for (final ancho in _anchosDisponibles) {
      if (ancho >= anchoFisico) {
        return ancho;
      }
    }
    return _anchosDisponibles.last;
  }
}
