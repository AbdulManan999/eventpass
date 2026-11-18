package com.abdulmanan.eventpass.nfc

import android.nfc.cardemulation.HostApduService
import android.os.Bundle

/**
 * The ticket currently offered over NFC. Set only while the attendee has the
 * "Tap to check in" screen open; otherwise the phone answers no reader.
 */
object TicketEmulation {
    @Volatile
    var emulator: Type4TagEmulator? = null
}

/**
 * Android routes APDUs for the NDEF Tag Application AID here (see
 * res/xml/ticket_apdu_service.xml), so this phone acts as an NFC ticket.
 */
class TicketHceService : HostApduService() {
    override fun processCommandApdu(commandApdu: ByteArray, extras: Bundle?): ByteArray =
        TicketEmulation.emulator?.process(commandApdu) ?: Type4TagEmulator.SW_FILE_NOT_FOUND

    override fun onDeactivated(reason: Int) {
        TicketEmulation.emulator?.reset()
    }
}
