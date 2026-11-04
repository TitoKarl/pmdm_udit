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
    required this.portada,
    required this.anio,
    required this.generos,
    required this.tipo,
    required this.duracionMinutos,
    required this.valoracion,
    this.temporadas = 1,
  });

  final String id;
  final String titulo;
  final String sinopsis;
  final String portada;
  final int anio;
  final List<String> generos;
  final TipoContenido tipo;

  /// Duración total para películas y duración por episodio para series.
  final int duracionMinutos;

  /// Valoración sobre 10.
  final double valoracion;

  final int temporadas;

  bool get esSerie => tipo == TipoContenido.serie;

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
