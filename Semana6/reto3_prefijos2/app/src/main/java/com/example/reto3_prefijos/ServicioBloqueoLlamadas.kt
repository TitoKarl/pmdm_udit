package com.example.reto3_prefijos

import android.telecom.Call
import android.telecom.CallScreeningService

class ServicioBloqueoLlamadas : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        if (callDetails.callDirection != Call.Details.DIRECTION_INCOMING) {
            return
        }

        val numero = callDetails.handle?.schemeSpecificPart

        if (numero.isNullOrBlank()) {
            respondToCall(
                callDetails,
                CallResponse.Builder().build()
            )
            return
        }

        val db = BaseDatos(applicationContext)

        val bloquear = try {
            db.debeBloquear(numero)
        } catch (_: Exception) {
            false
        } finally {
            db.close()
        }

        val respuesta = CallResponse.Builder()
            .setDisallowCall(bloquear)
            .setRejectCall(bloquear)
            .setSkipCallLog(false)
            .setSkipNotification(false)
            .build()

        respondToCall(callDetails, respuesta)
    }
}