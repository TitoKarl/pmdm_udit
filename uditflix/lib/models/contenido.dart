// MODELO CONTENIDO

// Esta clase representa un contenido en nuestra platadorma UDITFlix.
// Por ejemplo: una pelicula, un comic o un videojuego.

// En programacion orientada a objetos, una clase define 
// que caracteristicas tendran los objetos.

class Contenido {
    final int id;
    final String titulo;
    final String descripcion;
    // Tipo de contenido: video, comic o juego
    final String tipo;
    final String duracion;
    
    // Constructor: permite crear nuevos Contenido. 

    const Contenido({
        requered this.id,
        requered this.titulo,
        requered this.descripcion,
        requered this.tipo,
        requered this.duracion,
  

    })
}