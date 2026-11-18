import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:eventpass/utils/nfc/ticket_ndef.dart';

final nfcServiceProvider = Provider<NfcService>((ref) => NfcService(), name: 'nfcServiceProvider');

enum NfcStatus { ready, disabled, unsupported }

enum TagWriteResult { written, tooSmall, readOnly, notNdef, cancelled, failed }

/// Everything NFC in one place, so screens stay simple and tests can fake it.
///
/// * Reading (gate staff): tickets from wristbands, stickers, and phones that
///   emulate a tag. Android keeps reader mode on while the scanner is open;
///   iOS shows its system sheet.
/// * Writing (attendees): save the ticket to a blank NFC wristband or sticker.
/// * Emulation (attendees, Android only): the phone answers as an NFC tag that
///   holds the ticket; implemented natively in `TicketHceService.kt`.
class NfcService {
  static const _channel = MethodChannel('eventpass/nfc');
  static const _events = EventChannel('eventpass/nfc/events');

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  /// iOS reads only while its system sheet is up, so scanning starts on a tap.
  bool get needsReadButton => _isIos;

  Future<NfcStatus> status() async {
    if (!_isAndroid && !_isIos) return NfcStatus.unsupported;
    try {
      return switch (await NfcManager.instance.checkAvailability()) {
        NfcAvailability.enabled => NfcStatus.ready,
        NfcAvailability.disabled => NfcStatus.disabled,
        NfcAvailability.unsupported => NfcStatus.unsupported,
      };
    } catch (_) {
      return NfcStatus.unsupported;
    }
  }

  Future<void> openSettings() async {
    if (_isAndroid) await _channel.invokeMethod<void>('openNfcSettings');
  }

  /// Calls [onTag] for every tag held to the phone, with its ticket token or
  /// null when the tag holds no ticket, until [stopReading].
  Future<void> startReading({required void Function(String? token) onTag, void Function()? onEnded}) =>
      NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        noPlatformSoundsAndroid: true, // the scanner plays its own feedback
        alertMessageIos: 'Hold the wristband or phone near the top of this iPhone.',
        invalidateAfterFirstReadIos: false,
        onSessionErrorIos: (_) => onEnded?.call(),
        onDiscovered: (tag) async {
          final ndef = Ndef.from(tag);
          NdefMessage? message = ndef?.cachedMessage;
          if (message == null && ndef != null) {
            try {
              message = await ndef.read();
            } catch (_) {
              // Pulled away mid-read: report as unreadable, the next tap will retry.
            }
          }
          onTag(TicketNdef.tokenFrom(message));
        },
      );

  Future<void> stopReading() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {
      // Already stopped.
    }
  }

  Completer<TagWriteResult>? _write;

  /// Waits for one tag and writes [token] to it.
  Future<TagWriteResult> writeTicket(String token) async {
    await cancelWrite();
    final done = _write = Completer<TagWriteResult>();
    void finish(TagWriteResult r) {
      if (!done.isCompleted) done.complete(r);
    }

    final message = TicketNdef.message(token);
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        alertMessageIos: 'Hold a blank NFC wristband or sticker near the top of your iPhone.',
        onSessionErrorIos: (_) => finish(TagWriteResult.cancelled),
        onDiscovered: (tag) async {
          final ndef = Ndef.from(tag);
          TagWriteResult result;
          if (ndef == null) {
            result = TagWriteResult.notNdef;
          } else if (!ndef.isWritable) {
            result = TagWriteResult.readOnly;
          } else if (ndef.maxSize < message.byteLength) {
            result = TagWriteResult.tooSmall;
          } else {
            try {
              await ndef.write(message: message);
              result = TagWriteResult.written;
            } catch (_) {
              result = TagWriteResult.failed;
            }
          }
          await NfcManager.instance.stopSession(
            alertMessageIos: result == TagWriteResult.written ? 'Saved to the wristband' : null,
            errorMessageIos: result == TagWriteResult.written ? null : 'Could not save the ticket',
          );
          finish(result);
        },
      );
    } catch (_) {
      finish(TagWriteResult.failed);
    }
    return done.future;
  }

  Future<void> cancelWrite() async {
    final pending = _write;
    if (pending == null || pending.isCompleted) return;
    pending.complete(TagWriteResult.cancelled);
    await stopReading();
  }

  /// True when this phone can act as an NFC ticket (Android with host card emulation).
  Future<bool> canEmulate() async {
    if (!_isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isEmulationSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Makes the phone answer gate readers as a tag holding [token], until [stopEmulation].
  Future<void> startEmulation(String token) =>
      _channel.invokeMethod<void>('startEmulation', {'ndefMessage': TicketNdef.encode(token)});

  Future<void> stopEmulation() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stopEmulation');
    } catch (_) {
      // Activity already gone; the native side clears emulation on destroy.
    }
  }

  /// Fires each time a gate reader finishes reading the emulated ticket.
  Stream<void> get emulationReads => _events.receiveBroadcastStream().where((e) => e == 'read').map((_) {});
}
