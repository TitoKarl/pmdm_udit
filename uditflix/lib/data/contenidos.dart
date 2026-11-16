// DATOS SIMULADOS DE UDITFLIX

// En esta primera version no tenemos una API ni una base de datos.
// Por eso utilizamos una lis de objetos creada manualmente

// Mas adelante sustituiremos estos datos por informacion
// que recibiremos desde el servidor mediante una API REST

import '../models/contenido.dart';

// Lista de contenidos que aparecen en nuestra aplicacion
// Cada elemento de la lista es un objeto de tipo Contenido.

const List<Contenido> contenidos = [
    Contenido(
        id: 1,
        titulo: 'Introduccion a Flutter',
        descripcion: 'Aprende a crear aplicaciones multiplataforma',
        tipo: 'video',
        duracion: '15 minutos'
    ),
    Contenido(
        id: 2,
        titulo: 'Desarrollo con java',
        descripcion: 'Introduccion a la programacion orientada a objetos',
        tipo: 'video',
        duracion: '25 minutos'
    ),
    Contenido(
        id: 3,
        titulo: 'El mundo de los comics',
        descripcion: 'Una coleccion de historias y aventuras ilustradas',
        tipo: 'comic',
        duracion: '10 paginas'
    ),
    Contenido(
        id: 4,
        titulo: 'Programacion de videojuegos',
        descripcion: 'Descubre los fundamentos de la logica de los videojuegos',
        tipo: 'Juego',
        duracion: '20 minutos'
    ),
];