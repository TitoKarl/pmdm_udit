package com.example.burgershop

import android.os.Bundle
import android.os.PersistableBundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
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
                  //  CatalogoHamburguesas(catalogoHamburguesa)
                }
            }
        }
    }
}