package com.abdulmanan.eventpass.nfc

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Test

/** Plays the conversation an Android or iOS NDEF reader has with a Type 4 Tag. */
class Type4TagEmulatorTest {
    private val message = ByteArray(300) { (it % 251).toByte() }

    private fun hex(s: String) = s.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
    private fun status(response: ByteArray) = response.takeLast(2).toByteArray()
    private fun data(response: ByteArray) = response.copyOfRange(0, response.size - 2)

    private val selectApp = hex("00A4040007D276000085010100")
    private val selectCc = hex("00A4000C02E103")
    private val selectNdef = hex("00A4000C02E104")
    private fun read(offset: Int, length: Int) = hex("00B0") + byteArrayOf((offset shr 8).toByte(), offset.toByte(), length.toByte())

    @Test
    fun `a reader gets the whole message, chunked by the capability container`() {
        var reads = 0
        val tag = Type4TagEmulator(message) { reads++ }

        assertArrayEquals(Type4TagEmulator.SW_OK, tag.process(selectApp))
        assertArrayEquals(Type4TagEmulator.SW_OK, tag.process(selectCc))
        val cc = data(tag.process(read(0, 15)))
        assertEquals(15, cc.size)
        assertEquals(0x20, cc[2].toInt()) // mapping version 2.0
        val mle = ((cc[3].toInt() and 0xFF) shl 8) or (cc[4].toInt() and 0xFF)
        assertArrayEquals(Type4TagEmulator.NDEF_FILE_ID, cc.copyOfRange(9, 11))
        assertEquals(0xFF.toByte(), cc[14]) // read-only

        assertArrayEquals(Type4TagEmulator.SW_OK, tag.process(selectNdef))
        val nlen = data(tag.process(read(0, 2)))
        assertEquals(message.size, ((nlen[0].toInt() and 0xFF) shl 8) or (nlen[1].toInt() and 0xFF))

        var received = ByteArray(0)
        var offset = 2
        while (received.size < message.size) {
            val chunk = tag.process(read(offset, minOf(mle, message.size - received.size)))
            assertArrayEquals(Type4TagEmulator.SW_OK, status(chunk))
            received += data(chunk)
            offset += data(chunk).size
        }
        assertArrayEquals(message, received)
        assertEquals("reports delivery once", 1, reads)

        // Reading again in the same conversation doesn't report a second delivery.
        tag.process(read(2, mle))
        tag.process(read(2 + mle, 0))
        assertEquals(1, reads)
    }

    @Test
    fun `a new tap reports a new delivery`() {
        var reads = 0
        val tag = Type4TagEmulator(ByteArray(10)) { reads++ }
        repeat(2) {
            tag.process(selectApp)
            tag.process(selectNdef)
            tag.process(read(0, 12))
            tag.reset()
        }
        assertEquals(2, reads)
    }

    @Test
    fun `refuses other applications, files and commands`() {
        val tag = Type4TagEmulator(message)
        // Payment terminals select their own AIDs; the phone must not answer them.
        assertArrayEquals(Type4TagEmulator.SW_FILE_NOT_FOUND, tag.process(hex("00A404000E325041592E5359532E444446303100")))
        // Files can't be selected before the application.
        assertArrayEquals(Type4TagEmulator.SW_FILE_NOT_FOUND, tag.process(selectNdef))
        assertArrayEquals(Type4TagEmulator.SW_NOT_ALLOWED, tag.process(read(0, 2)))

        tag.process(selectApp)
        assertArrayEquals(Type4TagEmulator.SW_FILE_NOT_FOUND, tag.process(hex("00A4000C02E105")))
        // UPDATE BINARY: the ticket is read-only.
        assertArrayEquals(Type4TagEmulator.SW_INS_NOT_SUPPORTED, tag.process(hex("00D6000002AAAA")))
        assertArrayEquals(Type4TagEmulator.SW_WRONG_LENGTH, tag.process(hex("00A4")))
        tag.process(selectNdef)
        assertArrayEquals(Type4TagEmulator.SW_WRONG_P1P2, tag.process(read(1000, 2)))
    }
}
