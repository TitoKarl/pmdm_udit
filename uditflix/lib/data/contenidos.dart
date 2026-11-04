import '../models/contenido.dart';

/// Catálogo de ejemplo de Uditflix.
const List<Contenido> contenidos = [
  Contenido(
    id: 'la-ultima-frontera',
    titulo: 'La Última Frontera',
    sinopsis:
        'Una tripulación perdida despierta a años luz de casa. Sin mapa ni '
        'contacto con la Tierra, deberán decidir si regresar o convertirse en '
        'la primera colonia humana de una galaxia desconocida.',
    portada: 'https://picsum.photos/seed/uditflix-frontera/500/750',
    anio: 2024,
    generos: ['Ciencia ficción', 'Aventura'],
    tipo: TipoContenido.pelicula,
    duracionMinutos: 128,
    valoracion: 8.4,
  ),
  Contenido(
    id: 'sombras-de-madrid',
    titulo: 'Sombras de Madrid',
    sinopsis:
        'Una inspectora recién llegada a Madrid descubre que los casos más '
        'antiguos del archivo policial comparten un mismo sospechoso: alguien '
        'que lleva décadas sin envejecer.',
    portada: 'https://picsum.photos/seed/uditflix-madrid/500/750',
    anio: 2023,
    generos: ['Drama', 'Intriga'],
    tipo: TipoContenido.serie,
    duracionMinutos: 52,
    valoracion: 8.1,
    temporadas: 3,
  ),
  Contenido(
    id: 'codigo-rojo',
    titulo: 'Código Rojo',
    sinopsis:
        'Un especialista en rescates tiene 24 horas para desactivar el sistema '
        'de seguridad de la ciudad antes de que un ataque coordinado deje a '
        'millones de personas incomunicadas.',
    portada: 'https://picsum.photos/seed/uditflix-codigo/500/750',
    anio: 2025,
    generos: ['Acción', 'Thriller'],
    tipo: TipoContenido.pelicula,
    duracionMinutos: 112,
    valoracion: 7.6,
  ),
  Contenido(
    id: 'el-jardin-de-las-horas',
    titulo: 'El Jardín de las Horas',
    sinopsis:
        'En una casa rural donde cada reloj marca una hora distinta, una '
        'familia intenta recomponer su historia mientras el tiempo parece '
        'avanzar en direcciones opuestas.',
    portada: 'https://picsum.photos/seed/uditflix-jardin/500/750',
    anio: 2022,
    generos: ['Misterio', 'Drama'],
    tipo: TipoContenido.serie,
    duracionMinutos: 48,
    valoracion: 8.8,
    temporadas: 2,
  ),
  Contenido(
    id: 'risas-de-medianoche',
    titulo: 'Risas de Medianoche',
    sinopsis:
        'Un cómico en crisis acepta presentar el peor programa de la televisión '
        'local. Lo que empieza como un castigo se convierte en el fenómeno que '
        'nadie vio venir.',
    portada: 'https://picsum.photos/seed/uditflix-risas/500/750',
    anio: 2021,
    generos: ['Comedia'],
    tipo: TipoContenido.pelicula,
    duracionMinutos: 98,
    valoracion: 7.2,
  ),
  Contenido(
    id: 'orbita-7',
    titulo: 'Órbita 7',
    sinopsis:
        'La primera estación espacial comercial de Europa recibe una señal que '
        'no debería existir. La tripulación tiene siete días para averiguar '
        'quién —o qué— la está enviando.',
    portada: 'https://picsum.photos/seed/uditflix-orbita/500/750',
    anio: 2025,
    generos: ['Ciencia ficción', 'Suspense'],
    tipo: TipoContenido.serie,
    duracionMinutos: 45,
    valoracion: 9.0,
    temporadas: 1,
  ),
  Contenido(
    id: 'caminos-de-sal',
    titulo: 'Caminos de Sal',
    sinopsis:
        'Dos hermanos heredan un viejo velero y el diario de su padre. Al '
        'reconstruir el último viaje que nunca terminó, descubren una verdad '
        'que llevaba veinte años esperando en la costa.',
    portada: 'https://picsum.photos/seed/uditflix-sal/500/750',
    anio: 2020,
    generos: ['Drama', 'Aventura'],
    tipo: TipoContenido.pelicula,
    duracionMinutos: 117,
    valoracion: 7.9,
  ),
  Contenido(
    id: 'el-bosque-callado',
    titulo: 'El Bosque Callado',
    sinopsis:
        'Cada invierno, el pueblo de Valdeluz pierde la señal de radio durante '
        'tres días. Este año, la nueva maestra de la escuela decide averiguar '
        'qué ocurre entre los árboles.',
    portada: 'https://picsum.photos/seed/uditflix-bosque/500/750',
    anio: 2024,
    generos: ['Terror', 'Misterio'],
    tipo: TipoContenido.serie,
    duracionMinutos: 50,
    valoracion: 8.3,
    temporadas: 2,
  ),
];
