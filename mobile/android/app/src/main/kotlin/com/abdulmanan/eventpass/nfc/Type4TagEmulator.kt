package com.abdulmanan.eventpass.nfc

/**
 * A read-only NFC Forum Type 4 Tag holding one NDEF message, answered over
 * ISO 7816-4 APDUs. Because the phone looks exactly like an NFC sticker or
 * wristband, the gate scanner reads tickets from phones and from tags with
 * the same code.
 *
 * Reader conversation (NFC Forum Type 4 Tag spec, mapping version 2.0):
 * 1. SELECT the NDEF Tag Application by AID `D2760000850101`.
 * 2. SELECT the Capability Container file (E103) and READ BINARY it.
 * 3. SELECT the NDEF file (E104), READ BINARY its 2-byte length, then the message.
 *
 * Pure Kotlin with no Android dependencies, so it is unit tested on the JVM.
 */
class Type4TagEmulator(ndefMessage: ByteArray, private val onFullyRead: () -> Unit = {}) {
    private enum class File { NONE, CAPABILITY_CONTAINER, NDEF }

    /** The NDEF file: 2-byte big-endian length (NLEN), then the message. */
    private val ndefFile: ByteArray

    private val capabilityContainer: ByteArray

    private var applicationSelected = false
    private var selectedFile = File.NONE
    private var delivered = false

    init {
        require(ndefMessage.size <= MAX_NDEF_SIZE) { "NDEF message too large: ${ndefMessage.size} bytes" }
        ndefFile = u16(ndefMessage.size) + ndefMessage
        capabilityContainer = bytes(0x00, 0x0F) + // CCLEN: 15 bytes
            bytes(0x20) + // mapping version 2.0
            u16(MAX_READ) + // MLe: the most a single READ BINARY returns
            u16(MAX_READ) + // MLc: the most a command may carry (writes are refused anyway)
            bytes(0x04, 0x06) + // NDEF File Control TLV, 6 bytes:
            NDEF_FILE_ID + // file id
            u16(ndefFile.size) + // maximum NDEF file size
            bytes(0x00, 0xFF) // read access granted, write access denied
    }

    /** Handles one command APDU and returns the response APDU (data + status word). */
    fun process(apdu: ByteArray): ByteArray {
        if (apdu.size < 4) return SW_WRONG_LENGTH
        val ins = apdu[1].toInt() and 0xFF
        val p1 = apdu[2].toInt() and 0xFF
        val p2 = apdu[3].toInt() and 0xFF
        return when (ins) {
            INS_SELECT -> select(apdu, p1)
            INS_READ_BINARY -> readBinary(apdu, p1, p2)
            else -> SW_INS_NOT_SUPPORTED
        }
    }

    /** The reader moved away: the next tap starts a new conversation. */
    fun reset() {
        applicationSelected = false
        selectedFile = File.NONE
        delivered = false
    }

    private fun select(apdu: ByteArray, p1: Int): ByteArray {
        val data = commandData(apdu) ?: return SW_WRONG_LENGTH
        return when (p1) {
            0x04 -> if (data.contentEquals(NDEF_AID)) {
                applicationSelected = true
                selectedFile = File.NONE
                delivered = false
                SW_OK
            } else {
                SW_FILE_NOT_FOUND
            }
            0x00 -> when {
                !applicationSelected -> SW_FILE_NOT_FOUND
                data.contentEquals(CC_FILE_ID) -> SW_OK.also { selectedFile = File.CAPABILITY_CONTAINER }
                data.contentEquals(NDEF_FILE_ID) -> SW_OK.also { selectedFile = File.NDEF }
                else -> SW_FILE_NOT_FOUND
            }
            else -> SW_WRONG_P1P2
        }
    }

    private fun readBinary(apdu: ByteArray, p1: Int, p2: Int): ByteArray {
        val file = when (selectedFile) {
            File.CAPABILITY_CONTAINER -> capabilityContainer
            File.NDEF -> ndefFile
            File.NONE -> return SW_NOT_ALLOWED
        }
        val offset = ((p1 and 0x7F) shl 8) or p2
        if (offset > file.size) return SW_WRONG_P1P2
        val le = if (apdu.size >= 5) (apdu[4].toInt() and 0xFF).let { if (it == 0) 256 else it } else 256
        val end = minOf(offset + le, file.size)
        // The last byte of the message went out: the scanner has the ticket.
        if (selectedFile == File.NDEF && end == file.size && end > 2 && !delivered) {
            delivered = true
            onFullyRead()
        }
        return file.copyOfRange(offset, end) + SW_OK
    }

    /** Lc-prefixed data of a command, or null when the lengths don't add up. */
    private fun commandData(apdu: ByteArray): ByteArray? {
        if (apdu.size < 5) return null
        val lc = apdu[4].toInt() and 0xFF
        if (apdu.size < 5 + lc) return null
        return apdu.copyOfRange(5, 5 + lc)
    }

    companion object {
        /** NFC Forum NDEF Tag Application, version 2. */
        val NDEF_AID = bytes(0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01)
        val CC_FILE_ID = bytes(0xE1, 0x03)
        val NDEF_FILE_ID = bytes(0xE1, 0x04)

        /** Bytes per READ BINARY; small enough for every reader's transceive limit. */
        const val MAX_READ = 0x7F
        const val MAX_NDEF_SIZE = 0x7FFF - 2

        private const val INS_SELECT = 0xA4
        private const val INS_READ_BINARY = 0xB0

        val SW_OK = bytes(0x90, 0x00)
        val SW_WRONG_LENGTH = bytes(0x67, 0x00)
        val SW_NOT_ALLOWED = bytes(0x69, 0x86)
        val SW_FILE_NOT_FOUND = bytes(0x6A, 0x82)
        val SW_WRONG_P1P2 = bytes(0x6B, 0x00)
        val SW_INS_NOT_SUPPORTED = bytes(0x6D, 0x00)

        private fun bytes(vararg values: Int) = ByteArray(values.size) { values[it].toByte() }
        private fun u16(value: Int) = bytes(value shr 8 and 0xFF, value and 0xFF)
    }
}
