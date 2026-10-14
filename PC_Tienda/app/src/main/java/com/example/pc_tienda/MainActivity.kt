
package com.example.pc_tienda

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.pc_tienda.ui.theme.PC_TiendaTheme
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            PC_TiendaTheme {
                Surface(
                    modifier = Modifier.fillMaxSize()
                ) {
                    PantallaPrincipal()
                }
            }
        }
    }
}

data class Producto(
    val nombre: String,
    val precio: String,
    val imagenResId: Int,
    val enlace: String
)

val catalogoPc = listOf(
    Producto(
        "PcCom Ready AMD Ryzen 7",
        "1.339 €",
        R.drawable.pc_1,
        "https://www.pccomponentes.com/pccom-ready-amd-ryzen-7-5700x-32gb-1tb-ssd-rtx-5060-windows-11-home"
    ),
    Producto(
        "PcCom Imperial AMD Ryzen 7",
        "2.469 €",
        R.drawable.pc_2,
        "https://www.pccomponentes.com/pccom-imperial-amd-ryzen-7-9800x3d-32gb-1tb-ssd-rtx-5070-v2-windows-11-home"
    ),
    Producto(
        "PcCom Custom Core 9",
        "6.299 €",
        R.drawable.pc_3,
        "https://www.pccomponentes.com/pccom-custom-core-ultra-9-285ia-64gb-4tb-ssd-rtx-5080-windows-11-pro"
    ),
    Producto(
        "PcCom Work Intel Core i5",
        "789 €",
        R.drawable.pc_4,
        "https://www.pccomponentes.com/pccom-work-intel-core-i5-12400-16gb-500gb-ssd-v2-w11-home-plus-teclado-plus-raton-plus-monitor-24-fhd"
    ),
    Producto(
        "PcCom Ultimate Intel Core Ultra 9",
        "5.472 €",
        R.drawable.pc_5,
        "https://www.pccomponentes.com/pccom-ultimate-intel-core-ultra-9-285k-64gb-2tb-ssd-rtx-5080-windows-11-pro-house-pride-gryfindor"
    )
)

@Composable
fun CatalogoPc(productos: List<Producto>) {
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = 250.dp),
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(productos) { producto ->
            TarjetaProducto(producto)
        }
    }
}

@Composable
fun TarjetaProducto(producto: Producto) {
    val contexto = LocalContext.current

    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column {
            Image(
                painter = painterResource(
                    id = producto.imagenResId
                ),
                contentDescription = producto.nombre,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp),
                contentScale = ContentScale.Fit
            )

            Column(
                modifier = Modifier.padding(12.dp)
            ) {
                Text(
                    text = producto.nombre,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(
                    modifier = Modifier.height(8.dp)
                )

                Text(
                    text = producto.precio,
                    fontSize = 16.sp,
                    color = MaterialTheme.colorScheme.primary
                )

                Spacer(
                    modifier = Modifier.height(12.dp)
                )

                Button(
                    onClick = {
                        val intent = Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse(producto.enlace)
                        )
                        contexto.startActivity(intent)
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Ver detalles")
                }
            }
        }
    }
}

@Composable
fun PantallaPrincipal() {
    var mostrarPortada by remember {
        mutableStateOf(true)
    }

    LaunchedEffect(Unit) {
        delay(1500)
        mostrarPortada = false
    }

    if (mostrarPortada) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "Detalles PC",
                fontSize = 32.sp,
                fontWeight = FontWeight.Bold
            )
        }
    } else {
        CatalogoPc(productos = catalogoPc)
    }
}