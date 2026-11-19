-- NFC check-in: the gate phone reads the same signed ticket token from an NFC
-- wristband or from the attendee's phone (which emulates an NFC tag).
ALTER TABLE scans DROP CONSTRAINT scans_method_check;
ALTER TABLE scans ADD CONSTRAINT scans_method_check CHECK (method IN ('qr', 'nfc', 'geofence'));
