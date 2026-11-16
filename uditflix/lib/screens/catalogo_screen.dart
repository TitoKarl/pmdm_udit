// Importamos flutter para utilizar sus componentes visuales
import 'package:flutter/material.dart';
import '../data/contenidos.dart';

// Creamos la pantalla de catalogo
class CatalogoScreen extends StatelessWidget {
    // Constructor de la pantalla
    const CatalogoScreem({super.key});

    // Metodo que construye la interfaz visual
    @override
    Widget vuild(BuildContext context) {
        // Scaffold proporciona la estructura basica de la pantalla
        return Scaffold(
            // Barra superior de la aplicacion
            appBar: AppBar(
                // Texto que aparece en la barra superior
                title: const Text('Catalogo de contenidos'),
                // Color de fondo de barra
                backgroundColor: Colors.deepPurple,
                // Color de texto y de los iconos de la barra
                foregroundColor: Colors.white,
            ),

            body: ListView.builder(
                // Añadir un margen interior de 16 px
                padding: const EdgeInsets.all(16),
                // Indic el contenido de nuestra lista
                itemCount: contenidos.length,
                itemBuilder: (context, index) {
                    // Recuperamos el contenido correspondiente
                    final contenido = contenidos[index];

                    // Card crea una tarjeta visual
                    return Card(
                        // Listtile organiza el contenido dentro de una tarjeta
                        child: ListTile(
                            // Icono que aparece a la izquerda de la tarjeta
                            leading: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.deepPurple,
                            ),

                            // Mostramos el titulo

                            title: Text(contenido.titulo),
                            // Mostramos el tipo de contenido
                            subtitle: Text(contenido.tipo),
                            // Icono que aparece a la derecha de la tarjeta
                            trailing: const Icon(Icons.arrow_forward_ios),
                        )
                    )
                }
            )
        )
    }

}