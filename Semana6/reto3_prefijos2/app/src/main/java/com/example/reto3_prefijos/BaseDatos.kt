package com.example.reto3_prefijos

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

data class Filtro(
    val id: Int,
    val prefijo: String,
    val tipo: String,
    val activo: Boolean
)

class BaseDatos(context: Context) :
    SQLiteOpenHelper(context, "filtros_llamadas.db", null, 1) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE filtros (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                prefijo TEXT NOT NULL UNIQUE,
                tipo TEXT NOT NULL,
                activo INTEGER NOT NULL DEFAULT 1
            )
            """.trimIndent()
        )

        insertarInicial(db, "400", "SPAM")
        insertarInicial(db, "800", "SPAM")
        insertarInicial(db, "900", "SPAM")
        insertarInicial(db, "6", "SOSPECHOSO")
        insertarInicial(db, "91", "SOSPECHOSO")
        insertarInicial(db, "7", "SOSPECHOSO")
        insertarInicial(db, "93", "SOSPECHOSO")
        insertarInicial(db, "34", "PERMITIDO")
    }

    private fun insertarInicial(
        db: SQLiteDatabase,
        prefijo: String,
        tipo: String
    ) {
        val valores = ContentValues().apply {
            put("prefijo", prefijo)
            put("tipo", tipo)
            put("activo", 1)
        }

        db.insert("filtros", null, valores)
    }

    override fun onUpgrade(
        db: SQLiteDatabase,
        oldVersion: Int,
        newVersion: Int
    ) {
    }

    fun obtenerFiltros(): List<Filtro> {
        val lista = mutableListOf<Filtro>()

        readableDatabase.query(
            "filtros",
            arrayOf("id", "prefijo", "tipo", "activo"),
            null,
            null,
            null,
            null,
            "LENGTH(prefijo) DESC, prefijo ASC"
        ).use { cursor ->
            while (cursor.moveToNext()) {
                lista.add(
                    Filtro(
                        id = cursor.getInt(0),
                        prefijo = cursor.getString(1),
                        tipo = cursor.getString(2),
                        activo = cursor.getInt(3) == 1
                    )
                )
            }
        }

        return lista
    }

    fun insertarFiltro(prefijo: String, tipo: String): Boolean {
        if (prefijo.isBlank() || prefijo.any { !it.isDigit() }) {
            return false
        }

        val valores = ContentValues().apply {
            put("prefijo", prefijo)
            put("tipo", tipo)
            put("activo", 1)
        }

        return writableDatabase.insert("filtros", null, valores) != -1L
    }

    fun actualizarFiltro(
        id: Int,
        prefijo: String,
        tipo: String,
        activo: Boolean
    ): Boolean {
        if (prefijo.isBlank() || prefijo.any { !it.isDigit() }) {
            return false
        }

        val valores = ContentValues().apply {
            put("prefijo", prefijo)
            put("tipo", tipo)
            put("activo", if (activo) 1 else 0)
        }

        return writableDatabase.update(
            "filtros",
            valores,
            "id = ?",
            arrayOf(id.toString())
        ) > 0
    }

    fun cambiarEstado(id: Int, activo: Boolean): Boolean {
        val valores = ContentValues().apply {
            put("activo", if (activo) 1 else 0)
        }

        return writableDatabase.update(
            "filtros",
            valores,
            "id = ?",
            arrayOf(id.toString())
        ) > 0
    }

    fun eliminarFiltro(id: Int): Boolean {
        return writableDatabase.delete(
            "filtros",
            "id = ?",
            arrayOf(id.toString())
        ) > 0
    }

    fun clasificarNumero(numero: String): Pair<String, String> {
        var limpio = numero.filter { it.isDigit() }

        if (limpio.startsWith("0034")) {
            limpio = limpio.removePrefix("0034")
        } else if (limpio.startsWith("34") && limpio.length > 9) {
            val filtroEspana = obtenerFiltros()
                .find { it.prefijo == "34" && it.activo }

            if (filtroEspana != null) {
                return Pair(filtroEspana.prefijo, filtroEspana.tipo)
            }
        }

        val filtro = obtenerFiltros()
            .filter { it.activo && it.prefijo != "34" }
            .sortedByDescending { it.prefijo.length }
            .find { limpio.startsWith(it.prefijo) }

        return if (filtro != null) {
            Pair(filtro.prefijo, filtro.tipo)
        } else {
            val filtroEspana = obtenerFiltros()
                .find { it.prefijo == "34" && it.activo }

            if (filtroEspana != null &&
                numero.filter { it.isDigit() }.startsWith("0034")
            ) {
                Pair(filtroEspana.prefijo, filtroEspana.tipo)
            } else {
                Pair("Sin identificar", "DESCONOCIDO")
            }
        }
    }

    fun debeBloquear(numero: String): Boolean {
        var limpio = numero.filter { it.isDigit() }

        if (limpio.startsWith("0034")) {
            limpio = limpio.removePrefix("0034")
        } else if (limpio.startsWith("34") && limpio.length > 9) {
            limpio = limpio.removePrefix("34")
        }

        return obtenerFiltros()
            .filter { it.activo && it.tipo == "SPAM" }
            .sortedByDescending { it.prefijo.length }
            .any { limpio.startsWith(it.prefijo) }
    }
}