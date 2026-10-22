// Hacer un aviso que te avisen de cuantas llamadas has recibido y que ten aun boton para
// si quieres te muestre un log con todas las llamadas y sus prefijos y dependiendo del prefijo
// te diga si es spam, un prefijo sospechoso o uno normal

// SPAM: 400, 800, 900
// SOSPECHOSO: 6, 91, 7, 93
// PERMITIDO: 34


// IMPORTANTE: CREAC FICHERO TEXT
package com.example.reto3_prefijos

import android.Manifest
import android.content.pm.PackageManager
import android.database.ContentObserver
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.CallLog
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

data class Llamada(
    val numero: String,
    val prefijo: String,
    val tipo: String,
    val fecha: String,
    val bloqueada: Boolean
)

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
            MaterialTheme {
                var llamadas by remember {
                    mutableStateOf(emptyList<Llamada>())
                }
                var mostrarLog by remember {
                    mutableStateOf(false)
                }
                var mensaje by remember {
                    mutableStateOf("Concede permiso para consultar las llamadas.")
                }

                val permisoLauncher = rememberLauncherForActivityResult(
                    ActivityResultContracts.RequestPermission()
                ) { concedido ->
                    if (concedido) {
                        llamadas = obtenerLlamadas()
                        mensaje = "Historial actualizado."
                    } else {
                        mensaje = "Necesitas permitir el acceso al registro de llamadas."
                    }
                }

                fun actualizarLlamadas() {
                    val concedido = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.READ_CALL_LOG
                    ) == PackageManager.PERMISSION_GRANTED

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
                DisposableEffect(Unit) {
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

                    contentResolver.registerContentObserver(
                        CallLog.Calls.CONTENT_URI,
                        true,
                        observador
                    )

                    onDispose {
                        contentResolver.unregisterContentObserver(observador)
                    }
                }

                val contadores = llamadas.groupingBy { it.tipo }.eachCount()
                val spam = contadores["SPAM"] ?: 0
                val sospechosas = contadores["SOSPECHOSO"] ?: 0
                val permitidas = contadores["PERMITIDO"] ?: 0
                val desconocidas = contadores["DESCONOCIDO"] ?: 0
                val bloqueadas = llamadas.count { it.bloqueada }

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "Control de llamadas",
                            style = MaterialTheme.typography.headlineMedium
                        )

                        Spacer(modifier = Modifier.height(20.dp))

                        Card(modifier = Modifier.fillMaxWidth()) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(20.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text("Llamadas recibidas")
                                Text(
                                    text = llamadas.size.toString(),
                                    style = MaterialTheme.typography.displayLarge
                                )
                                Text(
                                    "Entrantes, perdidas, rechazadas y bloqueadas",
                                    style = MaterialTheme.typography.bodySmall
                                )
                                Text(
                                    text = "$bloqueadas bloqueadas por la app",
                                    style = MaterialTheme.typography.bodySmall
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        Card(modifier = Modifier.fillMaxWidth()) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                verticalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                FilaContador("SPAM", spam, Color(0xFFD32F2F))
                                FilaContador(
                                    "SOSPECHOSO",
                                    sospechosas,
                                    Color(0xFFFF9800)
                                )
                                FilaContador(
                                    "PERMITIDO",
                                    permitidas,
                                    Color(0xFF388E3C)
                                )
                                FilaContador(
                                    "DESCONOCIDO",
                                    desconocidas,
                                    Color.Gray
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        Button(
                            onClick = { actualizarLlamadas() },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("Actualizar llamadas")
                        }

                        Button(
                            onClick = { mostrarLog = !mostrarLog },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                if (mostrarLog) "Ocultar log" else "Ver log de llamadas"
                            )
                        }

                        Spacer(modifier = Modifier.height(8.dp))

                        Text(
                            text = mensaje,
                            style = MaterialTheme.typography.bodySmall
                        )

                        if (mostrarLog) {
                            Spacer(modifier = Modifier.height(12.dp))

                            Text(
                                text = "Registro de llamadas",
                                style = MaterialTheme.typography.titleLarge
                            )

                            Spacer(modifier = Modifier.height(8.dp))

                            LazyColumn(
                                modifier = Modifier.fillMaxWidth(),
                                verticalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                items(llamadas) { llamada ->
                                    val colorTipo = when (llamada.tipo) {
                                        "SPAM" -> Color(0xFFD32F2F)
                                        "SOSPECHOSO" -> Color(0xFFFF9800)
                                        "PERMITIDO" -> Color(0xFF388E3C)
                                        else -> Color.Gray
                                    }

                                    Card(
                                        modifier = Modifier.fillMaxWidth()
                                    ) {
                                        Column(
                                            modifier = Modifier.padding(12.dp)
                                        ) {
                                            Text(
                                                text = "Número: ${llamada.numero}",
                                                style = MaterialTheme.typography.titleMedium
                                            )
                                            Text("Prefijo detectado: ${llamada.prefijo}")
                                            Text("Fecha: ${llamada.fecha}")
                                            Text(
                                                text = "Clasificación: ${llamada.tipo}",
                                                color = colorTipo
                                            )
                                            if (llamada.bloqueada) {
                                                Text(
                                                    text = "Bloqueada por el filtro",
                                                    color = MaterialTheme.colorScheme.error,
                                                    style = MaterialTheme.typography.bodySmall
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun FilaContador(
    nombre: String,
    cantidad: Int,
    color: Color
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(text = nombre, color = color)
        Text(
            text = cantidad.toString(),
            style = MaterialTheme.typography.titleMedium
        )
    }
}
