package com.example.reto3_prefijos.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

// Tema de PRE BLOCKER: negro como color principal y morado
// (de claro a oscuro) como color secundario.
private val EsquemaPreBlocker = darkColorScheme(
    primary = MoradoPrincipal,
    onPrimary = Color.White,
    primaryContainer = MoradoOscuro,
    onPrimaryContainer = Color.White,
    secondary = MoradoClaro,
    onSecondary = Color.Black,
    secondaryContainer = MoradoProfundo,
    onSecondaryContainer = MoradoClaro,
    tertiary = MoradoClaro,
    onTertiary = Color.Black,
    background = NegroFondo,
    onBackground = TextoPrincipal,
    surface = NegroSuperficie,
    onSurface = TextoPrincipal,
    surfaceVariant = NegroElevada,
    onSurfaceVariant = TextoSecundario,
    outline = Color(0xFF3A2A5C),
    error = SpamRojo,
    onError = Color.Black
)

@Composable
fun PreBlockerTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = EsquemaPreBlocker,
        typography = Typography,
        content = content
    )
}
