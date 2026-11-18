package com.abdulmanan.eventpass

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.nfc.NfcAdapter
import android.nfc.cardemulation.CardEmulation
import android.provider.Settings
import com.abdulmanan.eventpass.nfc.TicketEmulation
import com.abdulmanan.eventpass.nfc.TicketHceService
import com.abdulmanan.eventpass.nfc.Type4TagEmulator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the Flutter app and the `eventpass/nfc` channel, which turns ticket
 * emulation (the phone acting as an NFC ticket) on and off.
 */
class MainActivity : FlutterActivity() {
    private var events: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        EventChannel(messenger, "eventpass/nfc/events").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
                events = sink
            }

            override fun onCancel(arguments: Any?) {
                events = null
            }
        })

        MethodChannel(messenger, "eventpass/nfc").setMethodCallHandler { call, result ->
            when (call.method) {
                "isEmulationSupported" -> result.success(
                    NfcAdapter.getDefaultAdapter(this) != null &&
                        packageManager.hasSystemFeature(PackageManager.FEATURE_NFC_HOST_CARD_EMULATION),
                )
                "startEmulation" -> {
                    val message = call.argument<ByteArray>("ndefMessage")
                    if (message == null) {
                        result.error("bad_args", "ndefMessage is required", null)
                    } else {
                        TicketEmulation.emulator = Type4TagEmulator(message) {
                            runOnUiThread { events?.success("read") }
                        }
                        setPreferred(true)
                        result.success(null)
                    }
                }
                "stopEmulation" -> {
                    stopEmulation()
                    result.success(null)
                }
                "openNfcSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                    } catch (_: Exception) {
                        startActivity(Intent(Settings.ACTION_WIRELESS_SETTINGS))
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (TicketEmulation.emulator != null) setPreferred(true)
    }

    override fun onPause() {
        setPreferred(false)
        super.onPause()
    }

    override fun onDestroy() {
        stopEmulation()
        super.onDestroy()
    }

    private fun stopEmulation() {
        TicketEmulation.emulator = null
        setPreferred(false)
    }

    /**
     * A wallet or transit app may also claim the NDEF AID. While the ticket
     * screen is open, ask Android to route taps to EventPass first.
     */
    private fun setPreferred(preferred: Boolean) {
        val adapter = NfcAdapter.getDefaultAdapter(this) ?: return
        if (!packageManager.hasSystemFeature(PackageManager.FEATURE_NFC_HOST_CARD_EMULATION)) return
        try {
            val cardEmulation = CardEmulation.getInstance(adapter)
            if (preferred) {
                cardEmulation.setPreferredService(this, ComponentName(this, TicketHceService::class.java))
            } else {
                cardEmulation.unsetPreferredService(this)
            }
        } catch (_: Exception) {
            // Not fatal: without the preference, Android may ask which app should answer.
        }
    }
}
