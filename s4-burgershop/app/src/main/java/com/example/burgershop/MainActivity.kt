package com.example.burgershop

import android.os.Bundle
import android.os.PersistableBundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.autofill.ContentDataType
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.burgershop.ui.theme.BurgerShopTheme
// ACTIVITY PRINCIPAL
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)

        setContent {
            //MaterialTheme: aplica los colores y
            //tipografias por defecto a todo lo que hay dentro
            MaterialTheme{
                // Surface: el "lienzo" de fondo ocupa la pantalla
                Surface(
                    modifier = Modifier.fillMaxSize()
                ) {
                    CatalogoHamburguesas(catalogoHamburguesas)
                }
            }
        }
    }
}
// MODELO DE DATOS
//EL "modelo" que define que informacion tiene cada producti

data class Producto(
    val nombre : String,
    val precio : String,
    val imanResID : Int // el identificador de la imagen
)

// DATOS DE PRUEBA (Hardcodeados)
// De momento viven aqui mismo, en el codigo. No vienen de ningun servidor
// ni base de datos

val catalogoHamburguesas = listOf(
    Producto(
        "Clasica con queso",
        "6,50 €",
        R.drawable.burger_clasica
    ),
    Producto(
        "BBQ Bacon",
        "7,90 €",
        R.drawable.burger_bbq
    ),
    Producto(
        "Doble carne",
        "8,50 €",
        R.drawable.burger_doble
    ),
    Producto(
        "Vegetariana",
        "7,20 €",
        R.drawable.burger_vegetariana
    ),
    Producto(
        "Picante Jalapeño",
        "7,80 €",
        R.drawable.burger_picante
    ),
    Producto(
        "Pollo Cirspy",
        "6,90 €",
        R.drawable.burger_pollo
    ),
)
// CATALOGO
// LazyColumn: pinta una lista que se puede recorres en scroll
// vertica, solo dibuja en memoria lo que se ve en memoria
// (por eso se llama "lazy", perezoso): es eficiente aunque la lista
// tenga cietos de elementos
@Composable
fun CatalogoHamburguesas(producto: List<Producto>) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        // margen alrededor de toda la lista
        contentPadding = PaddingValues(16.dp),
        // espacio entre una tarjeta y la siguiente
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(producto){ producto ->
            TarjetaProducto(producto)
        }
    }
}

//TARJETA DE PRODUCTO
//Una "caja" (Card) con imagen arriba y datos + boton
@Composable
fun TarjetaProducto(producto: Producto){

    //Card: una superficie elevada, con sombra y borden redondeados
    // por defecto - ideal para agrupar  visualmente la info de un producto

    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        //Column: apial sus elementos de arriba a abajo (flexbox)
        Column {
            Image(
                painter = painterResource(
                    id = producto.imanResID
                ),
                // para accesibilidad (lectores de pantalla)
                contentDescription = producto.nombre,
                modifier = Modifier
                    .fillMaxWidth()// Ocupa todo el ancho de la tarjeta
                    .height(100.dp),
                contentScale = ContentScale.Crop // Recorta la imagen sin deformarse
            )

            // Segunda Column, con margen interior para el texto y el boton
            Column(
                modifier = Modifier.padding(12.dp)
            ) {
                Text(
                    text = producto.nombre,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold
                )

                Spacer(modifier = Modifier.height(4.dp)) // hueco pequeño

                Text(
                    text = producto.precio,
                    fontSize = 16.sp,
                    color = MaterialTheme.colorScheme.primary // color del tema
                )

                Spacer(modifier = Modifier.height(8.dp)) // hueco mediano

                Button(
                    onClick = {
                        //De momento no hace nada
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Añadir al carrito")
                }
            }
        }
    }

}