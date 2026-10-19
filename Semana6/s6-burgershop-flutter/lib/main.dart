import 'package:flutter/material.dart';

// main(): el punto de arranque de CUALQUIER app Flutter.
// Siempre existe, un runApp() = onCreate() en Kotlin
void main () {
  runApp(const BurgerShopApp());
}

//APP RAIZ

class BurgerShoppApp extends StatelessWidget {


// const + super.key: es nuestro constructor - Flutter pide siempre este comando
  const BurgerShoppApp({super.key});

//build(): el metodo que TODO widget debe tener.
//Aqui es donde dibujas TODO lo que ve en la pantalla

@override
  Widget build(BuildContext context) {
  // MaterialApp: el "contenedor raiz" de toda la app
  return MaterialApp(
    debugShowCheckedModeBanner: false, // quitala cinta roja
    title: 'BurgerShop',
    theme: ThemeData(
      // COLOR DE LA APP: esta es la unica linea para cambiar el aspecto
      colorScheme: Colors.deepOrange,
      useMaterial3: true,



    ),
    home: const PantallaCatalogo(),// La primerapantalla ve al abrir el app
  );

 }

}

//MODELO DE DATOS
//En Dart no existe "data class" como en Kotlin: una clase normal
//con un constructor que recibe los campos para hacer el mismo trbajo

class Producto {
  // final: ese valor no cambia una vez creado el objeto
  final String nombre;
  final String precio; // Al modificar a carrod e compras modificamos la variable
  final String imagenAsset;

  // Constructor: "requierd" oblida a pasar siempre estos tres datos
  //  al crear un producto
Producto({
    required this.nombre,
    required this.imagenAsset,
    required this.precio
});
}

// DATOS DE PRUEBA
// Los mismos productos en kotlin, apuntando a los mismos Archivos
// final List<roducto> = una llista que no se puede reasgnar,pero el contenido si
// prodriamos modificar

final List<Producto> catalogoHambuerguesa = [
  Producto(
      nombre: 'Clasica con queso',
      precio: '6.50€',
      imagenAsset: '../assets/images/burger_clasica.jpg'
  ),
  Producto(
      nombre: 'BBQ Bacon',
      precio: '7.90€',
      imagenAsset: '../assets/images/burger_bbq.jpg'
  ),
  Producto(
      nombre: 'Doble Carne',
      precio: '8.50€',
      imagenAsset: '../assets/images/burger_doble.jpg'
  ),
  Producto(
      nombre: 'Clasica vegetariana',
      precio: '7.20€',
      imagenAsset: '../assets/images/burger_vegetariana.jpg'
  ),
  Producto(
      nombre: 'Picante Jalapeño',
      precio: '7.980€',
      imagenAsset: '../assets/images/burger_picante.jpg'
  ),
  Producto(
      nombre: 'Pollo crispy',
      precio: '6.90€',
      imagenAsset: '../assets/images/burger_pollo.jpg'
  ),
];

//PANTALLA 1: CATALOGO RESPONSIVE (RETO 2)

class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({super.key});
  @override
  Widget build(BuildContext context){
    //Scafold: La estructura standar de una pantalla Andoird/IOS
    return Scaffold(
      appBar: AppBar(title: const Text('🍔 BurgerShop')),

      // LayoutBuilder: nos da el ANCHO de la pantalla
      body: LayoutBuilder(
        builder: (context, constraints){
          // Mismo calculo que GridCells.Adaptative(minSize = 250.dp)
          // "cuantas tarjetas de al menos 250 caben en el ancho disponible
          const double anchoMinimo = 250;
          const double espacio = 16; // hueo entre las tarjetas
          final double anchoUtil = constraints.maxWidth - (espacio * 2);
          int columnas = ((anchoUtil + espacio) / (anchoMinimo + espacio)).floor();
          if (columnas < 1) columnas = 1; // minimo 1 columna

          // GridView.builder : Equivalente de LazyVerticaLgrid en compose

          return GridView.builder(
            padding: const EdgeInsets.all(espacio), // margen alrededor de la regilla
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas, // movil vertical 1; horizontal 3
              mainAxisSpacing: espacio, // hueco vertical entre tarjetas
              crossAxisSpacing: espacio, // hueco horizontal entre columnas



              mainAxisExtent: 340,
            ),
            itemCount: catalogoHambuerguesa.length, //cuantos elementos tiene la lista
            itemBuilder: (context, index){
              final producto = catalogoHambuerguesa[index];
              return TarjetaProducto(producto: producto);
            },
          );
        },
      ),
    );
  }
}