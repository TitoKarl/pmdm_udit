/// Tipos de contenido disponibles en el catálogo.
enum TipoContenido {
  pelicula('Película'),
  serie('Serie');

  const TipoContenido(this.etiqueta);

  final String etiqueta;
}

/// Representa una película o serie del catálogo de Uditflix.
class Contenido {
  const Contenido({
    required this.id,
    required this.titulo,
    required this.sinopsis,
    required this.semillaImagen,
    required this.anio,
    required this.generos,
    required this.tipo,
    required this.duracionMinutos,
    required this.valoracion,
    this.temporadas = 1,
  });

  static const String _baseImagenes = 'https://picsum.photos/seed';

  final String id;
  final String titulo;
  final String sinopsis;

  /// Semilla de Picsum: permite pedir la misma foto en distintos tamaños.
  final String semillaImagen;

  final int anio;
  final List<String> generos;
  final TipoContenido tipo;

  /// Duración total para películas y duración por episodio para series.
  final int duracionMinutos;

  /// Valoración sobre 10.
  final double valoracion;

  final int temporadas;

  bool get esSerie => tipo == TipoContenido.serie;

  /// Portada vertical y ligera para las tarjetas del catálogo.
  String get portada => '$_baseImagenes/$semillaImagen/300/450';

  /// Versión panorámica de la misma imagen para destacados y cabeceras.
  ///
  /// [ancho] es el ancho deseado en píxeles físicos. Pedir la imagen con
  /// resolución suficiente evita que se vea pixelada al escalarla.
  String portadaAncha(int ancho) {
    final alto = (ancho * 9 / 16).round();
    return '$_baseImagenes/$semillaImagen/$ancho/$alto';
  }

  String get duracionFormateada {
    if (esSerie) {
      return temporadas == 1 ? '1 temporada' : '$temporadas temporadas';
    }

    final horas = duracionMinutos ~/ 60;
    final minutos = duracionMinutos % 60;

    if (horas == 0) {
      return '${minutos}min';
    }
    return '${horas}h ${minutos}min';
  }

  String get generosTexto => generos.join(' · ');
}
