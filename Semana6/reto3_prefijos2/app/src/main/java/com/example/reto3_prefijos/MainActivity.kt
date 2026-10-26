// PRE BLOCKER
// Dashboard de llamadas con graficos y simulador de llamadas.

// SPAM: 400, 800, 900
// SOSPECHOSO: 6, 91, 7, 93
// PERMITIDO: 34

// IMPORTANTE: CREAC FICHERO TEXT
package com.example.reto3_prefijos

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.CallLog
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import com.example.reto3_prefijos.ui.theme.BordeMorado
import com.example.reto3_prefijos.ui.theme.DesconocidoGris
import com.example.reto3_prefijos.ui.theme.MoradoClaro
import com.example.reto3_prefijos.ui.theme.MoradoOscuro
import com.example.reto3_prefijos.ui.theme.MoradoPrincipal
import com.example.reto3_prefijos.ui.theme.MoradoProfundo
import com.example.reto3_prefijos.ui.theme.NegroElevada
import com.example.reto3_prefijos.ui.theme.NegroSuperficie
import com.example.reto3_prefijos.ui.theme.PermitidoVerde
import com.example.reto3_prefijos.ui.theme.PreBlockerTheme
import com.example.reto3_prefijos.ui.theme.SospechosoAmbar
import com.example.reto3_prefijos.ui.theme.SpamRojo
import com.example.reto3_prefijos.ui.theme.TextoPrincipal
import com.example.reto3_prefijos.ui.theme.TextoSecundario
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class Llamada(
    val numero: String,
    val prefijo: String,
    val tipo: String,
    val fecha: String,
    val bloqueada: Boolean,
    val simulada: Boolean = false
)

private val tiposLlamada = listOf(
    "SPAM",
    "SOSPECHOSO",
    "PERMITIDO",
    "DESCONOCIDO"
)

private val tiposSimulables = listOf(
    "PERMITIDO",
    "SOSPECHOSO",
    "SPAM",
    "DESCONOCIDO"
)

private fun colorParaTipo(tipo: String): Color = when (tipo) {
    "SPAM" -> SpamRojo
    "SOSPECHOSO" -> SospechosoAmbar
    "PERMITIDO" -> PermitidoVerde
    else -> DesconocidoGris
}

private fun numeroSimulado(tipo: String): String = when (tipo) {
    "SPAM" -> listOf("400123456", "800987654", "900111222").random()
    "SOSPECHOSO" -> listOf("612345678", "711222333", "913456789", "934444555").random()
    "PERMITIDO" -> listOf("+34612345678", "+34687654321", "+34912345678").random()
    else -> listOf("123456789", "555000111", "222333444").random()
}

class MainActivity : ComponentActivity() {

    private fun obtenerLlamadas(): List<Llamada> {
        val llamadas = mutableListOf<Llamada>()

        // Las llamadas bloqueadas o rechazadas no se guardan como INCOMING_TYPE:
        // el servicio de filtrado las registra como BLOCKED_TYPE o REJECTED_TYPE.
        // Hay que incluir todos los tipos para no perder llamadas en el contador.
        val tiposRegistrados = arrayOf(
            CallLog.Calls.INCOMING_TYPE,
            CallLog.Calls.MISSED_TYPE,
            CallLog.Calls.REJECTED_TYPE,
            CallLog.Calls.BLOCKED_TYPE
        )

        val cursor = contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            arrayOf(
                CallLog.Calls.NUMBER,
                CallLog.Calls.DATE,
                CallLog.Calls.TYPE
            ),
            "${CallLog.Calls.TYPE} IN (?, ?, ?, ?)",
            tiposRegistrados.map { it.toString() }.toTypedArray(),
            "${CallLog.Calls.DATE} DESC"
        )

        cursor?.use {
            val columnaNumero = it.getColumnIndex(CallLog.Calls.NUMBER)
            val columnaFecha = it.getColumnIndex(CallLog.Calls.DATE)
            val columnaTipo = it.getColumnIndex(CallLog.Calls.TYPE)

            while (it.moveToNext()) {
                val numero = it.getString(columnaNumero) ?: "Desconocido"
                val fechaMillis = it.getLong(columnaFecha)
                val tipoRegistro = it.getInt(columnaTipo)

                val fecha = SimpleDateFormat(
                    "dd/MM/yyyy HH:mm",
                    Locale.getDefault()
                ).format(Date(fechaMillis))

                val (prefijo, tipo) = clasificarNumero(numero)

                llamadas.add(
                    Llamada(
                        numero = numero,
                        prefijo = prefijo,
                        tipo = tipo,
                        fecha = fecha,
                        bloqueada = tipoRegistro == CallLog.Calls.BLOCKED_TYPE ||
                            tipoRegistro == CallLog.Calls.REJECTED_TYPE
                    )
                )
            }
        }

        return llamadas
    }

    private fun clasificarNumero(numero: String): Pair<String, String> {
        var limpio = numero.filter { it.isDigit() }

        // Normalizar el prefijo internacional de España.
        if (limpio.startsWith("0034")) {
            limpio = limpio.removePrefix("0034")
        } else if (limpio.startsWith("34") && limpio.length > 9) {
            return Pair("34", "PERMITIDO")
        }

        return when {
            limpio.startsWith("400") -> Pair("400", "SPAM")
            limpio.startsWith("800") -> Pair("800", "SPAM")
            limpio.startsWith("900") -> Pair("900", "SPAM")
            limpio.startsWith("91") -> Pair("91", "SOSPECHOSO")
            limpio.startsWith("93") -> Pair("93", "SOSPECHOSO")
            limpio.startsWith("6") -> Pair("6", "SOSPECHOSO")
            limpio.startsWith("7") -> Pair("7", "SOSPECHOSO")
            else -> Pair("Sin identificar", "DESCONOCIDO")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            PreBlockerTheme {
                var llamadas by remember {
                    mutableStateOf(emptyList<Llamada>())
                }
                var simuladas by remember {
                    mutableStateOf(emptyList<Llamada>())
                }
                var filtroTipo by remember {
                    mutableStateOf("TODAS")
                }
                var mensaje by remember {
                    mutableStateOf("Concede permiso para consultar las llamadas.")
                }
                var permisoConcedido by remember {
                    mutableStateOf(false)
                }
                var mostrarDialogo by remember {
                    mutableStateOf(false)
                }
                var tipoPendiente by remember {
                    mutableStateOf<String?>(null)
                }

                fun anadirSimulada(tipo: String, numero: String) {
                    val (prefijo, _) = clasificarNumero(numero)

                    simuladas = listOf(
                        Llamada(
                            numero = numero,
                            prefijo = prefijo,
                            tipo = tipo,
                            fecha = SimpleDateFormat(
                                "dd/MM/yyyy HH:mm",
                                Locale.getDefault()
                            ).format(Date()),
                            bloqueada = tipo == "SPAM",
                            simulada = true
                        )
                    ) + simuladas
                }

                // Marca de verdad el numero y deja constancia en el dashboard.
                fun realizarLlamadaReal(tipo: String) {
                    val numero = numeroSimulado(tipo)
                    anadirSimulada(tipo, numero)

                    val intent = Intent(
                        Intent.ACTION_CALL,
                        Uri.fromParts("tel", numero, null)
                    )

                    try {
                        startActivity(intent)
                        mensaje = "Llamada real iniciada: $tipo ($numero)."
                    } catch (e: Exception) {
                        mensaje = "No se pudo iniciar la llamada: ${e.message}"
                    }
                }

                val permisoLauncher = rememberLauncherForActivityResult(
                    ActivityResultContracts.RequestPermission()
                ) { concedido ->
                    permisoConcedido = concedido
                    if (concedido) {
                        llamadas = obtenerLlamadas()
                        mensaje = "Historial actualizado."
                    } else {
                        mensaje = "Necesitas permitir el acceso al registro de llamadas."
                    }
                }

                val llamadaLauncher = rememberLauncherForActivityResult(
                    ActivityResultContracts.RequestPermission()
                ) { concedido ->
                    val tipo = tipoPendiente
                    tipoPendiente = null

                    if (tipo != null) {
                        if (concedido) {
                            realizarLlamadaReal(tipo)
                        } else {
                            val numero = numeroSimulado(tipo)
                            anadirSimulada(tipo, numero)
                            mensaje = "Sin permiso para llamar: $tipo solo en el dashboard."
                        }
                    }
                }

                fun actualizarLlamadas() {
                    val concedido = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_CALL_LOG
                    ) == PackageManager.PERMISSION_GRANTED

                    permisoConcedido = concedido

                    if (concedido) {
                        llamadas = obtenerLlamadas()
                        mensaje = "Historial actualizado."
                    } else {
                        permisoLauncher.launch(Manifest.permission.READ_CALL_LOG)
                    }
                }

                LaunchedEffect(Unit) {
                    actualizarLlamadas()
                }

                // El registro de llamadas se actualiza en segundo plano cuando
                // termina una llamada. Escuchamos ese cambio para que el
                // contador no se quede con el valor de la primera llamada.
                //
                // Solo se registra cuando ya hay permiso: registrar el
                // observador sin READ_CALL_LOG lanza SecurityException y
                // cierra la app antes de poder pedir el permiso.
                DisposableEffect(permisoConcedido) {
                    if (!permisoConcedido) {
                        return@DisposableEffect onDispose { }
                    }

                    val observador = object : ContentObserver(
                        Handler(Looper.getMainLooper())
                    ) {
                        override fun onChange(selfChange: Boolean) {
                            val concedido = ContextCompat.checkSelfPermission(
                                this@MainActivity,
                                Manifest.permission.READ_CALL_LOG
                            ) == PackageManager.PERMISSION_GRANTED

                            if (concedido) {
                                llamadas = obtenerLlamadas()
                                mensaje = "Historial actualizado."
                            }
                        }
                    }

                    try {
                        contentResolver.registerContentObserver(
                            CallLog.Calls.CONTENT_URI,
                            true,
                            observador
                        )
                    } catch (_: SecurityException) {
                        // El permiso se ha revocado: no hay nada que observar.
                    }

                    onDispose {
                        try {
                            contentResolver.unregisterContentObserver(observador)
                        } catch (_: SecurityException) {
                            // Sin permiso no se puede desregistrar; no pasa nada.
                        }
                    }
                }

                // Las simuladas van delante porque son las mas recientes.
                val todas = simuladas + llamadas
                val filtradas = if (filtroTipo == "TODAS") {
                    todas
                } else {
                    todas.filter { it.tipo == filtroTipo }
                }
                val bloqueadas = todas.count { it.bloqueada }

                DashboardLlamadas(
                    llamadas = filtradas,
                    total = todas.size,
                    bloqueadas = bloqueadas,
                    filtroTipo = filtroTipo,
                    onFiltro = { filtroTipo = it },
                    mensaje = mensaje,
                    onActualizar = { actualizarLlamadas() },
                    onSimular = { mostrarDialogo = true }
                )

                if (mostrarDialogo) {
                    DialogoSimularLlamada(
                        onDismiss = { mostrarDialogo = false },
                        onElegir = { tipo ->
                            mostrarDialogo = false

                            val puedeLlamar = ContextCompat.checkSelfPermission(
                                this,
                                Manifest.permission.CALL_PHONE
                            ) == PackageManager.PERMISSION_GRANTED

                            if (puedeLlamar) {
                                realizarLlamadaReal(tipo)
                            } else {
                                tipoPendiente = tipo
                                llamadaLauncher.launch(Manifest.permission.CALL_PHONE)
                            }
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun DashboardLlamadas(
    llamadas: List<Llamada>,
    total: Int,
    bloqueadas: Int,
    filtroTipo: String,
    onFiltro: (String) -> Unit,
    mensaje: String,
    onActualizar: () -> Unit,
    onSimular: () -> Unit
) {
    val contadores = llamadas.groupingBy { it.tipo }.eachCount()
    val resumen = tiposLlamada.map { it to (contadores[it] ?: 0) }
    val porPrefijo = llamadas
        .groupingBy { it.prefijo }
        .eachCount()
        .entries
        .sortedByDescending { it.value }
        .take(4)
    val recientes = llamadas.take(5)

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item {
                CabeceraPreBlocker()
            }

            item {
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    TarjetaKpi(
                        titulo = "Llamadas",
                        valor = total.toString(),
                        modifier = Modifier.weight(1f)
                    )
                    TarjetaKpi(
                        titulo = "Bloqueadas",
                        valor = bloqueadas.toString(),
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            item {
                SelectorFiltro(
                    filtroTipo = filtroTipo,
                    onFiltro = onFiltro,
                    mostrando = llamadas.size,
                    total = total
                )
            }

            item {
                TarjetaDashboard {
                    Text(
                        text = "Distribución por tipo",
                        style = MaterialTheme.typography.titleMedium,
                        color = TextoPrincipal
                    )
                    Spacer(modifier = Modifier.height(12.dp))

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        GraficoDonut(
                            resumen = resumen,
                            total = llamadas.size,
                            modifier = Modifier.size(120.dp)
                        )

                        Spacer(modifier = Modifier.width(16.dp))

                        Column(
                            modifier = Modifier.weight(1f),
                            verticalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            resumen.forEach { (tipo, cantidad) ->
                                LeyendaTipo(
                                    tipo = tipo,
                                    cantidad = cantidad,
                                    total = llamadas.size
                                )
                            }
                        }
                    }
                }
            }

            if (porPrefijo.isNotEmpty()) {
                item {
                    TarjetaDashboard {
                        Text(
                            text = "Llamadas por prefijo",
                            style = MaterialTheme.typography.titleMedium,
                            color = TextoPrincipal
                        )
                        Spacer(modifier = Modifier.height(12.dp))

                        porPrefijo.forEach { entrada ->
                            BarraPrefijo(
                                prefijo = entrada.key,
                                cantidad = entrada.value,
                                maximo = porPrefijo.first().value
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                        }
                    }
                }
            }

            item {
                Button(
                    onClick = onSimular,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .background(
                            Brush.horizontalGradient(
                                listOf(MoradoPrincipal, MoradoOscuro)
                            ),
                            RoundedCornerShape(26.dp)
                        ),
                    shape = RoundedCornerShape(26.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = Color.Transparent
                    ),
                    elevation = ButtonDefaults.buttonElevation(0.dp)
                ) {
                    Text(
                        text = "Simular llamada",
                        color = Color.White,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            item {
                OutlinedButton(
                    onClick = onActualizar,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp),
                    border = BorderStroke(1.dp, MoradoPrincipal),
                    shape = RoundedCornerShape(24.dp)
                ) {
                    Text(
                        text = "Actualizar llamadas",
                        color = MoradoClaro
                    )
                }
            }

            item {
                Text(
                    text = mensaje,
                    style = MaterialTheme.typography.bodySmall,
                    color = TextoSecundario
                )
            }

            item {
                Text(
                    text = "Últimas llamadas",
                    style = MaterialTheme.typography.titleMedium,
                    color = TextoPrincipal
                )
            }

            if (recientes.isEmpty()) {
                item {
                    Text(
                        text = if (total == 0) {
                            "No hay llamadas registradas."
                        } else {
                            "No hay llamadas de tipo $filtroTipo."
                        },
                        style = MaterialTheme.typography.bodySmall,
                        color = TextoSecundario
                    )
                }
            } else {
                items(recientes) { llamada ->
                    FilaLlamada(llamada)
                }

                if (llamadas.size > recientes.size) {
                    item {
                        Text(
                            text = "... y ${llamadas.size - recientes.size} llamadas más " +
                                "resumidas en los gráficos.",
                            style = MaterialTheme.typography.bodySmall,
                            color = TextoSecundario
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun CabeceraPreBlocker() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(
                Brush.linearGradient(
                    listOf(MoradoOscuro, MoradoPrincipal, MoradoProfundo)
                )
            )
            .padding(20.dp)
    ) {
        Column {
            Text(
                text = "PRE BLOCKER",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
            Text(
                text = "Dashboard de llamadas",
                style = MaterialTheme.typography.bodyMedium,
                color = Color(0xFFE9E1FF)
            )
        }
    }
}

@Composable
private fun TarjetaKpi(
    titulo: String,
    valor: String,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .clip(RoundedCornerShape(18.dp))
            .background(
                Brush.verticalGradient(
                    listOf(NegroElevada, NegroSuperficie)
                )
            )
            .padding(14.dp)
    ) {
        Text(
            text = titulo,
            style = MaterialTheme.typography.labelMedium,
            color = TextoSecundario
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = valor,
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = MoradoClaro
        )
    }
}

@Composable
private fun SelectorFiltro(
    filtroTipo: String,
    onFiltro: (String) -> Unit,
    mostrando: Int,
    total: Int
) {
    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        FlowRow(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            ChipFiltro(
                texto = "Todas",
                tipo = "TODAS",
                filtroActual = filtroTipo,
                onClick = onFiltro
            )

            tiposLlamada.forEach { tipo ->
                ChipFiltro(
                    texto = tipo,
                    tipo = tipo,
                    filtroActual = filtroTipo,
                    onClick = onFiltro
                )
            }
        }

        Text(
            text = "Mostrando $mostrando de $total",
            style = MaterialTheme.typography.bodySmall,
            color = TextoSecundario
        )
    }
}

@Composable
private fun ChipFiltro(
    texto: String,
    tipo: String,
    filtroActual: String,
    onClick: (String) -> Unit
) {
    FilterChip(
        selected = filtroActual == tipo,
        onClick = { onClick(tipo) },
        label = { Text(texto) },
        leadingIcon = {
            Box(
                modifier = Modifier
                    .size(10.dp)
                    .background(colorParaTipo(tipo), CircleShape)
            )
        },
        colors = FilterChipDefaults.filterChipColors(
            containerColor = NegroSuperficie,
            labelColor = TextoSecundario,
            iconColor = TextoSecundario,
            selectedContainerColor = MoradoProfundo,
            selectedLabelColor = Color.White,
            selectedLeadingIconColor = Color.White
        )
    )
}

@Composable
private fun TarjetaDashboard(
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(20.dp))
            .background(NegroSuperficie)
            .border(1.dp, BordeMorado, RoundedCornerShape(20.dp))
            .padding(16.dp),
        content = content
    )
}

@Composable
private fun GraficoDonut(
    resumen: List<Pair<String, Int>>,
    total: Int,
    modifier: Modifier = Modifier
) {
    Box(modifier = modifier, contentAlignment = Alignment.Center) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val grosor = 20.dp.toPx()

            if (total == 0) {
                drawArc(
                    color = Color(0xFF2A2A2E),
                    startAngle = 0f,
                    sweepAngle = 360f,
                    useCenter = false,
                    style = Stroke(width = grosor)
                )
            } else {
                var inicio = -90f

                resumen.forEach { (tipo, cantidad) ->
                    if (cantidad > 0) {
                        val barrido = cantidad.toFloat() / total * 360f

                        drawArc(
                            color = colorParaTipo(tipo),
                            startAngle = inicio + 2f,
                            sweepAngle = (barrido - 4f).coerceAtLeast(2f),
                            useCenter = false,
                            style = Stroke(
                                width = grosor,
                                cap = StrokeCap.Round
                            )
                        )

                        inicio += barrido
                    }
                }
            }
        }

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = total.toString(),
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                color = TextoPrincipal
            )
            Text(
                text = "llamadas",
                style = MaterialTheme.typography.labelSmall,
                color = TextoSecundario
            )
        }
    }
}

@Composable
private fun LeyendaTipo(
    tipo: String,
    cantidad: Int,
    total: Int
) {
    val porcentaje = if (total == 0) 0 else cantidad * 100 / total

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(10.dp)
                .background(colorParaTipo(tipo), CircleShape)
        )

        Spacer(modifier = Modifier.width(8.dp))

        Text(
            text = tipo,
            style = MaterialTheme.typography.bodySmall,
            color = TextoPrincipal,
            modifier = Modifier.weight(1f)
        )

        Text(
            text = "$cantidad · $porcentaje%",
            style = MaterialTheme.typography.bodySmall,
            color = TextoSecundario
        )
    }
}

@Composable
private fun BarraPrefijo(
    prefijo: String,
    cantidad: Int,
    maximo: Int
) {
    val fraccion = if (maximo == 0) 0f else cantidad.toFloat() / maximo

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = prefijo,
            style = MaterialTheme.typography.bodySmall,
            color = TextoSecundario,
            modifier = Modifier.width(96.dp)
        )

        Box(
            modifier = Modifier
                .weight(1f)
                .height(10.dp)
                .clip(RoundedCornerShape(5.dp))
                .background(NegroElevada)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxHeight()
                    .fillMaxWidth(fraccion)
                    .clip(RoundedCornerShape(5.dp))
                    .background(
                        Brush.horizontalGradient(
                            listOf(MoradoPrincipal, MoradoOscuro)
                        )
                    )
            )
        }

        Spacer(modifier = Modifier.width(10.dp))

        Text(
            text = cantidad.toString(),
            style = MaterialTheme.typography.bodySmall,
            color = TextoPrincipal
        )
    }
}

@Composable
private fun FilaLlamada(llamada: Llamada) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(NegroSuperficie)
            .padding(12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(10.dp)
                .background(colorParaTipo(llamada.tipo), CircleShape)
        )

        Spacer(modifier = Modifier.width(10.dp))

        Column(modifier = Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = llamada.numero,
                    style = MaterialTheme.typography.titleSmall,
                    color = TextoPrincipal
                )

                if (llamada.simulada) {
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "simulada",
                        style = MaterialTheme.typography.labelSmall,
                        color = MoradoClaro
                    )
                }
            }

            Text(
                text = "Prefijo ${llamada.prefijo} · ${llamada.fecha}",
                style = MaterialTheme.typography.bodySmall,
                color = TextoSecundario
            )
        }

        Text(
            text = llamada.tipo,
            style = MaterialTheme.typography.labelSmall,
            color = colorParaTipo(llamada.tipo),
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
private fun DialogoSimularLlamada(
    onDismiss: () -> Unit,
    onElegir: (String) -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = NegroElevada,
        title = {
            Text(
                text = "Simular llamada",
                color = TextoPrincipal,
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text(
                    text = "Elige el tipo de llamada. Se marcará el número de verdad: " +
                        "el móvil hará una llamada saliente real y, además, " +
                        "la verás en el dashboard.",
                    style = MaterialTheme.typography.bodySmall,
                    color = SospechosoAmbar
                )

                tiposSimulables.forEach { tipo ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(12.dp))
                            .background(NegroSuperficie)
                            .clickable { onElegir(tipo) }
                            .padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(12.dp)
                                .background(colorParaTipo(tipo), CircleShape)
                        )

                        Spacer(modifier = Modifier.width(12.dp))

                        Text(
                            text = tipo,
                            color = colorParaTipo(tipo),
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text(text = "Cancelar", color = MoradoClaro)
            }
        }
    )
}
