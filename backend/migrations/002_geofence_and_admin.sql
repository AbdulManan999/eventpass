-- Richer event details for the app and the admin dashboard.
ALTER TABLE events
  ADD COLUMN description text NOT NULL DEFAULT '',
  ADD COLUMN category    text NOT NULL DEFAULT 'tech'
    CHECK (category IN ('tech', 'music', 'sports', 'business', 'community'));

-- A check-in is either a QR scan at the gate or a geofenced self check-in from
-- the attendee's own phone. Self check-ins store where the phone said it was.
ALTER TABLE scans
  ADD COLUMN method     text NOT NULL DEFAULT 'qr' CHECK (method IN ('qr', 'geofence')),
  ADD COLUMN latitude   double precision,
  ADD COLUMN longitude  double precision,
  ADD COLUMN distance_m integer;

CREATE INDEX scans_event_synced_idx ON scans (event_id, synced_at DESC);
CREATE INDEX tickets_event_idx ON tickets (event_id, issued_at DESC);
